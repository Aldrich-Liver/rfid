class EpcDecodeResult {
  final String companyPrefix;
  final String itemReference;
  final int serial;
  final String gtin14;
  final String ean13;
  final String? upcA;

  const EpcDecodeResult({
    required this.companyPrefix,
    required this.itemReference,
    required this.serial,
    required this.gtin14,
    required this.ean13,
    this.upcA,
  });

  /// Devuelve UPC-A si aplica, si no EAN-13.
  String get displayCode => upcA ?? ean13;
}

// Tabla GS1: partition → (cpBits, cpDigits, irBits, irDigits)
const _partitionTable = [
  (40, 12, 4, 1),
  (37, 11, 7, 2),
  (34, 10, 10, 3),
  (30, 9, 14, 4),
  (27, 8, 17, 5),
  (24, 7, 20, 6),
  (20, 6, 24, 7),
];

/// Decodifica un EPC SGTIN-96 hexadecimal a GTIN-14 / EAN-13 / UPC-A.
/// Lanza [FormatException] si el EPC no es SGTIN-96 válido.
EpcDecodeResult decodeEpc(String epcHex) {
  final cleaned = epcHex.replaceAll(' ', '').toUpperCase();
  if (cleaned.length != 24) {
    throw FormatException('EPC debe tener 24 caracteres hex, tiene ${cleaned.length}');
  }

  // 1. Convertir a BigInt y formatear como 96 bits
  final value = BigInt.parse(cleaned, radix: 16);
  final bits = value.toRadixString(2).padLeft(96, '0');

  // 2. Validar header (bits 0–7 = 0x30 = 00110000)
  final header = int.parse(bits.substring(0, 8), radix: 2);
  if (header != 0x30) {
    throw FormatException('Header inválido: 0x${header.toRadixString(16).toUpperCase()} (se esperaba 0x30)');
  }

  // 3. Partition (bits 11–13)
  final partition = int.parse(bits.substring(11, 14), radix: 2);
  if (partition > 6) throw FormatException('Partition fuera de rango: $partition');
  final (cpBits, cpDigits, irBits, irDigits) = _partitionTable[partition];

  // 4. CompanyPrefix (bits 14 .. 14+cpBits)
  final cpInt = BigInt.parse(bits.substring(14, 14 + cpBits), radix: 2);
  final companyPrefix = cpInt.toString().padLeft(cpDigits, '0');

  // 5. ItemReference (bits 14+cpBits .. 14+cpBits+irBits)
  final irStart = 14 + cpBits;
  final irInt = BigInt.parse(bits.substring(irStart, irStart + irBits), radix: 2);
  final itemReference = irInt.toString().padLeft(irDigits, '0');

  // 6. Serial (últimos 38 bits)
  final serial = int.parse(bits.substring(58), radix: 2);

  // 7. GTIN-14
  final indicator = itemReference[0];
  final resto = itemReference.substring(1);
  final base13 = indicator + companyPrefix + resto; // 13 dígitos
  final check = _gs1CheckDigit(base13);
  final gtin14 = base13 + check.toString();

  // 8. EAN-13 y UPC-A
  final ean13 = gtin14.substring(1);
  final upcA = gtin14.startsWith('00') ? gtin14.substring(2) : null;

  return EpcDecodeResult(
    companyPrefix: companyPrefix,
    itemReference: itemReference,
    serial: serial,
    gtin14: gtin14,
    ean13: ean13,
    upcA: upcA,
  );
}

int _gs1CheckDigit(String base13) {
  final reversed = base13.split('').reversed.toList();
  int sum = 0;
  for (int i = 0; i < reversed.length; i++) {
    final digit = int.parse(reversed[i]);
    sum += i.isEven ? digit * 3 : digit;
  }
  return (10 - (sum % 10)) % 10;
}
