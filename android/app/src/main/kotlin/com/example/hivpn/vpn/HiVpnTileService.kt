package com.example.hivpn.vpn

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.service.quicksettings.Tile
import android.service.quicksettings.TileService
import com.example.hivpn.MainActivity

class HiVpnTileService : TileService() {
    override fun onStartListening() {
        super.onStartListening()
        refreshTile()
    }

    override fun onClick() {
        super.onClick()
        if (WireGuardService.isActive()) {
            WireGuardService.requestDisconnect(this)
        } else {
            val launch = Intent(this, MainActivity::class.java).apply {
                action = Intent.ACTION_MAIN
                addCategory(Intent.CATEGORY_LAUNCHER)
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_RESET_TASK_IF_NEEDED
            }
            startActivityAndCollapse(launch)
        }
        refreshTile()
    }

    private fun refreshTile() {
        val tile = qsTile ?: return
        if (WireGuardService.isActive()) {
            tile.state = Tile.STATE_ACTIVE
            tile.label = "HiVPN — Connected"
        } else {
            tile.state = Tile.STATE_INACTIVE
            tile.label = "HiVPN — Tap to connect"
        }
        tile.updateTile()
    }

    companion object {
        fun requestTileUpdate(context: Context) {
            val intent = Intent(context, HiVpnTileService::class.java)
            requestListeningState(context, ComponentName(context, HiVpnTileService::class.java))
            context.startService(intent)
        }
    }
}
