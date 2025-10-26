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
        // Open the main activity when tile is clicked
        val launch = Intent(this, MainActivity::class.java).apply {
            action = Intent.ACTION_MAIN
            addCategory(Intent.CATEGORY_LAUNCHER)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_RESET_TASK_IF_NEEDED
        }
        startActivityAndCollapse(launch)
        refreshTile()
    }

    private fun refreshTile() {
        val tile = qsTile ?: return
        // Default to inactive state - the app will update this via requestTileUpdate
        tile.state = Tile.STATE_INACTIVE
        tile.label = "HiVPN"
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
