import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/rfid_tag.dart';
import '../models/reader_info.dart';

class ZebraRfidService {
  static const _methodChannel = MethodChannel('com.zebra.rfid/reader');
  static const _eventChannel  = EventChannel('com.zebra.rfid/tags');

  // True on iOS — no native Zebra SDK, use simulated data
  static bool get isMock => defaultTargetPlatform == TargetPlatform.iOS;

  StreamSubscription<dynamic>? _tagSubscription;
  final _tagController = StreamController<List<RfidTag>>.broadcast();

  // Mock state
  Timer? _mockTimer;
  double _mockRssi = -70;
  double _mockRssiTarget = -40;
  String _mockEpc = '300000000000000000000001';
  final _mockRng = math.Random();

  Stream<List<RfidTag>> get tagStream => _tagController.stream;

  // Called by BuscarScreen so the mock emits the searched EPC
  void setMockEpc(String epc) => _mockEpc = epc.toUpperCase();

  // ------------------------------------------------------------------
  // Lifecycle
  // ------------------------------------------------------------------

  void init() {
    if (isMock) return;
    _methodChannel.setMethodCallHandler(_handleNativeCalls);
    _tagSubscription = _eventChannel.receiveBroadcastStream().listen(
      _onTagData,
      onError: _onTagError,
    );
  }

  Future<dynamic> _handleNativeCalls(MethodCall call) async {
    if (call.method == 'nativeLog') {
      debugPrint(call.arguments as String? ?? '');
    }
  }

  void dispose() {
    _mockTimer?.cancel();
    _tagSubscription?.cancel();
    _tagController.close();
  }

  // ------------------------------------------------------------------
  // Commands
  // ------------------------------------------------------------------

  Future<String> connect() async {
    if (isMock) return 'iOS Simulator';
    final name = await _methodChannel.invokeMethod<String>('connect');
    return name ?? 'Unknown reader';
  }

  Future<void> disconnect() async {
    if (isMock) return;
    await _methodChannel.invokeMethod<void>('disconnect');
  }

  Future<void> startInventory() async {
    if (isMock) {
      _mockRssi = -70;
      _mockRssiTarget = -40;
      _mockTimer?.cancel();
      _mockTimer = Timer.periodic(const Duration(milliseconds: 350), (_) {
        // Walk toward target with noise, then occasionally reverse
        _mockRssi += (_mockRssiTarget - _mockRssi) * 0.18 +
            (_mockRng.nextDouble() - 0.5) * 2.5;
        _mockRssi = _mockRssi.clamp(-76.0, -28.0);
        if (_mockRng.nextDouble() < 0.04) {
          _mockRssiTarget = -76 + _mockRng.nextDouble() * 48;
        }
        _tagController.add([
          RfidTag(
            epc: _mockEpc,
            rssi: _mockRssi.round(),
            antenna: 1,
            readAt: DateTime.now(),
          ),
        ]);
      });
      return;
    }
    await _methodChannel.invokeMethod<void>('startInventory');
  }

  Future<void> stopInventory() async {
    if (isMock) {
      _mockTimer?.cancel();
      _mockTimer = null;
      return;
    }
    await _methodChannel.invokeMethod<void>('stopInventory');
  }

  Future<bool> isConnected() async {
    if (isMock) return true;
    return await _methodChannel.invokeMethod<bool>('isConnected') ?? false;
  }

  Future<ReaderInfo> getReaderInfo() async {
    if (isMock) {
      return const ReaderInfo(
        name: 'iOS Simulator',
        model: 'RFD8500',
        firmware: '1.0.0-sim',
        numAntennas: 1,
        serialNumber: 'SIM-001',
        batteryLevel: 85,
      );
    }
    final raw = await _methodChannel.invokeMethod<Map<Object?, Object?>>('getReaderInfo');
    if (raw == null) throw PlatformException(code: 'INFO_ERROR', message: 'No data');
    return ReaderInfo.fromMap(raw);
  }

  Future<void> openBluetoothSettings() async {
    if (isMock) return;
    await _methodChannel.invokeMethod<void>('openBluetoothSettings');
  }

  // ------------------------------------------------------------------
  // Internal
  // ------------------------------------------------------------------

  void _onTagData(dynamic data) {
    if (data is! List) return;
    final tags = data
        .whereType<Map<Object?, Object?>>()
        .map(RfidTag.fromMap)
        .toList();
    _tagController.add(tags);
  }

  void _onTagError(Object error) {
    _tagController.addError(error);
  }
}
