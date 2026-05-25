class ReaderInfo {
  final String name;
  final String model;
  final String firmware;
  final int numAntennas;
  final String serialNumber;
  final int batteryLevel; // 0-100, -1 if unknown
  final bool isCharging;

  const ReaderInfo({
    required this.name,
    required this.model,
    required this.firmware,
    required this.numAntennas,
    required this.serialNumber,
    this.batteryLevel = -1,
    this.isCharging = false,
  });

  factory ReaderInfo.fromMap(Map<Object?, Object?> map) {
    return ReaderInfo(
      name: map['name'] as String? ?? 'Unknown',
      model: map['model'] as String? ?? 'Unknown',
      firmware: map['firmware'] as String? ?? 'Unknown',
      numAntennas: map['numAntennas'] as int? ?? 1,
      serialNumber: map['serialNumber'] as String? ?? 'Unknown',
      batteryLevel: map['batteryLevel'] as int? ?? -1,
      isCharging: map['isCharging'] as bool? ?? false,
    );
  }

  String get batteryText =>
      batteryLevel < 0 ? '--' : '$batteryLevel%';
}
