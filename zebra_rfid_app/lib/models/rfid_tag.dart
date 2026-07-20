/// Estado de decodificación de un EPC.
enum EpcStatus {
  /// Header 0x30 y decodificación SGTIN-96 exitosa.
  decodificado,
  /// Header distinto de 0x30 — chip no encodeado con estándar GS1.
  sinEncodear,
  /// Header 0x30 pero la decodificación falló, o formato no reconocido que sí decodifica.
  desconocido,
}

class RfidTag {
  final String epc;
  final int rssi;
  final int antenna;
  final DateTime readAt;

  const RfidTag({
    required this.epc,
    required this.rssi,
    required this.antenna,
    required this.readAt,
  });

  factory RfidTag.fromMap(Map<Object?, Object?> map) {
    return RfidTag(
      epc: map['epc'] as String? ?? '',
      rssi: map['rssi'] as int? ?? 0,
      antenna: map['antenna'] as int? ?? 0,
      readAt: DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is RfidTag && epc == other.epc;

  @override
  int get hashCode => epc.hashCode;
}
