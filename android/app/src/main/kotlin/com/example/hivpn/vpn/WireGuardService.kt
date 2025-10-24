package com.example.hivpn.vpn

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder
import android.os.PowerManager
import android.os.SystemClock
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
import java.util.Locale
import java.util.concurrent.TimeUnit
import java.util.concurrent.atomic.AtomicBoolean
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.delay
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch
import org.json.JSONArray
import org.json.JSONObject

class WireGuardService : GoBackend.VpnService() {
    override fun onBind(intent: Intent?): IBinder? = null

    private val notificationManager by lazy {
        getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
    }
    private val powerManager by lazy {
        getSystemService(Context.POWER_SERVICE) as PowerManager
    }
    private val serviceScope = CoroutineScope(SupervisorJob() + Dispatchers.Main.immediate)

    private var telemetryJob: Job? = null
    @Volatile private var telemetry: SessionTelemetry? = null

    override fun onCreate() {
        super.onCreate()
        appContext = applicationContext
        createNotificationChannel()
        ensureBackend()
    }

    override fun onDestroy() {
        telemetryJob?.cancel()
        serviceScope.cancel()
        if (!isConnected.get()) {
            backend = null
            tunnel = null
        }
        super.onDestroy()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_CONNECT -> {
                val configJson = intent.getStringExtra(EXTRA_CONFIG)
                if (configJson != null) {
                    handleConnect(configJson)
                }
            }
            ACTION_DISCONNECT -> handleDisconnect()
            ACTION_EXTEND_SESSION -> {
                val additional = intent.getLongExtra(EXTRA_EXTEND_DURATION, 0L)
                val ip = intent.getStringExtra(EXTRA_EXTEND_IP)
                handleExtend(additional, ip)
            }
        }
        return START_STICKY
    }

    private fun handleConnect(configJson: String) {
        val parsedTelemetry = parseTelemetry(configJson)
        telemetry = parsedTelemetry
        val preparingNotification = buildNotification(parsedTelemetry, connected = false)
        startForeground(NOTIFICATION_ID, preparingNotification)

        if (isConnected.get()) {
            updateNotification(parsedTelemetry, connected = true)
            return
        }

        try {
            val json = JSONObject(configJson)
            val tunnelLabel = json.optString("tunnelName", DEFAULT_TUNNEL_NAME).ifBlank { DEFAULT_TUNNEL_NAME }
            val config = buildWireGuardConfig(json)
            val backendInstance = ensureBackend()
            val tunnelInstance = ensureTunnel(tunnelLabel)
            backendInstance.setState(tunnelInstance, Tunnel.State.UP, config)
            startedAt = SystemClock.elapsedRealtime()
            lastError = null
            setConnected(true)
            startTelemetry(parsedTelemetry)
            HiVpnTileService.requestTileUpdate(this)
        } catch (error: BadConfigException) {
            Log.e(TAG, "Invalid WireGuard config", error)
            lastError = error.localizedMessage ?: "Invalid configuration"
            updateNotification(parsedTelemetry, connected = false)
            setConnected(false)
            stopForeground(STOP_FOREGROUND_REMOVE)
            stopSelf()
            telemetry = null
        } catch (error: Throwable) {
            Log.e(TAG, "Failed to start WireGuard backend", error)
            lastError = error.localizedMessage ?: error::class.java.simpleName
            updateNotification(parsedTelemetry, connected = false)
            setConnected(false)
            stopForeground(STOP_FOREGROUND_REMOVE)
            stopSelf()
            telemetry = null
        }
    }

    private fun handleDisconnect() {
        telemetryJob?.cancel()
        telemetryJob = null
        telemetry = null
        if (!isConnected.get()) {
            stopForeground(STOP_FOREGROUND_REMOVE)
            stopSelf()
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

    private fun handleExtend(additionalDurationMs: Long, ip: String?) {
        val current = telemetry ?: return
        if (additionalDurationMs <= 0 && ip.isNullOrBlank()) {
            return
        }
        val updated = current.extend(additionalDurationMs, ip)
        startTelemetry(updated)
    }

    private fun startTelemetry(meta: SessionTelemetry) {
        telemetry = meta
        telemetryJob?.cancel()
        telemetryJob = serviceScope.launch {
            while (isActive && telemetry != null) {
                updateNotification(telemetry!!, connected = true)
                val delayMs = if (powerManager.isInteractive) 1_000L else 15_000L
                delay(delayMs)
            }
        }
        updateNotification(meta, connected = true)
    }

    private fun updateNotification(meta: SessionTelemetry, connected: Boolean) {
        notificationManager.notify(NOTIFICATION_ID, buildNotification(meta, connected))
    }

    private fun buildNotification(meta: SessionTelemetry, connected: Boolean): Notification {
        val remainingMs = meta.remainingMs(SystemClock.elapsedRealtime())
        val minutes = TimeUnit.MILLISECONDS.toMinutes(remainingMs)
        val seconds = TimeUnit.MILLISECONDS.toSeconds(remainingMs) % 60
        val timeLeft = String.format(Locale.US, "%02d:%02d", minutes, seconds)
        val countryName = meta.countryName.ifBlank { meta.serverName }
        val title = if (connected) {
            "HiVPN — Connected to ${meta.flagEmoji} $countryName"
        } else {
            "HiVPN — Connecting…"
        }
        val ipLine = "IP: ${meta.publicIp ?: "--"}"

        val contentIntent = PendingIntent.getActivity(
            this,
            0,
            Intent(this, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            },
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        val disconnectIntent = PendingIntent.getService(
            this,
            1,
            Intent(this, WireGuardService::class.java).apply { action = ACTION_DISCONNECT },
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        val extendIntent = PendingIntent.getActivity(
            this,
            2,
            Intent(this, MainActivity::class.java).apply {
                action = ACTION_SHOW_EXTEND_AD
                putExtra(EXTRA_NOTIFICATION_ACTION, ACTION_SHOW_EXTEND_AD)
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            },
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle(title.trim())
            .setStyle(
                NotificationCompat.InboxStyle()
                    .addLine("Time left: $timeLeft")
                    .addLine(ipLine)
            )
            .setContentIntent(contentIntent)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .addAction(
                R.drawable.notification_icon_background,
                "Disconnect",
                disconnectIntent,
            )
            .addAction(
                R.drawable.notification_icon_background,
                "Extend",
                extendIntent,
            )
            .build()
    }

    private fun parseTelemetry(configJson: String): SessionTelemetry {
        val json = JSONObject(configJson)
        val serverName = json.optString("sessionServerName", json.optString("serverName", json.optString("peerEndpoint", DEFAULT_TUNNEL_NAME)))
        val countryCode = json.optString("sessionCountryCode", "")
        val startElapsed = json.optLong("sessionStartElapsedMs", SystemClock.elapsedRealtime())
        val durationMs = json.optLong("sessionDurationMs", TimeUnit.HOURS.toMillis(1))
        val serverId = json.optString("sessionServerId", json.optString("serverId", serverName))
        val ip = json.optString("publicIp", null)
        return SessionTelemetry(
            serverId = serverId,
            serverName = serverName,
            countryCode = countryCode,
            startElapsedRealtime = startElapsed,
            durationMs = durationMs,
            publicIp = ip?.takeIf { it.isNotBlank() },
        )
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
        if (current == null || current.name != name) {
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
                "HiVPN Tunnel",
                NotificationManager.IMPORTANCE_LOW,
            ).apply {
                description = "Tunnel status"
            }
            notificationManager.createNotificationChannel(channel)
        }
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

    private class ServiceTunnel(private val label: String) : Tunnel {
        @Volatile private var state: Tunnel.State = Tunnel.State.DOWN

        override fun getName(): String = label

        override fun getState(): Tunnel.State = state

        override fun onStateChange(newState: Tunnel.State) {
            state = newState
            setConnected(newState == Tunnel.State.UP)
        }
    }

    data class SessionTelemetry(
        val serverId: String,
        val serverName: String,
        val countryCode: String,
        val startElapsedRealtime: Long,
        val durationMs: Long,
        val publicIp: String?,
    ) {
        val endElapsedRealtime: Long get() = startElapsedRealtime + durationMs
        val countryName: String = countryCode.takeIf { it.isNotBlank() }?.let { Locale("", it).displayCountry } ?: ""
        val flagEmoji: String = countryCode.takeIf { it.isNotBlank() }?.let { code ->
            code.uppercase(Locale.US).map { char ->
                Character.toChars(0x1F1E6 + (char.code - 'A'.code)).concatToString()
            }.joinToString(separator = "")
        } ?: ""

        fun remainingMs(nowElapsed: Long): Long = (endElapsedRealtime - nowElapsed).coerceAtLeast(0L)

        fun extend(additionalDurationMs: Long, ip: String?): SessionTelemetry {
            val updatedDuration = if (additionalDurationMs > 0) durationMs + additionalDurationMs else durationMs
            val updatedIp = ip?.takeIf { it.isNotBlank() } ?: publicIp
            return copy(durationMs = updatedDuration, publicIp = updatedIp)
        }

        fun toJson(): Map<String, Any?> {
            return mapOf(
                "serverId" to serverId,
                "serverName" to serverName,
                "countryCode" to countryCode,
                "startElapsedMs" to startElapsedRealtime,
                "durationMs" to durationMs,
                "publicIp" to publicIp,
            )
        }
    }

    companion object {
        private const val TAG = "WireGuardService"
        const val ACTION_CONNECT = "com.example.hivpn.vpn.CONNECT"
        const val ACTION_DISCONNECT = "com.example.hivpn.vpn.DISCONNECT"
        private const val ACTION_EXTEND_SESSION = "com.example.hivpn.vpn.EXTEND"
        const val EXTRA_CONFIG = "config"
        private const val EXTRA_EXTEND_DURATION = "extend_duration"
        private const val EXTRA_EXTEND_IP = "extend_ip"
        private const val EXTRA_NOTIFICATION_ACTION = "notification_action"
        private const val ACTION_SHOW_EXTEND_AD = "SHOW_EXTEND_AD"
        private const val CHANNEL_ID = "hivpn.tunnel"
        private const val NOTIFICATION_ID = 1001
        private const val DEFAULT_TUNNEL_NAME = "HiVPN"

        @Volatile private var backend: GoBackend? = null
        @Volatile private var tunnel: ServiceTunnel? = null
        @Volatile private var startedAt: Long = 0L
        private val isConnected = AtomicBoolean(false)
        @Volatile private var lastError: String? = null
        @Volatile private var appContext: Context? = null

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

        fun extendSession(additionalDurationMs: Long, ip: String?) {
            val context = appContext ?: return
            val intent = Intent(context, WireGuardService::class.java).apply {
                action = ACTION_EXTEND_SESSION
                putExtra(EXTRA_EXTEND_DURATION, additionalDurationMs)
                if (!ip.isNullOrBlank()) {
                    putExtra(EXTRA_EXTEND_IP, ip)
                }
            }
            ContextCompat.startForegroundService(context, intent)
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
    }
}
