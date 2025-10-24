package com.example.hivpn.vpn

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.service.quicksettings.Tile
import android.service.quicksettings.TileService

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
            val config = WireGuardService.lastConfig(this)
            if (config.isNotEmpty() && config != "{}") {
                WireGuardService.requestConnect(this, config)
            }
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
