package com.example.hivpn

import android.content.Intent
import android.net.VpnService
import android.os.Bundle
import android.os.SystemClock
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.example.hivpn.vpn.HiVpnTileService
import org.json.JSONObject
import id.laskarmedia.openvpn_flutter.OpenVPNFlutterPlugin

class MainActivity : FlutterActivity() {
    private val channelName = "com.example.vpn/VpnChannel"
    private val prepareRequestCode = 1001
    private var prepareResult: MethodChannel.Result? = null
    private var pendingExtendIntent = false
    private lateinit var methodChannel: MethodChannel

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleIntentAction(intent)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "prepare" -> handlePrepare(result)
                "getInstalledApps" -> result.success(fetchInstalledApps())
                "updateQuickTile" -> {
                    HiVpnTileService.requestTileUpdate(this)
                    result.success(null)
                }
                "elapsedRealtime" -> result.success(SystemClock.elapsedRealtime())
                else -> result.notImplemented()
            }
        }

        if (pendingExtendIntent) {
            methodChannel.invokeMethod("notifyIntentAction", ACTION_SHOW_EXTEND_AD)
            dispatchExtendRequest()
        } else {
            handleIntentAction(intent)
        }
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
        // OpenVPN permission handler
        OpenVPNFlutterPlugin.connectWhileGranted(requestCode == 24 && resultCode == RESULT_OK)

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

    private fun handleIntentAction(intent: Intent?) {
        if (intent == null) return
        val action = intent.action ?: return

        if (!::methodChannel.isInitialized) {
            if (action == ACTION_SHOW_EXTEND_AD) {
                pendingExtendIntent = true
            }
            return
        }

        methodChannel.invokeMethod("notifyIntentAction", action)

        if (action == ACTION_SHOW_EXTEND_AD) {
            dispatchExtendRequest()
        }
    }

    private fun dispatchExtendRequest() {
        if (::methodChannel.isInitialized) {
            methodChannel.invokeMethod("showExtendAd", null)
            pendingExtendIntent = false
        } else {
            pendingExtendIntent = true
        }
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

    companion object {
        const val ACTION_SHOW_EXTEND_AD = "com.example.hivpn.action.SHOW_EXTEND_AD"
    }
}
