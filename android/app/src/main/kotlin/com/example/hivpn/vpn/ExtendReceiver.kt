package com.example.hivpn.vpn

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import com.example.hivpn.MainActivity

class ExtendReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        if (intent?.action != ACTION_EXTEND) {
            return
        }
        val launch = Intent(context, MainActivity::class.java).apply {
            action = MainActivity.ACTION_SHOW_EXTEND_AD
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
        }
        context.startActivity(launch)
    }

    companion object {
        const val ACTION_EXTEND = "com.example.hivpn.vpn.ACTION_EXTEND"
    }
}
