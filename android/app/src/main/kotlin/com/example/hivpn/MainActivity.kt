package com.example.hivpn

import android.content.Intent
import android.net.VpnService
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.example.hivpn.vpn.WireGuardService
import org.json.JSONObject

class MainActivity : FlutterActivity() {
    private val channelName = "com.example.vpn/VpnChannel"
    private val prepareRequestCode = 1001
    private var prepareResult: MethodChannel.Result? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "prepare" -> handlePrepare(result)
                    "connect" -> {
                        val config = JSONObject(call.arguments as Map<*, *>).toString()
                        WireGuardService.requestConnect(this, config)
                        result.success(true)
                    }
                    "disconnect" -> {
                        WireGuardService.requestDisconnect(this)
                        result.success(null)
                    }
                    "isConnected" -> result.success(WireGuardService.isActive())
                    "getTunnelStats" -> result.success(WireGuardService.currentStats())
                    else -> result.notImplemented()
                }
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
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == prepareRequestCode) {
            prepareResult?.success(resultCode == RESULT_OK)
            prepareResult = null
        }
    }
}
