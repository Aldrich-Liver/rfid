import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/rfid_tag.dart';
import '../models/reader_info.dart';

class ZebraRfidService {
  static const _methodChannel = MethodChannel('com.zebra.rfid/reader');
  static const _eventChannel  = EventChannel('com.zebra.rfid/tags');

  StreamSubscription<dynamic>? _tagSubscription;
  final _tagController = StreamController<List<RfidTag>>.broadcast();

  Stream<List<RfidTag>> get tagStream => _tagController.stream;

  // ------------------------------------------------------------------
  // Lifecycle
  // ------------------------------------------------------------------

  void init() {
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
    _tagSubscription?.cancel();
    _tagController.close();
  }

  // ------------------------------------------------------------------
  // Commands
  // ------------------------------------------------------------------

  Future<String> connect() async {
    final name = await _methodChannel.invokeMethod<String>('connect');
    return name ?? 'Unknown reader';
  }

  Future<void> disconnect() async {
    await _methodChannel.invokeMethod<void>('disconnect');
  }

  Future<void> startInventory() async {
    await _methodChannel.invokeMethod<void>('startInventory');
  }

  Future<void> stopInventory() async {
    await _methodChannel.invokeMethod<void>('stopInventory');
  }

  Future<bool> isConnected() async {
    return await _methodChannel.invokeMethod<bool>('isConnected') ?? false;
  }

  Future<ReaderInfo> getReaderInfo() async {
    final raw = await _methodChannel.invokeMethod<Map<Object?, Object?>>('getReaderInfo');
    if (raw == null) throw PlatformException(code: 'INFO_ERROR', message: 'No data');
    return ReaderInfo.fromMap(raw);
  }

  Future<void> openBluetoothSettings() async {
    await _methodChannel.invokeMethod<void>('openBluetoothSettings');
  }

  /// Escribe un nuevo EPC sobre la etiqueta cuyo EPC actual es [targetEpc].
  Future<void> writeTag({required String targetEpc, required String newEpc}) async {
    await _methodChannel.invokeMethod<void>('writeTag', {
      'targetEpc': targetEpc,
      'newEpc': newEpc,
    });
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
