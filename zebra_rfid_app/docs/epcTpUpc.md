# Algoritmo: Decodificar EPC SGTIN-96 → GTIN-14 / EAN-13 / UPC-A

## Entrada
String hexadecimal de **24 caracteres** (96 bits) que representa un EPC SGTIN-96.
Ejemplo: `3034F849004ED6000000003D`

## Salida
- `companyPrefix` (string)
- `itemReference` (string)
- `serial` (int)
- `gtin14` (string de 14 dígitos)
- `ean13` (string de 13 dígitos)
- `upcA` (string de 12 dígitos, opcional — solo si aplica)

---

## Estructura de los 96 bits

| Campo          | Bits    | Tamaño                          |
|----------------|---------|----------------------------------|
| Header         | 0–7     | 8 bits (debe ser `0x30`)         |
| Filter         | 8–10    | 3 bits                           |
| Partition      | 11–13   | 3 bits                           |
| CompanyPrefix  | 14–…    | variable (según Partition)       |
| ItemReference  | …       | variable (según Partition)       |
| Serial         | últimos | 38 bits                          |

## Tabla de Partition (oficial GS1)

| Partition | CP bits | CP dígitos | IR bits | IR dígitos |
|-----------|---------|------------|---------|------------|
| 0         | 40      | 12         | 4       | 1          |
| 1         | 37      | 11         | 7       | 2          |
| 2         | 34      | 10         | 10      | 3          |
| 3         | 30      | 9          | 14      | 4          |
| 4         | 27      | 8          | 17      | 5          |
| 5         | 24      | 7          | 20      | 6          |
| 6         | 20      | 6          | 24      | 7          |

> En todas las particiones: **CP dígitos + IR dígitos = 13**.

---

## Pasos

### 1. Convertir el EPC hex a binario de 96 bits
- Parsear el hex como entero.
- Formatear ese entero como cadena binaria con **padding a 96 bits**.

### 2. Validar el Header
- Tomar los bits 0–7.
- Debe ser `00110000` (`0x30`). Si no, no es SGTIN-96 → lanzar error.

### 3. Leer el Partition
- Tomar los bits 11–13 como entero (0–6).
- Buscar en la tabla los valores `cpBits`, `cpDigits`, `irBits`, `irDigits`.

### 4. Extraer CompanyPrefix
- Tomar los bits `[14 .. 14 + cpBits)`.
- Convertir a entero decimal.
- Rellenar con ceros a la izquierda hasta `cpDigits`.

### 5. Extraer ItemReference
- Tomar los bits `[14 + cpBits .. 14 + cpBits + irBits)`.
- Convertir a entero decimal.
- Rellenar con ceros a la izquierda hasta `irDigits`.

### 6. Extraer Serial
- Tomar los bits restantes (los últimos 38).
- Convertir a entero decimal.

### 7. Construir el GTIN-14 ⚠️ Punto crítico

El primer dígito del **ItemReference** es el **indicator digit** del GTIN-14 y va al frente. NO se concatena `"0" + CP + IR`.

```
indicator = itemReference[0]
resto     = itemReference[1 .. fin]
base13    = indicator + companyPrefix + resto      // 13 dígitos
check     = calcular check digit GS1 sobre base13
gtin14    = base13 + check                          // 14 dígitos
```

### 8. Calcular el check digit GS1 (módulo 10)

Sobre los 13 dígitos de `base13`:

1. Invertir la cadena (recorrer de derecha a izquierda).
2. Para cada dígito en la cadena invertida:
   - Si su índice (0-based) es **par** → multiplicar por **3**.
   - Si su índice es **impar** → multiplicar por **1**.
3. Sumar todos los productos.
4. `check = (10 − (suma mod 10)) mod 10`.

### 9. Derivar EAN-13 y UPC-A
- **EAN-13** = `gtin14.substring(1)` → 13 dígitos.
- **UPC-A** = `gtin14.substring(2)` solo si `gtin14` empieza con `"00"`, si no → no aplica (es EAN-13 europeo).

---

## Ejemplo completo de verificación

**Entrada:** `3034F849004ED6000000003D`

| Paso | Resultado |
|------|-----------|
| Binario (96 bits) | `00110000 00110100 11111000 01001001 00000000 01001110 11010110 00000000 ...` |
| Header | `0x30` ✅ |
| Filter | `1` |
| Partition | `5` → CP=24 bits / 7 díg, IR=20 bits / 6 díg |
| CompanyPrefix | `4067904` |
| ItemReference | `080728` |
| Serial | `61` |
| indicator | `0` |
| base13 | `0` + `4067904` + `80728` = `0406790480728` |
| check digit | `5` |
| **GTIN-14** | `04067904807285` |
| **EAN-13** | `4067904807285` |
| **UPC-A** | (no aplica, no empieza con `00`) |

---

## Casos de prueba para validar la implementación

```
3034F849004ED6000000003D → EAN-13: 4067904807285
3034F849004ED5400000008C → EAN-13: 4067904807254
3034F84A3C4AAD4035A6563B → EAN-13: 4067983764691
3034F84A3C5E76C023C63530 → EAN-13: 4067983967313
3034F848D049FC4000000032 → EAN-13: 4067892757616
3034034A0C0DBAC000001998 → EAN-13: 0053891140591
3034034A0C0DBAC000001D6E → EAN-13: 0053891140591
```