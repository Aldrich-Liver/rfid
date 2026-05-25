import Flutter
import UIKit

class ZebraRfidPlugin: NSObject, FlutterPlugin, FlutterStreamHandler, srfidISdkApiDelegate {

    private var rfidApi: (NSObjectProtocol & srfidISdkApi)!
    private var eventSink: FlutterEventSink?
    private var connectedReaderId: Int32 = -1
    private var connectedReaderName: String = ""
    private var asciiReady = false
    private var pendingConnectResult: FlutterResult?
    private var pollTimer: Timer?
    private var inventoryActive = false  // true mientras Flutter espera que el inventario corra
    private var inventoryGeneration: Int = 0  // se incrementa con cada startInventory para identificar sesiones
    private var methodChannel: FlutterMethodChannel?

    // MARK: - Registration

    static func register(with registrar: FlutterPluginRegistrar) {
        let methodChannel = FlutterMethodChannel(
            name: "com.zebra.rfid/reader",
            binaryMessenger: registrar.messenger()
        )
        let eventChannel = FlutterEventChannel(
            name: "com.zebra.rfid/tags",
            binaryMessenger: registrar.messenger()
        )
        let instance = ZebraRfidPlugin()
        instance.methodChannel = methodChannel
        registrar.addMethodCallDelegate(instance, channel: methodChannel)
        eventChannel.setStreamHandler(instance)
        instance.initSDK()
    }

    /// Envía un log al lado Flutter para que aparezca en la debug console de VSCode
    private func log(_ message: String) {
        DispatchQueue.main.async { [weak self] in
            self?.methodChannel?.invokeMethod("nativeLog", arguments: "[Zebra iOS] \(message)")
        }
    }

    // MARK: - SDK init

    private func initSDK() {
        rfidApi = srfidSdkFactory.createRfidSdkApiInstance()
        rfidApi.srfidSetDelegate(self)
        rfidApi.srfidSetOperationalMode(Int32(SRFID_OPMODE_ALL))

        let eventMask = Int32(
            SRFID_EVENT_MASK_READ |
            SRFID_EVENT_MASK_STATUS |
            SRFID_EVENT_MASK_TRIGGER |
            SRFID_EVENT_MASK_BATTERY |
            SRFID_EVENT_MASK_STATUS_OPERENDSUMMARY
        )
        rfidApi.srfidSubsribe(forEvents: eventMask)
        rfidApi.srfidEnableAvailableReadersDetection(true)
        rfidApi.srfidEnableAutomaticSessionReestablishment(true)
    }

