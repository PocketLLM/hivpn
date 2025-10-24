package com.example.hivpn.vpn

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat
import com.example.hivpn.MainActivity
import com.example.hivpn.R
import com.wireguard.android.backend.GoBackend
import com.wireguard.android.backend.Tunnel
import com.wireguard.config.BadConfigException
import com.wireguard.config.Config
import com.wireguard.config.Interface
import com.wireguard.config.Peer
import java.util.concurrent.atomic.AtomicBoolean
import org.json.JSONArray
import org.json.JSONObject

class WireGuardService : GoBackend.VpnService() {
    override fun onBind(intent: Intent?): IBinder? = null

    private val prefs: SharedPreferences by lazy {
        getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
    }

    override fun onCreate() {
        super.onCreate()
        appContext = applicationContext
        createNotificationChannel()
        ensureBackend()
    }

    override fun onDestroy() {
        super.onDestroy()
        if (!isConnected.get()) {
            backend = null
            tunnel = null
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        super.onStartCommand(intent, flags, startId)
        when (intent?.action) {
            ACTION_CONNECT -> {
                val config = intent.getStringExtra(EXTRA_CONFIG)
                config?.let { handleConnect(it) }
            }
            ACTION_DISCONNECT -> handleDisconnect()
        }
        return START_STICKY
    }

    private fun handleConnect(configJson: String) {
        if (isConnected.get()) {
            updateNotification("Connected")
            return
        }

        prefs.edit().putString(KEY_LAST_CONFIG, configJson).apply()
        val notification = buildNotification("Connecting…")
        startForeground(NOTIFICATION_ID, notification)

        try {
            val json = JSONObject(configJson)
            val serverLabel = json.optString("serverName", json.optString("peerEndpoint", ""))
            val tunnelLabel = json.optString("tunnelName", DEFAULT_TUNNEL_NAME)
            val config = buildWireGuardConfig(json)
            val backendInstance = ensureBackend()
            val tunnelInstance = ensureTunnel(tunnelLabel.ifBlank { DEFAULT_TUNNEL_NAME })
            backendInstance.setState(tunnelInstance, Tunnel.State.UP, config)
            startedAt = System.currentTimeMillis()
            lastError = null
            updateNotification(
                if (serverLabel.isNotBlank()) "Connected to $serverLabel" else "Connected",
            )
        } catch (error: BadConfigException) {
            Log.e(TAG, "Invalid WireGuard config", error)
            lastError = error.localizedMessage ?: "Invalid configuration"
            updateNotification("Configuration error")
            setConnected(false)
            stopForeground(STOP_FOREGROUND_REMOVE)
            stopSelf()
            return
        } catch (error: Throwable) {
            Log.e(TAG, "Failed to start WireGuard backend", error)
            lastError = error.localizedMessage ?: error::class.java.simpleName
            updateNotification("Connection failed")
            setConnected(false)
            stopForeground(STOP_FOREGROUND_REMOVE)
            stopSelf()
            return
        }

        HiVpnTileService.requestTileUpdate(this)
    }

    private fun handleDisconnect() {
        if (!isConnected.get()) {
            stopForeground(STOP_FOREGROUND_REMOVE)
            stopSelf()
            setConnected(false)
            HiVpnTileService.requestTileUpdate(this)
            return
        }

        val backendInstance = backend
        val tunnelInstance = tunnel
        try {
            if (backendInstance != null && tunnelInstance != null) {
                backendInstance.setState(tunnelInstance, Tunnel.State.DOWN, null)
            }
        } catch (error: Throwable) {
            Log.e(TAG, "Failed to stop WireGuard backend", error)
            lastError = error.localizedMessage ?: error::class.java.simpleName
        } finally {
            stopForeground(STOP_FOREGROUND_REMOVE)
            stopSelf()
            setConnected(false)
            HiVpnTileService.requestTileUpdate(this)
        }
    }

    override fun onRevoke() {
        super.onRevoke()
        handleDisconnect()
    }

    private fun ensureBackend(): GoBackend {
        var existing = backend
        if (existing == null) {
            existing = GoBackend(applicationContext)
            backend = existing
        }
        return existing
    }

    private fun ensureTunnel(name: String): ServiceTunnel {
        val current = tunnel
        if (current == null || current.getName() != name) {
            val created = ServiceTunnel(name)
            tunnel = created
            return created
        }
        return current
    }

    private fun buildWireGuardConfig(json: JSONObject): Config {
        val interfaceBuilder = Interface.Builder()
        interfaceBuilder.parsePrivateKey(json.getString("interfacePrivateKey"))

        json.optString("interfaceAddress").takeIf { it.isNotBlank() }?.let {
            interfaceBuilder.parseAddresses(it)
        }

        val dnsValues = mutableSetOf<String>()
        json.optString("interfaceDns").takeIf { it.isNotBlank() }?.let {
            dnsValues.addAll(it.split(',').mapNotNull { value -> value.trim().takeIf(String::isNotEmpty) })
        }
        json.optJSONArray("dnsServers")?.let { array ->
            dnsValues.addAll(array.toStringList())
        }
        if (dnsValues.isNotEmpty()) {
            interfaceBuilder.parseDnsServers(dnsValues.joinToString(","))
        }

        val mtu = json.optInt("mtu", -1)
        if (mtu > 0) {
            interfaceBuilder.setMtu(mtu)
        }

        val splitMode = json.optString("splitTunnelMode", "allTraffic")
        if (splitMode == "selectedApps") {
            val packages = json.optJSONArray("splitTunnelPackages")?.toStringList()?.filter { it.isNotBlank() }
            if (!packages.isNullOrEmpty()) {
                interfaceBuilder.includeApplications(packages)
            }
        }

        val peerBuilder = Peer.Builder()
        peerBuilder.parsePublicKey(json.getString("peerPublicKey"))
        peerBuilder.parseAllowedIPs(json.getString("peerAllowedIps"))
        json.optString("peerEndpoint").takeIf { it.isNotBlank() }?.let {
            peerBuilder.parseEndpoint(it)
        }
        if (json.has("peerPersistentKeepalive")) {
            val keepalive = json.optInt("peerPersistentKeepalive", 0)
            if (keepalive > 0) {
                peerBuilder.setPersistentKeepalive(keepalive)
            }
        }

        return Config.Builder()
            .setInterface(interfaceBuilder.build())
            .addPeer(peerBuilder.build())
            .build()
    }

    private fun JSONArray.toStringList(): List<String> {
        val values = mutableListOf<String>()
        for (index in 0 until length()) {
            val value = optString(index)
            if (!value.isNullOrBlank()) {
                values.add(value)
            }
        }
        return values
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "HiVPN",
                NotificationManager.IMPORTANCE_LOW,
            )
            val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            manager.createNotificationChannel(channel)
        }
    }

    private fun updateNotification(content: String) {
        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        manager.notify(NOTIFICATION_ID, buildNotification(content))
    }

    private fun buildNotification(content: String): Notification {
        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            Intent(this, MainActivity::class.java),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("HiVPN")
            .setContentText(content)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .addAction(
                R.drawable.notification_icon_background,
                "Disconnect",
                PendingIntent.getService(
                    this,
                    1,
                    Intent(this, WireGuardService::class.java).apply { action = ACTION_DISCONNECT },
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
                ),
            )
            .addAction(
                R.drawable.notification_icon_background,
                "Extend",
                PendingIntent.getActivity(
                    this,
                    2,
                    Intent(this, MainActivity::class.java).apply {
                        flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                    },
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
                ),
            )
            .build()
    }

    private class ServiceTunnel(private val label: String) : Tunnel {
        @Volatile
        private var state: Tunnel.State = Tunnel.State.DOWN

        override fun getName(): String = label

        override fun getState(): Tunnel.State = state

        override fun onStateChange(newState: Tunnel.State) {
            state = newState
            setConnected(newState == Tunnel.State.UP)
        }
    }

    companion object {
        private const val TAG = "WireGuardService"
        const val ACTION_CONNECT = "com.example.hivpn.vpn.CONNECT"
        const val ACTION_DISCONNECT = "com.example.hivpn.vpn.DISCONNECT"
        const val EXTRA_CONFIG = "config"
        private const val CHANNEL_ID = "hivpn_vpn"
        private const val NOTIFICATION_ID = 1001
        private const val PREFS_NAME = "hivpn_service"
        private const val KEY_LAST_CONFIG = "last_config"
        private const val DEFAULT_TUNNEL_NAME = "HiVPN"

        @Volatile
        private var backend: GoBackend? = null

        @Volatile
        private var tunnel: ServiceTunnel? = null

        @Volatile
        private var startedAt: Long = 0L

        private val isConnected = AtomicBoolean(false)

        @Volatile
        private var lastError: String? = null

        @Volatile
        private var appContext: Context? = null

        fun requestConnect(context: Context, config: String) {
            val intent = Intent(context, WireGuardService::class.java).apply {
                action = ACTION_CONNECT
                putExtra(EXTRA_CONFIG, config)
            }
            ContextCompat.startForegroundService(context, intent)
        }

        fun requestDisconnect(context: Context) {
            val intent = Intent(context, WireGuardService::class.java).apply {
                action = ACTION_DISCONNECT
            }
            context.startService(intent)
        }

        fun isActive(): Boolean = isConnected.get()

        fun currentStats(): Map<String, Any> {
            val connected = isConnected.get()
            val stats = mutableMapOf<String, Any>("state" to if (connected) "connected" else "idle")
            if (startedAt > 0) {
                stats["startedAt"] = startedAt
            }
            if (connected) {
                val backendInstance = backend
                val tunnelInstance = tunnel
                if (backendInstance != null && tunnelInstance != null) {
                    try {
                        val statistics = backendInstance.getStatistics(tunnelInstance)
                        stats["rxBytes"] = statistics.totalRx()
                        stats["txBytes"] = statistics.totalTx()
                    } catch (error: Throwable) {
                        Log.e(TAG, "Unable to read tunnel statistics", error)
                        stats["error"] = error.localizedMessage ?: error::class.java.simpleName
                    }
                }
            }
            lastError?.let { stats["error"] = it }
            return stats
        }

        fun persistLastConfig(context: Context, config: String) {
            context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                .edit()
                .putString(KEY_LAST_CONFIG, config)
                .apply()
        }

        fun lastConfig(context: Context): String {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            return prefs.getString(KEY_LAST_CONFIG, "{}") ?: "{}"
        }

        private fun setConnected(value: Boolean) {
            val previous = isConnected.getAndSet(value)
            if (!value) {
                startedAt = 0L
            }
            if (previous != value) {
                appContext?.let { HiVpnTileService.requestTileUpdate(it) }
            }
        }
    }
}
