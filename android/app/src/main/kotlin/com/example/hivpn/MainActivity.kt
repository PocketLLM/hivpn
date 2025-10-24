package com.example.hivpn

import android.content.Intent
import android.net.VpnService
import android.os.Bundle
import android.os.SystemClock
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.example.hivpn.vpn.HiVpnTileService
import com.example.hivpn.vpn.WireGuardService
import org.json.JSONObject

class MainActivity : FlutterActivity() {
    private val channelName = "com.example.vpn/VpnChannel"
    private val prepareRequestCode = 1001
    private var prepareResult: MethodChannel.Result? = null
    private var pendingIntentAction: String? = null
    private lateinit var vpnChannel: MethodChannel

    companion object {
        private const val EXTRA_NOTIFICATION_ACTION = "notification_action"
        private const val ACTION_SHOW_EXTEND_AD = "SHOW_EXTEND_AD"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleIntentAction(intent)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        vpnChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
        vpnChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "prepare" -> handlePrepare(result)
                "connect" -> {
                    val config = JSONObject(call.arguments as Map<*, *>).toString()
                    WireGuardService.requestConnect(this, config)
                    HiVpnTileService.requestTileUpdate(this)
                    result.success(true)
                }
                "disconnect" -> {
                    WireGuardService.requestDisconnect(this)
                    HiVpnTileService.requestTileUpdate(this)
                    result.success(null)
                }
                "isConnected" -> result.success(WireGuardService.isActive())
                "getTunnelStats" -> result.success(WireGuardService.currentStats())
                "getInstalledApps" -> result.success(fetchInstalledApps())
                "updateQuickTile" -> {
                    HiVpnTileService.requestTileUpdate(this)
                    result.success(null)
                }
                "elapsedRealtime" -> result.success(SystemClock.elapsedRealtime())
                "extendSession" -> {
                    val args = call.arguments as? Map<*, *>
                    val additionalDuration =
                        (args?.get("additionalDurationMs") as? Number)?.toLong() ?: 0L
                    val ip = args?.get("ip") as? String
                    WireGuardService.extendSession(additionalDuration, ip)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
        deliverPendingIntentAction()
    }

    private fun handlePrepare(result: MethodChannel.Result) {
        val intent = VpnService.prepare(this)
        if (intent != null) {
            prepareResult = result
            startActivityForResult(intent, prepareRequestCode)
        } else {
            result.success(true)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == prepareRequestCode) {
            prepareResult?.success(resultCode == RESULT_OK)
            prepareResult = null
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleIntentAction(intent)
    }

    private fun fetchInstalledApps(): List<Map<String, String>> {
        val pm = packageManager
        val apps = pm.getInstalledApplications(0)
        return apps
            .filter { pm.getLaunchIntentForPackage(it.packageName) != null }
            .map {
                mapOf(
                    "package" to it.packageName,
                    "name" to pm.getApplicationLabel(it).toString(),
                )
            }
            .sortedBy { it["name"] }
    }

    private fun handleIntentAction(intent: Intent?) {
        val action = intent?.getStringExtra(EXTRA_NOTIFICATION_ACTION) ?: intent?.action
        if (action == ACTION_SHOW_EXTEND_AD) {
            if (this::vpnChannel.isInitialized) {
                vpnChannel.invokeMethod("notifyIntentAction", action)
            } else {
                pendingIntentAction = action
            }
        }
    }

    private fun deliverPendingIntentAction() {
        val action = pendingIntentAction ?: return
        if (this::vpnChannel.isInitialized) {
            vpnChannel.invokeMethod("notifyIntentAction", action)
            pendingIntentAction = null
        }
    }
}
