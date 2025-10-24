package com.example.hivpn.vpn

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED) {
            Log.d(TAG, "Boot completed; secure auto-connect disabled.")
        }
    }

    companion object {
        private const val TAG = "BootReceiver"
    }
}

class NetworkChangeReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        Log.d(TAG, "Network change detected; waiting for user-initiated reconnect.")
    }

    companion object {
        private const val TAG = "NetworkReceiver"
    }
}