    // MARK: - FlutterPlugin

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "connect":
            connectReader(result: result)
        case "disconnect":
            disconnectReader(result: result)
        case "startInventory":
            startInventory(result: result)
        case "stopInventory":
            stopInventory(result: result)
        case "isConnected":
            result(connectedReaderId != -1)
        case "getReaderInfo":
            getReaderInfo(result: result)
        case "openBluetoothSettings":
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - FlutterStreamHandler

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }

    // MARK: - Reader commands

    private func connectReader(result: @escaping FlutterResult) {
        // Verificar si ya hay sesión activa con ASCII lista
        if connectedReaderId != -1 && asciiReady {
            result(connectedReaderName)
            return
        }
        // Sesión activa pero sin ASCII aún — establecerla ahora
        if let reader = firstActiveReader() {
            connectedReaderId = reader.getReaderID()
            connectedReaderName = reader.getReaderName() ?? "Zebra Reader"
            let ascii = rfidApi.srfidEstablishAsciiConnection(connectedReaderId)
            if ascii == SRFID_RESULT_SUCCESS {
                asciiReady = true
                result(connectedReaderName)
                return
            }
        }

        // Iniciar intento de conexión con lector disponible
        var available: NSMutableArray? = NSMutableArray()
        rfidApi.srfidGetAvailableReadersList(&available)
        if let readers = available, readers.count > 0,
           let reader = readers.firstObject as? srfidReaderInfo {
            rfidApi.srfidEstablishCommunicationSession(reader.getReaderID())
        }

        // Polling cada 1s hasta 30s: espera sesión BT + ASCII connection
        pendingConnectResult = result
        var attempts = 0
        pollTimer?.invalidate()
        pollTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else { timer.invalidate(); return }
            attempts += 1

            // Paso 1: sesión BT activa
            guard let reader = self.firstActiveReader() else {
                // Reintentar conexión con lector disponible
                var avail: NSMutableArray? = NSMutableArray()
                self.rfidApi.srfidGetAvailableReadersList(&avail)
                if let readers = avail, readers.count > 0,
                   let r = readers.firstObject as? srfidReaderInfo {
                    self.rfidApi.srfidEstablishCommunicationSession(r.getReaderID())
                }
                if attempts >= 30 { self.failPending() }
                return
            }

            self.connectedReaderId = reader.getReaderID()
            self.connectedReaderName = reader.getReaderName() ?? "Zebra Reader"

            // Paso 2: ASCII connection (requerida para inventario e info)
            if !self.asciiReady {
                let ascii = self.rfidApi.srfidEstablishAsciiConnection(self.connectedReaderId)
                if ascii == SRFID_RESULT_SUCCESS {
                    self.asciiReady = true
                } else if attempts >= 30 {
                    self.failPending()
                    return
                } else {
                    return // seguir esperando
                }
            }

            // Listo: sesión BT + ASCII establecidas
            timer.invalidate()
            self.pollTimer = nil
            let pending = self.pendingConnectResult
            self.pendingConnectResult = nil
            pending?(self.connectedReaderName)
        }
    }

    private func failPending() {
        pollTimer?.invalidate()
        pollTimer = nil
        let pending = pendingConnectResult
        pendingConnectResult = nil
        pending?(FlutterError(
            code: "NO_READER",
            message: "No se pudo conectar al lector Zebra. Verifica que esté encendido y emparejado.",
            details: nil
        ))
    }

    private func firstActiveReader() -> srfidReaderInfo? {
        var active: NSMutableArray? = NSMutableArray()
        rfidApi.srfidGetActiveReadersList(&active)
        return active?.firstObject as? srfidReaderInfo
    }

    private func disconnectReader(result: @escaping FlutterResult) {
        pollTimer?.invalidate()
        pollTimer = nil
        pendingConnectResult = nil
        if connectedReaderId != -1 {
            rfidApi.srfidTerminateCommunicationSession(connectedReaderId)
            connectedReaderId = -1
            connectedReaderName = ""
            asciiReady = false
        }
        result(nil)
    }

    private func getReaderInfo(result: @escaping FlutterResult) {
        guard connectedReaderId != -1 else {
            result(FlutterError(code: "NOT_CONNECTED", message: "No hay lector conectado", details: nil))
            return
        }

        var model = ""
        var serial = ""
        var firmware = ""

        var caps: srfidReaderCapabilitiesInfo? = srfidReaderCapabilitiesInfo()
        var statusMsg: NSString?
        if rfidApi.srfidGetReaderCapabilitiesInfo(connectedReaderId,
                                                   aReaderCapabilitiesInfo: &caps,
                                                   aStatusMessage: &statusMsg) == SRFID_RESULT_SUCCESS,
           let c = caps {
            model = c.getModel() ?? ""
            serial = c.getSerialNumber() ?? ""
        }

        var versionInfo: srfidReaderVersionInfo? = srfidReaderVersionInfo()
        if rfidApi.srfidGetReaderVersionInfo(connectedReaderId,
                                              aReaderVersionInfo: &versionInfo,
                                              aStatusMessage: &statusMsg) == SRFID_RESULT_SUCCESS,
           let v = versionInfo {
            firmware = v.getDeviceVersion() ?? ""
        }

        result([
            "name": connectedReaderName,
            "model": model,
            "firmware": firmware,
            "numAntennas": 1,
            "serialNumber": serial,
            "batteryLevel": -1,
            "isCharging": false
        ])
    }

    private func startInventory(result: @escaping FlutterResult) {
        log("startInventory — readerId=\(connectedReaderId) asciiReady=\(asciiReady) sink=\(eventSink != nil)")
        guard connectedReaderId != -1 else {
            result(FlutterError(code: "NOT_CONNECTED", message: "No hay lector conectado", details: nil))
            return
        }

        // Re-establecer ASCII si no está listo (puede caerse sin notificación)
        if !asciiReady {
            let ascii = rfidApi.srfidEstablishAsciiConnection(connectedReaderId)
            if ascii == SRFID_RESULT_SUCCESS {
                asciiReady = true
            } else {
                result(FlutterError(code: "ASCII_ERROR",
                    message: "Sin conexión ASCII con el lector. Desconecta y vuelve a conectar.",
                    details: nil))
                return
            }
        }

        // Siempre detener cualquier sesión previa antes de iniciar una nueva.
        // Esto garantiza que el lector esté en estado limpio.
        rfidApi.srfidStopInventory(connectedReaderId, aStatusMessage: nil)
        inventoryActive = false

        // Incrementar generación para invalidar cualquier OPERATION_END_SUMMARY previo
        inventoryGeneration += 1
        let currentGeneration = inventoryGeneration

        // Esperar 150ms para que el lector procese el stop completamente
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
            guard let self = self else { return }
            // Verificar que no se haya llamado otro start/stop mientras esperábamos
            guard self.inventoryGeneration == currentGeneration else {
                result(FlutterError(code: "CANCELLED", message: "Operación cancelada", details: nil))
                return
            }
            guard self.connectedReaderId != -1 else {
                result(FlutterError(code: "NOT_CONNECTED", message: "Lector desconectado", details: nil))
                return
            }

            self.performStartInventory(result: result, generation: currentGeneration)
        }
    }

    private func performStartInventory(result: @escaping FlutterResult, generation: Int) {
        let reportConfig = srfidReportConfig()
        reportConfig.setIncPC(false)
        reportConfig.setIncPhase(false)
        reportConfig.setIncChannelIndex(false)
        reportConfig.setIncRSSI(true)
        reportConfig.setIncTagSeenCount(true)
        reportConfig.setIncFirstSeenTime(true)
        reportConfig.setIncLastSeenTime(true)

        let accessConfig = srfidAccessConfig()
        accessConfig.setDoSelect(false)

        var statusMsg: NSString?
        var status = rfidApi.srfidStartInventory(
            connectedReaderId,
            aMemoryBank: SRFID_MEMORYBANK_NONE,
            aReportConfig: reportConfig,
            aAccessConfig: accessConfig,
            aStatusMessage: &statusMsg
        )

        if status == SRFID_RESULT_SUCCESS {
            inventoryActive = true
            result(nil)
            return
        }

        // Inventario ya activo (no debería pasar tras el stop previo): detener y reintentar
        if status == SRFID_RESULT_RESPONSE_ERROR {
            rfidApi.srfidStopInventory(connectedReaderId, aStatusMessage: nil)
            // Segundo intento inmediato
            status = rfidApi.srfidStartInventory(
                connectedReaderId,
                aMemoryBank: SRFID_MEMORYBANK_NONE,
                aReportConfig: reportConfig,
                aAccessConfig: accessConfig,
                aStatusMessage: &statusMsg
            )
            if status == SRFID_RESULT_SUCCESS { inventoryActive = true; result(nil); return }
        }

        // ASCII caído (código 9): re-establecer y reintentar
        if status == SRFID_RESULT_ASCII_CONNECTION_REQUIRED {
            asciiReady = false
            let ascii = rfidApi.srfidEstablishAsciiConnection(connectedReaderId)
            if ascii == SRFID_RESULT_SUCCESS {
                asciiReady = true
                status = rfidApi.srfidStartInventory(
                    connectedReaderId,
                    aMemoryBank: SRFID_MEMORYBANK_NONE,
                    aReportConfig: reportConfig,
                    aAccessConfig: accessConfig,
                    aStatusMessage: &statusMsg
                )
                if status == SRFID_RESULT_SUCCESS { inventoryActive = true; result(nil); return }
            }
        }

        result(FlutterError(
            code: "INVENTORY_ERROR",
            message: "No se pudo iniciar el inventario (cód. \(status)). Desconecta y vuelve a conectar.",
            details: nil
        ))
    }

    private func stopInventory(result: @escaping FlutterResult) {
        inventoryActive = false
        inventoryGeneration += 1  // Invalidar cualquier start pendiente (del asyncAfter)
        guard connectedReaderId != -1 else { result(nil); return }
        var statusMsg: NSString?
        rfidApi.srfidStopInventory(connectedReaderId, aStatusMessage: &statusMsg)
        result(nil)
    }

    // MARK: - srfidISdkApiDelegate

    func srfidEventReaderAppeared(_ availableReader: srfidReaderInfo!) {
        guard pendingConnectResult != nil else { return }
        rfidApi.srfidEstablishCommunicationSession(availableReader.getReaderID())
    }

    func srfidEventReaderDisappeared(_ readerID: Int32) {
        if readerID == connectedReaderId {
            connectedReaderId = -1
            connectedReaderName = ""
        }
    }

    func srfidEventCommunicationSessionEstablished(_ activeReader: srfidReaderInfo!) {
        connectedReaderId = activeReader.getReaderID()
        connectedReaderName = activeReader.getReaderName() ?? "Zebra Reader"
        // El polling establecerá la ASCII connection y resolverá el resultado
    }

    func srfidEventCommunicationSessionTerminated(_ readerID: Int32) {
        if readerID == connectedReaderId {
            connectedReaderId = -1
            connectedReaderName = ""
            asciiReady = false
        }
    }

    func srfidEventReadNotify(_ readerID: Int32, aTagData tagData: srfidTagData!) {
        let tagId = tagData?.getTagId() ?? ""
        log("srfidEventReadNotify — epc=\(tagId) sink=\(eventSink != nil)")
        guard let sink = eventSink, !tagId.isEmpty else { return }
        let tag: [String: Any] = [
            "epc": tagId,
            "rssi": Int(tagData.getPeakRSSI()),
            "firstSeen": Int(tagData.getFirstSeenTime()),
            "lastSeen": Int(tagData.getLastSeenTime()),
            "seenCount": Int(tagData.getTagSeenCount())
        ]
        DispatchQueue.main.async { sink([tag]) }
    }

    func srfidEventStatusNotify(_ readerID: Int32, aEvent event: SRFID_EVENT_STATUS, aNotification notificationData: Any!) {
        guard event == SRFID_EVENT_STATUS_OPERATION_END_SUMMARY else { return }
        log("OPERATION_END_SUMMARY — inventoryActive=\(inventoryActive) gen=\(inventoryGeneration)")

        // Solo auto-reiniciar si Flutter espera que el inventario siga corriendo
        guard inventoryActive && connectedReaderId != -1 else { return }

        let reportConfig = srfidReportConfig()
        reportConfig.setIncRSSI(true)
        reportConfig.setIncTagSeenCount(true)
        reportConfig.setIncFirstSeenTime(true)
        reportConfig.setIncLastSeenTime(true)
        let accessConfig = srfidAccessConfig()
        accessConfig.setDoSelect(false)

        var status = rfidApi.srfidStartInventory(
            connectedReaderId,
            aMemoryBank: SRFID_MEMORYBANK_NONE,
            aReportConfig: reportConfig,
            aAccessConfig: accessConfig,
            aStatusMessage: nil
        )
        log("Auto-restart inventory — status=\(status)")

        // Si falla con RESPONSE_ERROR, el lector aún tiene una sesión pendiente.
        // Detener y reintentar inmediatamente para minimizar gap entre rondas.
        if status == SRFID_RESULT_RESPONSE_ERROR {
            rfidApi.srfidStopInventory(connectedReaderId, aStatusMessage: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
                guard let self = self, self.inventoryActive, self.connectedReaderId != -1 else { return }
                let retryStatus = self.rfidApi.srfidStartInventory(
                    self.connectedReaderId,
                    aMemoryBank: SRFID_MEMORYBANK_NONE,
                    aReportConfig: reportConfig,
                    aAccessConfig: accessConfig,
                    aStatusMessage: nil
                )
                self.log("Auto-restart retry — status=\(retryStatus)")
            }
        }
    }
    func srfidEventProximityNotify(_ readerID: Int32, aProximityPercent proximityPercent: Int32) {}
    func srfidEventMultiProximityNotify(_ readerID: Int32, aTagData tagData: srfidTagData!) {}
    func srfidEventTriggerNotify(_ readerID: Int32, aTriggerEvent triggerEvent: SRFID_TRIGGEREVENT) {}
    func srfidEventBatteryNotity(_ readerID: Int32, aBatteryEvent batteryEvent: srfidBatteryEvent!) {}
    func srfidEventWifiScan(_ readerID: Int32, wlanSCanObject wlanScanObject: srfidWlanScanList!) {}
    func srfidEventIOTSatusNotity(_ readerID: Int32, aIOTStatusEvent iotStatusEvent: srfidIOTStatusEvent!) {}
    func srfidEventConnectedInterfaceNotity(_ readerID: Int32, aConnectedInterfaceEvent connectedInterfaceEvent: sfidConnectedInterfaceEvent!) {}
}
