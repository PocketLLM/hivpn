package com.example.hivpn.vpn

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat
import com.example.hivpn.MainActivity
import com.example.hivpn.R

class WireGuardService : android.net.VpnService() {
    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
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
        if (isConnected) {
            updateNotification("Connected")
            return
        }
        Log.d(TAG, "Configuring WireGuard: $configJson")
        val notification = buildNotification("Connecting…")
        startForeground(NOTIFICATION_ID, notification)
        // TODO: integrate actual WireGuard backend.
        isConnected = true
        updateNotification("Connected")
    }

    private fun handleDisconnect() {
        if (!isConnected) return
        isConnected = false
        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
    }

    override fun onRevoke() {
        super.onRevoke()
        handleDisconnect()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "HiVPN",
                NotificationManager.IMPORTANCE_LOW
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
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
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
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
            )
            .build()
    }

    companion object {
        private const val TAG = "WireGuardService"
        const val ACTION_CONNECT = "com.example.hivpn.vpn.CONNECT"
        const val ACTION_DISCONNECT = "com.example.hivpn.vpn.DISCONNECT"
        const val EXTRA_CONFIG = "config"
        private const val CHANNEL_ID = "hivpn_vpn"
        private const val NOTIFICATION_ID = 1001

        @Volatile
        private var isConnected: Boolean = false

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

        fun isActive(): Boolean = isConnected
    }
}
