package com.example.hivpn.vpn

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Handler
import android.os.HandlerThread
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

    private val powerManager: PowerManager by lazy {
        getSystemService(Context.POWER_SERVICE) as PowerManager
    }

    private val notificationManager: NotificationManager by lazy {
        getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
    }

    private val handlerThread = HandlerThread("HiVpnNotification").apply { start() }
    private val updateHandler = Handler(handlerThread.looper)
    private val updateRunnable = Runnable { updateNotificationInternal(); scheduleNextUpdate() }

    private var activeSession: SessionMeta? = null

    override fun onCreate() {
        super.onCreate()
        appContext = applicationContext
        createNotificationChannel()
        ensureBackend()
        activeSession = loadPersistedMeta()
    }

    override fun onDestroy() {
        updateHandler.removeCallbacksAndMessages(null)
        if (!isConnected.get()) {
            handlerThread.quitSafely()
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
            ACTION_EXTEND -> handleExtend(intent)
        }
        return START_STICKY
    }

    private fun handleConnect(configJson: String) {
        val connectingNotification = buildNotification(
            title = getString(R.string.app_name) + " — Connecting…",
            timeRemaining = "--:--",
            ipAddress = "--"
        )
        startForeground(NOTIFICATION_ID, connectingNotification)

        try {
            val json = JSONObject(configJson)
            val sessionMeta = SessionMeta.fromJson(json) ?: SessionMeta.default()
            val config = buildWireGuardConfig(json)
            val backendInstance = ensureBackend()
            val tunnelInstance = ensureTunnel(sessionMeta.tunnelName)
            backendInstance.setState(tunnelInstance, Tunnel.State.UP, config)
            activeSession = sessionMeta.copy(startElapsedMs = sessionMeta.startElapsedMs.takeIf { it > 0 }
                ?: SystemClock.elapsedRealtime())
            persistMeta(activeSession)
            lastError = null
            setConnected(true)
            updateNotificationInternal(true)
            scheduleNextUpdate(0L)
        } catch (error: BadConfigException) {
            Log.e(TAG, "Invalid WireGuard config", error)
            lastError = error.localizedMessage ?: "Invalid configuration"
            setConnected(false)
            stopForeground(STOP_FOREGROUND_REMOVE)
            stopSelf()
            telemetry = null
        } catch (error: Throwable) {
            Log.e(TAG, "Failed to start WireGuard backend", error)
            lastError = error.localizedMessage ?: error::class.java.simpleName
            setConnected(false)
            stopForeground(STOP_FOREGROUND_REMOVE)
            stopSelf()
            telemetry = null
        }
    }

    private fun handleExtend(intent: Intent) {
        val durationMs = intent.getLongExtra(EXTRA_DURATION_MS, -1L)
        if (durationMs <= 0) {
            return
        }
        val ip = intent.getStringExtra(EXTRA_PUBLIC_IP)
        val session = activeSession ?: return
        activeSession = session.copy(durationMs = durationMs, publicIp = ip ?: session.publicIp)
        persistMeta(activeSession)
        updateNotificationInternal(true)
        scheduleNextUpdate(0L)
    }

    private fun handleDisconnect() {
        updateHandler.removeCallbacks(updateRunnable)
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
            persistMeta(null)
            activeSession = null
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
            )
            channel.setShowBadge(false)
            notificationManager.createNotificationChannel(channel)
        }
    }

    private fun scheduleNextUpdate(delayOverride: Long? = null) {
        updateHandler.removeCallbacks(updateRunnable)
        val delay = delayOverride ?: if (powerManager.isInteractive) 1000L else 15_000L
        updateHandler.postDelayed(updateRunnable, delay)
    }

    private fun updateNotificationInternal(force: Boolean = false) {
        val session = activeSession
        val now = SystemClock.elapsedRealtime()
        val remaining = session?.let { (it.startElapsedMs + it.durationMs) - now } ?: 0L
        val clamped = remaining.coerceAtLeast(0L)
        val minutes = (clamped / 1000) / 60
        val seconds = (clamped / 1000) % 60
        val remainingLabel = String.format(Locale.US, "%02d:%02d", minutes, seconds)
        val ipLabel = session?.publicIp?.takeIf { it.isNotBlank() } ?: "--"
        val displayName = session?.displayName().orEmpty()
        val title = if (session != null && isConnected.get()) {
            if (displayName.isNotBlank()) {
                "HiVPN — Connected to $displayName"
            } else {
                "HiVPN — Connected"
            }
        } else {
            getString(R.string.app_name) + " — Connecting…"
        }
        val notification = buildNotification(
            title = title,
            timeRemaining = remainingLabel,
            ipAddress = ipLabel,
        )
        if (force) {
            notificationManager.notify(NOTIFICATION_ID, notification)
        } else {
            notificationManager.notify(NOTIFICATION_ID, notification)
        }
    }

    private fun buildNotification(
        title: String,
        timeRemaining: String,
        ipAddress: String,
    ): Notification {
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(title)
            .setContentText("Time left: $timeRemaining")
            .setStyle(
                NotificationCompat.InboxStyle()
                    .addLine("Time left: $timeRemaining")
                    .addLine("IP: $ipAddress")
            )
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setCategory(NotificationCompat.CATEGORY_SERVICE)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setContentIntent(mainPendingIntent())
            .addAction(
                NotificationCompat.Action(
                    R.drawable.notification_icon_background,
                    "Disconnect",
                    disconnectPendingIntent(),
                ),
            )
            .addAction(
                NotificationCompat.Action(
                    R.drawable.notification_icon_background,
                    "Extend",
                    extendPendingIntent(),
                ),
            )
            .build()
    }

    private fun mainPendingIntent(): PendingIntent {
        val intent = Intent(this, MainActivity::class.java)
        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        return PendingIntent.getActivity(
            this,
            0,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }

    private fun disconnectPendingIntent(): PendingIntent {
        val intent = Intent(this, WireGuardService::class.java).apply {
            action = ACTION_DISCONNECT
        }
        return PendingIntent.getService(
            this,
            1,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }

    private fun extendPendingIntent(): PendingIntent {
        val intent = Intent(this, ExtendReceiver::class.java).apply {
            action = ExtendReceiver.ACTION_EXTEND
        }
        return PendingIntent.getBroadcast(
            this,
            2,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }

    private fun persistMeta(meta: SessionMeta?) {
        if (meta == null) {
            prefs.edit().remove(KEY_SESSION_META).apply()
        } else {
            prefs.edit().putString(KEY_SESSION_META, meta.toJson().toString()).apply()
        }
    }

    private fun loadPersistedMeta(): SessionMeta? {
        val raw = prefs.getString(KEY_SESSION_META, null) ?: return null
        return try {
            SessionMeta.fromJson(JSONObject(raw))
        } catch (error: Throwable) {
            Log.w(TAG, "Failed to parse stored session meta", error)
            null
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

    private data class SessionMeta(
        val serverId: String?,
        val serverName: String?,
        val countryCode: String?,
        val publicIp: String?,
        val startElapsedMs: Long,
        val durationMs: Long,
        val tunnelName: String,
    ) {
        fun toJson(): JSONObject {
            return JSONObject().apply {
                put("serverId", serverId)
                put("serverName", serverName)
                put("countryCode", countryCode)
                put("publicIp", publicIp)
                put("startElapsedMs", startElapsedMs)
                put("durationMs", durationMs)
                put("tunnelName", tunnelName)
            }
        }

        fun displayName(): String {
            val flag = countryCode?.let { flagFromCountry(it) } ?: ""
            val name = serverName ?: "Unknown"
            return "$flag $name".trim()
        }

        companion object {
            fun fromJson(json: JSONObject): SessionMeta? {
                val duration = json.optLong("sessionDurationMs", json.optLong("durationMs", -1))
                if (duration <= 0) {
                    return null
                }
                val start = json.optLong("sessionStartElapsedMs", json.optLong("startElapsedMs", -1))
                val tunnelName = json.optString("tunnelName", DEFAULT_TUNNEL_NAME)
                return SessionMeta(
                    serverId = json.optString("serverId", null),
                    serverName = json.optString("serverName", null),
                    countryCode = json.optString("countryCode", null),
                    publicIp = json.optString("publicIp", null),
                    startElapsedMs = if (start > 0) start else SystemClock.elapsedRealtime(),
                    durationMs = duration,
                    tunnelName = tunnelName,
                )
            }

            fun default(): SessionMeta {
                return SessionMeta(
                    serverId = null,
                    serverName = null,
                    countryCode = null,
                    publicIp = null,
                    startElapsedMs = SystemClock.elapsedRealtime(),
                    durationMs = DEFAULT_DURATION_MS,
                    tunnelName = DEFAULT_TUNNEL_NAME,
                )
            }

            private fun flagFromCountry(country: String): String {
                if (country.length < 2) return ""
                val first = Character.codePointAt(country.uppercase(Locale.US), 0) - 0x41 + 0x1F1E6
                val second = Character.codePointAt(country.uppercase(Locale.US), 1) - 0x41 + 0x1F1E6
                return String(Character.toChars(first)) + String(Character.toChars(second))
            }
        }
    }

    companion object {
        private const val TAG = "WireGuardService"
        const val ACTION_CONNECT = "com.example.hivpn.vpn.CONNECT"
        const val ACTION_DISCONNECT = "com.example.hivpn.vpn.DISCONNECT"
        const val ACTION_EXTEND = "com.example.hivpn.vpn.EXTEND"
        const val EXTRA_CONFIG = "config"
        private const val EXTRA_DURATION_MS = "durationMs"
        private const val EXTRA_PUBLIC_IP = "publicIp"
        private const val CHANNEL_ID = "hivpn.tunnel"
        private const val NOTIFICATION_ID = 1001
        private const val PREFS_NAME = "hivpn_service"
        private const val KEY_SESSION_META = "session_meta"
        private const val DEFAULT_TUNNEL_NAME = "HiVPN"
        private const val DEFAULT_DURATION_MS = 60L * 60L * 1000L

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

        fun extendSession(context: Context, durationMs: Long, publicIp: String?) {
            val intent = Intent(context, WireGuardService::class.java).apply {
                action = ACTION_EXTEND
                putExtra(EXTRA_DURATION_MS, durationMs)
                if (!publicIp.isNullOrBlank()) {
                    putExtra(EXTRA_PUBLIC_IP, publicIp)
                }
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

        private fun setConnected(value: Boolean) {
            val previous = isConnected.getAndSet(value)
            if (value) {
                startedAt = System.currentTimeMillis()
            } else {
                startedAt = 0L
            }
            if (previous != value) {
                appContext?.let { HiVpnTileService.requestTileUpdate(it) }
            }
        }
    }
}
