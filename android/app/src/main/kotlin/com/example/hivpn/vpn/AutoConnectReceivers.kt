package com.example.hivpn.vpn

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.net.ConnectivityManager
import android.util.Log
import org.json.JSONObject

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED) {
            val config = WireGuardService.lastConfig(context)
            if (config.isEmpty() || config == "{}") return
            val json = JSONObject(config)
            if (json.optBoolean("connectOnBoot", false)) {
                Log.d(TAG, "Auto connecting on boot")
                WireGuardService.requestConnect(context, config)
            }
        }
    }

    companion object {
        private const val TAG = "BootReceiver"
    }
}

class NetworkChangeReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val config = WireGuardService.lastConfig(context)
        if (config.isEmpty() || config == "{}") return
        val json = JSONObject(config)
        if (json.optBoolean("reconnectOnNetworkChange", false)) {
            val connectivity = context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
            val active = connectivity.activeNetworkInfo
            if (active != null && active.isConnected) {
                Log.d(TAG, "Network change detected, reconnecting")
                WireGuardService.requestConnect(context, config)
            }
        }
    }

    companion object {
        private const val TAG = "NetworkReceiver"
    }
}
