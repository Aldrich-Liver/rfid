/// Tipo de EPC decodificado.
enum EpcType { sgtin96, grai96, sscc96 }

class EpcDecodeResult {
  final EpcType type;
  final String companyPrefix;
  final String itemReference;
  final int serial;
  final String gtin14;
  final String ean13;
  final String? upcA;

  const EpcDecodeResult({
    this.type = EpcType.sgtin96,
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

/// Resultado de decodificación de etiquetas de contenedor (GRAI-96 / SSCC-96).
class LabelDecodeResult {
  final EpcType type;
  final String letter;
  final String numericPart;

  const LabelDecodeResult({
    required this.type,
    required this.letter,
    required this.numericPart,
  });

  String get displayLabel => '$letter$numericPart';
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

// ─────────────────────────────────────────────────────────────────────────────
// GRAI-96 / SSCC-96 — Decodificación de etiquetas de contenedor
// ─────────────────────────────────────────────────────────────────────────────

/// Mapeo Asset Type → letra para GRAI-96 (específico de la empresa).
const _graiLetterMap = <int, String>{
  1: 'A',
  6: 'V',
  8: 'F',
};

/// Mapeo extension digit → letra para SSCC-96 (específico de la empresa).
const _ssccLetterMap = <int, String>{
  1: 'G',
};

/// Detecta el tipo de EPC por su header (primer byte).
/// Retorna null si no es un formato reconocido.
EpcType? detectEpcType(String epcHex) {
  final cleaned = epcHex.replaceAll(' ', '').toUpperCase();
  if (cleaned.length != 24) return null;
  final headerByte = int.parse(cleaned.substring(0, 2), radix: 16);
  switch (headerByte) {
    case 0x30:
      return EpcType.sgtin96;
    case 0x33:
      return EpcType.grai96;
    case 0x31:
      return EpcType.sscc96;
    default:
      return null;
  }
}

/// Decodifica un EPC GRAI-96 (header 0x33) a etiqueta de contenedor.
LabelDecodeResult decodeGrai96(String epcHex) {
  final cleaned = epcHex.replaceAll(' ', '').toUpperCase();
  if (cleaned.length != 24) {
    throw FormatException('EPC debe tener 24 caracteres hex, tiene ${cleaned.length}');
  }

  final value = BigInt.parse(cleaned, radix: 16);
  final bits = value.toRadixString(2).padLeft(96, '0');

  // Header
  final header = int.parse(bits.substring(0, 8), radix: 2);
  if (header != 0x33) {
    throw FormatException('Header inválido para GRAI-96: 0x${header.toRadixString(16).toUpperCase()}');
  }

  // Partition (bits 11-13)
  final partition = int.parse(bits.substring(11, 14), radix: 2);
  if (partition > 6) throw FormatException('Partition fuera de rango: $partition');
  final (cpBits, _, _, _) = _partitionTable[partition];

  // Asset Type (bits 14+cpBits .. 58, 20 bits para partition 5)
  final atStart = 14 + cpBits;
  final atEnd = 58; // CP + AT = 44 bits → AT termina en bit 58
  final atVal = int.parse(bits.substring(atStart, atEnd), radix: 2);

  // Serial (bits 58-95, 38 bits)
  final serial = int.parse(bits.substring(58, 96), radix: 2);

  // Numeric part: últimos 8 dígitos del serial
  final numericPart = (serial % 100000000).toString().padLeft(8, '0');

  // Letra desde Asset Type
  final letter = _graiLetterMap[atVal] ?? '?';

  return LabelDecodeResult(type: EpcType.grai96, letter: letter, numericPart: numericPart);
}

/// Decodifica un EPC SSCC-96 (header 0x31) a etiqueta de contenedor.
LabelDecodeResult decodeSscc96(String epcHex) {
  final cleaned = epcHex.replaceAll(' ', '').toUpperCase();
  if (cleaned.length != 24) {
    throw FormatException('EPC debe tener 24 caracteres hex, tiene ${cleaned.length}');
  }

  final value = BigInt.parse(cleaned, radix: 16);
  final bits = value.toRadixString(2).padLeft(96, '0');

  // Header
  final header = int.parse(bits.substring(0, 8), radix: 2);
  if (header != 0x31) {
    throw FormatException('Header inválido para SSCC-96: 0x${header.toRadixString(16).toUpperCase()}');
  }

  // Partition (bits 11-13)
  final partition = int.parse(bits.substring(11, 14), radix: 2);
  if (partition > 6) throw FormatException('Partition fuera de rango: $partition');
  final (cpBits, _, _, _) = _partitionTable[partition];

  // Serial Reference (bits 14+cpBits .. 72, variable bits)
  final srStart = 14 + cpBits;
  final srEnd = 72; // Los últimos 24 bits (72-95) son reservados/cero
  final srVal = int.parse(bits.substring(srStart, srEnd), radix: 2);

  // Numeric part: últimos 8 dígitos del SR
  final numericPart = (srVal % 100000000).toString().padLeft(8, '0');

  // Extension digit (primer dígito del SR de 10 dígitos) → letra
  final srStr = srVal.toString();
  final extensionDigit = srStr.isNotEmpty ? int.parse(srStr[0]) : 0;
  final letter = _ssccLetterMap[extensionDigit] ?? '?';

  return LabelDecodeResult(type: EpcType.sscc96, letter: letter, numericPart: numericPart);
}

/// Intenta decodificar cualquier EPC soportado.
/// Retorna un resultado tipado según el header detectado.
/// Lanza FormatException si no es un formato reconocido.
Object decodeAnyEpc(String epcHex) {
  final type = detectEpcType(epcHex);
  switch (type) {
    case EpcType.sgtin96:
      return decodeEpc(epcHex);
    case EpcType.grai96:
      return decodeGrai96(epcHex);
    case EpcType.sscc96:
      return decodeSscc96(epcHex);
    default:
      throw FormatException('Formato EPC no reconocido: ${epcHex.substring(0, 2)}');
  }
}
