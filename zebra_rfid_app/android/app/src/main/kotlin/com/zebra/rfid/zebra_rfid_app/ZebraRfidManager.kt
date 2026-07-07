package com.zebra.rfid.zebra_rfid_app

import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Handler
import android.os.Looper
import android.util.Log
import com.zebra.rfid.api3.*
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

private const val TAG = "ZebraRfidManager"

class ZebraRfidManager(
    private val context: Context,
    private val tagEventSink: EventChannel.EventSink?,
    private val methodChannel: MethodChannel?,
) : RfidEventsListener {

    private var readers: Readers? = null
    private var reader: RFIDReader? = null
    private var isConnected = false
    // EventSink must be called on the main thread
    private val mainHandler = Handler(Looper.getMainLooper())

    /** Envía un log al lado Flutter para que aparezca en la debug console de VSCode */
    private fun log(message: String) {
        Log.i(TAG, message)
        mainHandler.post { methodChannel?.invokeMethod("nativeLog", "[Zebra Android] $message") }
    }

    // ------------------------------------------------------------------
    // Connection
    // ------------------------------------------------------------------

    fun connect(result: MethodChannel.Result) {
        try {
            // Try BLUETOOTH first, then fall back to other transports
            readers = tryCreateReaders()
            if (readers == null) {
                result.error("NO_READER", "No se pudo inicializar el SDK de transporte", null)
                return
            }

            val availableReaders = readers!!.GetAvailableRFIDReaderList()
            if (availableReaders.isNullOrEmpty()) {
                // Try switching transport
                try {
                    readers!!.setTransport(ENUM_TRANSPORT.SERVICE_SERIAL)
                    val serial = readers!!.GetAvailableRFIDReaderList()
                    if (!serial.isNullOrEmpty()) {
                        connectToReader(serial[0], result)
                        return
                    }
                } catch (_: Exception) {}
                result.error("NO_READER", "No RFID readers found", null)
                return
            }

            connectToReader(availableReaders[0], result)
        } catch (e: InvalidUsageException) {
            Log.e(TAG, "connect InvalidUsage: ${e.info}")
            result.error("CONNECT_ERROR", e.info, null)
        } catch (e: OperationFailureException) {
            Log.e(TAG, "connect OperationFailure: ${e.results}")
            result.error("CONNECT_ERROR", e.results.toString(), null)
        } catch (e: Exception) {
            Log.e(TAG, "connect Exception: ${e.message}")
            result.error("CONNECT_ERROR", e.message ?: "Error desconocido", null)
        }
    }

    private fun tryCreateReaders(): Readers? {
        // Try transports in order of likelihood for handheld sleds
        val transports = listOf(
            ENUM_TRANSPORT.BLUETOOTH,
            ENUM_TRANSPORT.SERVICE_SERIAL,
            ENUM_TRANSPORT.SERVICE_USB,
        )
        for (transport in transports) {
            try {
                log("Trying transport: $transport")
                return Readers(context, transport)
            } catch (e: Exception) {
                log("Transport $transport failed: ${e.message}")
            }
        }
        return null
    }

    private fun connectToReader(readerDevice: ReaderDevice, result: MethodChannel.Result) {
        reader = readerDevice.getRFIDReader()
        reader!!.connect()
        configureReader()
        isConnected = true
        log("Connected to ${readerDevice.getName()}")
        result.success(readerDevice.getName())
    }

    fun disconnect(result: MethodChannel.Result) {
        try {
            if (reader != null) {
                reader!!.Events.removeEventsListener(this)
                reader!!.disconnect()
            }
            readers?.Dispose()
            isConnected = false
            result.success(null)
        } catch (e: Exception) {
            result.error("DISCONNECT_ERROR", e.message, null)
        }
    }

    // ------------------------------------------------------------------
    // Reader info
    // ------------------------------------------------------------------

    fun getReaderInfo(result: MethodChannel.Result) {
        if (!isConnected || reader == null) {
            result.error("NOT_CONNECTED", "Reader not connected", null)
            return
        }
        try {
            val caps = reader!!.ReaderCapabilities
            val battery = getDeviceBatteryInfo()

            // SDK typo: getFirwareVersion (missing 'm') is the real method name
            val name = safeGet { caps.getScannerName() }
                ?: safeGet { reader!!.getHostName() }
                ?: "Unknown"
            val model    = safeGet { caps.getModelName() } ?: "Unknown"
            val firmware = safeGet { caps.getFirwareVersion() } ?: "Unknown"
            val numAntennas = safeGetInt { caps.getNumAntennaSupported() } ?: 1
            val serial = safeGet { caps.getSerialNumber() } ?: "Unknown"

            result.success(
                mapOf(
                    "name"         to name,
                    "model"        to model,
                    "firmware"     to firmware,
                    "numAntennas"  to numAntennas,
                    "serialNumber" to serial,
                    "batteryLevel" to battery.first,
                    "isCharging"   to battery.second,
                )
            )
        } catch (e: InvalidUsageException) {
            result.error("INFO_ERROR", e.info, null)
        } catch (e: Exception) {
            result.error("INFO_ERROR", e.message, null)
        }
    }

    private fun safeGet(block: () -> String?): String? = try { block() } catch (_: Exception) { null }
    private fun safeGetInt(block: () -> Int): Int? = try { block() } catch (_: Exception) { null }

    // Returns (level 0-100, isCharging)
    private fun getDeviceBatteryInfo(): Pair<Int, Boolean> {
        return try {
            val intent = context.registerReceiver(
                null,
                IntentFilter(Intent.ACTION_BATTERY_CHANGED)
            )
            val level = intent?.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) ?: -1
            val scale = intent?.getIntExtra(BatteryManager.EXTRA_SCALE, 100) ?: 100
            val status = intent?.getIntExtra(BatteryManager.EXTRA_STATUS, -1) ?: -1
            val isCharging = status == BatteryManager.BATTERY_STATUS_CHARGING ||
                    status == BatteryManager.BATTERY_STATUS_FULL
            val pct = if (scale > 0) (level * 100 / scale) else -1
            Pair(pct, isCharging)
        } catch (e: Exception) {
            Pair(-1, false)
        }
    }

    // ------------------------------------------------------------------
    // Inventory
    // ------------------------------------------------------------------

    fun startInventory(result: MethodChannel.Result) {
        if (!isConnected || reader == null) {
            result.error("NOT_CONNECTED", "Reader not connected", null)
            return
        }
        try {
            // Siempre detener cualquier sesión previa para garantizar estado limpio.
            log("startInventory — stopping previous session...")
            try { reader!!.Actions.Inventory.stop() } catch (_: Exception) {}

            // Purgar tags previos del buffer interno del SDK
            try { reader!!.Actions.purgeTags() } catch (_: Exception) {}

            log("startInventory — calling perform()...")
            reader!!.Actions.Inventory.perform()
            log("startInventory — SUCCESS")
            result.success(null)
        } catch (e: InvalidUsageException) {
            log("startInventory — InvalidUsage: ${e.info}")
            result.error("INVENTORY_ERROR", e.info, null)
        } catch (e: OperationFailureException) {
            log("startInventory — OperationFailure: ${e.results}, retrying...")
            // Si falla porque ya está corriendo, intentar stop + start
            try {
                reader!!.Actions.Inventory.stop()
                reader!!.Actions.purgeTags()
                reader!!.Actions.Inventory.perform()
                log("startInventory — retry SUCCESS")
                result.success(null)
            } catch (e2: Exception) {
                log("startInventory — retry FAILED: ${e2.message}")
                result.error("INVENTORY_ERROR", e.results.toString(), null)
            }
        }
    }

    fun stopInventory(result: MethodChannel.Result) {
        if (!isConnected || reader == null) {
            result.error("NOT_CONNECTED", "Reader not connected", null)
            return
        }
        try {
            reader!!.Actions.Inventory.stop()
            result.success(null)
        } catch (e: InvalidUsageException) {
            result.error("INVENTORY_ERROR", e.info, null)
        } catch (e: OperationFailureException) {
            result.error("INVENTORY_ERROR", e.results.toString(), null)
        }
    }

    fun getConnectionStatus(result: MethodChannel.Result) {
        result.success(isConnected)
    }

    // ------------------------------------------------------------------
    // Write EPC
    // ------------------------------------------------------------------

    fun writeTag(targetEpc: String, newEpc: String, result: MethodChannel.Result) {
        if (!isConnected || reader == null) {
            result.error("NOT_CONNECTED", "Reader not connected", null)
            return
        }

        val cleanTarget = targetEpc.trim().uppercase()
        val cleanNewEpc = newEpc.trim().uppercase()

        if (cleanTarget.isEmpty()) {
            result.error("NO_TARGET", "No se detectó ninguna etiqueta para grabar", null)
            return
        }
        if (cleanNewEpc.isEmpty() || cleanNewEpc.length % 4 != 0 || !cleanNewEpc.matches(Regex("^[0-9A-F]+$"))) {
            result.error("INVALID_EPC", "El nuevo EPC debe ser hexadecimal con longitud múltiplo de 4", null)
            return
        }

        try {
            log("writeTag — target=$cleanTarget new=$cleanNewEpc")
            val tagAccess = reader!!.Actions.TagAccess
            val accessParams = tagAccess.WriteAccessParams()
            accessParams.setOffset(2) // salta CRC + PC, escribe directo sobre el banco EPC
            accessParams.setWriteData(cleanNewEpc)
            accessParams.setWriteDataLength(cleanNewEpc.length / 4)

            tagAccess.writeWait(cleanTarget, accessParams, null, null)
            log("writeTag — SUCCESS")
            result.success(null)
        } catch (e: InvalidUsageException) {
            log("writeTag — InvalidUsage: ${e.info}")
            result.error("WRITE_ERROR", e.info, null)
        } catch (e: OperationFailureException) {
            log("writeTag — OperationFailure: ${e.results}")
            result.error("WRITE_ERROR", e.results.toString(), null)
        } catch (e: Exception) {
            log("writeTag — Exception: ${e.message}")
            result.error("WRITE_ERROR", e.message ?: "Error desconocido al grabar", null)
        }
    }

    // ------------------------------------------------------------------
    // Reader configuration
    // ------------------------------------------------------------------

    private fun configureReader() {
        val rfidReader = reader ?: return
        rfidReader.Events.addEventsListener(this)
        rfidReader.Events.setHandheldEvent(true)
        rfidReader.Events.setTagReadEvent(true)
        rfidReader.Events.setAttachTagDataWithReadEvent(false)

        val triggerInfo = TriggerInfo()
        triggerInfo.StartTrigger.setTriggerType(START_TRIGGER_TYPE.START_TRIGGER_TYPE_IMMEDIATE)
        triggerInfo.StopTrigger.setTriggerType(STOP_TRIGGER_TYPE.STOP_TRIGGER_TYPE_IMMEDIATE)

        rfidReader.Config.setTriggerMode(ENUM_TRIGGER_MODE.RFID_MODE, true)
        rfidReader.Config.setStartTrigger(triggerInfo.StartTrigger)
        rfidReader.Config.setStopTrigger(triggerInfo.StopTrigger)
    }

    // ------------------------------------------------------------------
    // RfidEventsListener callbacks
    // ------------------------------------------------------------------

    override fun eventReadNotify(e: RfidReadEvents?) {
        val rfidReader = reader ?: return
        val tags = rfidReader.Actions.getReadTags(100) ?: return

        val tagList = tags.map { tag ->
            mapOf(
                "epc"     to (tag.getTagID() ?: ""),
                "rssi"    to tag.getPeakRSSI().toInt(),
                "antenna" to tag.getAntennaID().toInt(),
            )
        }
        if (tagList.isNotEmpty()) {
            // EventSink MUST be called on the main thread
            mainHandler.post { tagEventSink?.success(tagList) }
        }
    }

    override fun eventStatusNotify(rfidStatusEvents: RfidStatusEvents?) {
        val statusType = rfidStatusEvents?.StatusEventData?.getStatusEventType() ?: return
        log("Status event: $statusType")

        if (statusType == STATUS_EVENT_TYPE.DISCONNECTION_EVENT) {
            isConnected = false
            mainHandler.post {
                tagEventSink?.error("READER_DISCONNECTED", "Reader disconnected unexpectedly", null)
            }
        }
    }
}
