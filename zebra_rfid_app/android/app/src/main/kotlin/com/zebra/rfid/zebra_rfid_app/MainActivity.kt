package com.zebra.rfid.zebra_rfid_app

import android.content.Intent
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

private const val METHOD_CHANNEL = "com.zebra.rfid/reader"
private const val EVENT_CHANNEL  = "com.zebra.rfid/tags"

class MainActivity : FlutterActivity() {

    private var tagEventSink: EventChannel.EventSink? = null
    private var rfidManager: ZebraRfidManager? = null
    private var methodChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Tag event stream — pushes tag reads to Flutter
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    tagEventSink = events
                    rfidManager = ZebraRfidManager(applicationContext, tagEventSink, methodChannel)
                }
                override fun onCancel(arguments: Any?) {
                    tagEventSink = null
                    rfidManager = null
                }
            })

        // Method channel — commands from Flutter to the reader
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL)
        methodChannel!!.setMethodCallHandler { call, result ->
                val manager = rfidManager
                when (call.method) {
                    "connect"       -> manager?.connect(result)
                        ?: result.error("NOT_INITIALIZED", "Subscribe to tag stream first", null)
                    "disconnect"    -> manager?.disconnect(result)
                        ?: result.error("NOT_INITIALIZED", "Subscribe to tag stream first", null)
                    "startInventory" -> manager?.startInventory(result)
                        ?: result.error("NOT_INITIALIZED", "Subscribe to tag stream first", null)
                    "stopInventory" -> manager?.stopInventory(result)
                        ?: result.error("NOT_INITIALIZED", "Subscribe to tag stream first", null)
                    "isConnected"   -> manager?.getConnectionStatus(result)
                        ?: result.success(false)
                    "getReaderInfo" -> manager?.getReaderInfo(result)
                        ?: result.error("NOT_CONNECTED", "Reader not connected", null)
                    "openBluetoothSettings" -> {
                        startActivity(Intent(Settings.ACTION_BLUETOOTH_SETTINGS))
                        result.success(null)
                    }
                    else            -> result.notImplemented()
                }
            }
    }
}
