import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/rfid_tag.dart';
import '../services/zebra_rfid_service.dart';
import '../utils/epc_decoder.dart';

// Represents a unique item (by EPC). Tracks which antenna ports detected it.
class _ConteoItem {
  final String epc;
  final Set<int> antennas = {};
  int rssi;
  DateTime lastSeen;
  String? tid;
  String? pc;
  final EpcStatus status;

  _ConteoItem({required this.epc, required int antenna, required this.rssi})
      : lastSeen = DateTime.now(),
        status = _computeEpcStatus(epc) {
    antennas.add(antenna);
  }

  /// Regla: si detectEpcType devuelve null (header no reconocido, ej. 0xE2),
  /// la etiqueta no está encodeada con ningún estándar GS1 conocido.
  static EpcStatus _computeEpcStatus(String epc) {
    final type = detectEpcType(epc);
    if (type == null) return EpcStatus.sinEncodear;
    try {
      switch (type) {
        case EpcType.sgtin96:
          decodeEpc(epc);
        case EpcType.grai96:
          decodeGrai96(epc);
        case EpcType.sscc96:
          decodeSscc96(epc);
      }
      return EpcStatus.decodificado;
    } catch (_) {
      return EpcStatus.desconocido;
    }
  }

  void update(RfidTag tag) {
    antennas.add(tag.antenna);
    rssi = tag.rssi;
    lastSeen = DateTime.now();
  }

  String get antennasText => antennas.map((a) => 'A$a').join(', ');
}

// Grouped view: items with same UPC are one row
class _GroupedRow {
  final String groupKey; // UPC sin ceros, o EPC si no decodifica
  final String displayCode; // "UPC: 123..." o EPC hex
  final List<_ConteoItem> items;
  final DateTime firstSeen;

  _GroupedRow({
    required this.groupKey,
    required this.displayCode,
    required this.items,
    required this.firstSeen,
  });

  int get quantity => items.length;
}

class ConteoScreen extends StatefulWidget {
  final ZebraRfidService rfid;
  const ConteoScreen({super.key, required this.rfid});

  @override
  State<ConteoScreen> createState() => _ConteoScreenState();
}

class _ConteoScreenState extends State<ConteoScreen>
    with SingleTickerProviderStateMixin {
  // key = EPC (unique per physical item)
  final Map<String, _ConteoItem> _items = {};
  // Stable discovery order for grouping
  final List<String> _discoveryOrder = []; // group keys in order of first appearance
  final Map<String, _GroupedRow> _groups = {};
  bool _isScanning = false;
  String? _scanError;
  int _rawEvents = 0;
  StreamSubscription<List<RfidTag>>? _sub;

  // Counter animation
  late final AnimationController _counterAnim;
  late Animation<double> _scaleAnim;
  int _lastCount = 0;

  @override
  void initState() {
    super.initState();
    _counterAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnim = Tween<double>(begin: 1, end: 1.25).animate(
      CurvedAnimation(parent: _counterAnim, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _counterAnim.dispose();
    _sub?.cancel();
    _sub = null;
    // Siempre detener el inventario nativo al salir de la pantalla.
    // El nuevo startInventory hace stop+espera antes de iniciar,
    // así que no hay riesgo de OPERENDSUMMARY retrasado.
    widget.rfid.stopInventory().catchError((_) {}); // fire-and-forget
    super.dispose();
  }

  // ------------------------------------------------------------------
  // Scan control
  // ------------------------------------------------------------------

  Future<void> _startInventory() async {
    setState(() => _scanError = null);
    try {
      // Suscribirse ANTES de iniciar el inventario nativo para no perder
      // eventos que el SDK pueda enviar inmediatamente tras el start.
      _sub?.cancel();
      _sub = widget.rfid.tagStream.listen(_onTags, onError: _onError);
      await widget.rfid.startInventory();
      setState(() => _isScanning = true);
    } on PlatformException catch (e) {
      _sub?.cancel();
      _sub = null;
      setState(() => _scanError = e.message ?? 'Error al iniciar el inventario');
    }
  }

  Future<void> _stopInventory() async {
    _sub?.cancel();
    _sub = null;
    _isScanning = false; // Marcar detenido antes del await para que dispose no repita stopInventory
    try { await widget.rfid.stopInventory(); } catch (_) {}
    if (mounted) setState(() { _isScanning = false; _scanError = null; });
    // Con el inventario ya detenido, el SDK puede singularizar tags para leer TID.
    _fetchPendingTids();
  }

  /// Lanza lecturas de TID para todos los items sinEncodear que aún no tienen TID.
  /// Debe llamarse DESPUÉS de detener el inventario.
  void _fetchPendingTids() {
    final pending = _items.values
        .where((item) => item.status == EpcStatus.sinEncodear && item.tid == null)
        .toList();
    for (final item in pending) {
      _fetchTid(item);
    }
  }

  void _toggleScan() =>
      _isScanning ? _stopInventory() : _startInventory();

  // ------------------------------------------------------------------
  // Tag processing
  // ------------------------------------------------------------------

  void _onTags(List<RfidTag> tags) {
    if (!mounted) return;
    _rawEvents++;
    bool changed = false;

    for (final tag in tags) {
      if (tag.epc.isEmpty) continue;
      final existing = _items[tag.epc];
      if (existing == null) {
        // New unique item
        final item = _ConteoItem(
          epc: tag.epc,
          antenna: tag.antenna,
          rssi: tag.rssi,
        );
        _items[tag.epc] = item;
        _addToGroup(item);
        changed = true;
      } else {
        existing.update(tag);
      }
    }

    if (changed) {
      final newCount = _items.length;
      if (newCount != _lastCount) {
        _lastCount = newCount;
        _counterAnim.forward(from: 0);
      }
      setState(() {});
    }
  }

  /// Compute the group key for an item
  String _groupKeyFor(String epc) {
    try {
      final type = detectEpcType(epc);
      switch (type) {
        case EpcType.sgtin96:
          final d = decodeEpc(epc);
          return 'upc:${d.displayCode.replaceFirst(RegExp(r"^0+"), "")}';
        case EpcType.grai96:
          final l = decodeGrai96(epc);
          return 'label:${l.displayLabel}';
        case EpcType.sscc96:
          final l = decodeSscc96(epc);
          return 'label:${l.displayLabel}';
        default:
          return epc;
      }
    } catch (_) {
      return epc; // raw EPC as its own group
    }
  }

  /// Add item to its UPC group (or create new group)
  void _addToGroup(_ConteoItem item) {
    final key = _groupKeyFor(item.epc);
    if (_groups.containsKey(key)) {
      _groups[key]!.items.add(item);
    } else {
      String displayCode;
      if (key.startsWith('upc:')) {
        displayCode = 'UPC: ${key.substring(4)}';
      } else if (key.startsWith('label:')) {
        displayCode = 'Etiqueta: ${key.substring(6)}';
      } else {
        displayCode = item.epc;
      }
      _groups[key] = _GroupedRow(
        groupKey: key,
        displayCode: displayCode,
        items: [item],
        firstSeen: DateTime.now(),
      );
      _discoveryOrder.add(key);
    }
  }

  void _onError(Object err) {
    _showError(err.toString());
    setState(() => _isScanning = false);
  }

  /// Lee el banco TID del tag de forma asíncrona. Si falla, tid queda null
  /// sin interrumpir el conteo ni mostrar error al usuario.
  void _fetchTid(_ConteoItem item) {
    widget.rfid.readTid(item.epc).then((tid) {
      if (!mounted || !_items.containsKey(item.epc)) return;
      setState(() => _items[item.epc]!.tid = tid);
    }).catchError((_) {
      // TID permanece null — lectura no soportada o tag fuera de rango
    });
  }

  void _clearItems() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Limpiar conteo'),
        content: const Text('¿Deseas eliminar todos los artículos escaneados?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() { _items.clear(); _groups.clear(); _discoveryOrder.clear(); _lastCount = 0; });
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Limpiar'),
          ),
        ],
      ),
    );
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red.shade700),
    );
  }

  // ------------------------------------------------------------------
  // UI
  // ------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    // Grouped rows in stable discovery order
    final rows = _discoveryOrder
        .map((key) => _groups[key]!)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF833177),
        foregroundColor: Colors.white,
        title: const Text('Conteo de Inventario', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (_items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Limpiar',
              onPressed: _clearItems,
            ),
        ],
      ),
      body: Column(
        children: [
          // ── Counter header ──────────────────────────────────────
          _CounterHeader(
            count: _items.length,
            isScanning: _isScanning,
            scaleAnim: _scaleAnim,
            rawEvents: _rawEvents,
          ),

          // ── Error banner ─────────────────────────────────────────
          if (_scanError != null)
            Container(
              width: double.infinity,
              color: Colors.red.shade700,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(_scanError!, style: const TextStyle(color: Colors.white, fontSize: 13)),
                  ),
                ],
              ),
            ),

          // ── Tag list ────────────────────────────────────────────
          Expanded(
            child: rows.isEmpty
                ? _EmptyState(isScanning: _isScanning)
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                    itemCount: rows.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _GroupTile(row: rows[i]),
                  ),
          ),
        ],
      ),

      // ── Bottom action ──────────────────────────────────────────
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: SizedBox(
            height: 52,
            child: FilledButton.icon(
              onPressed: _toggleScan,
              icon: Icon(_isScanning ? Icons.stop_rounded : Icons.play_arrow_rounded, size: 22),
              label: Text(
                _isScanning ? 'Detener escaneo' : 'Iniciar escaneo',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: _isScanning ? Colors.red.shade600 : const Color(0xFF833177),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Widgets
// ---------------------------------------------------------------------------

class _CounterHeader extends StatelessWidget {
  final int count;
  final bool isScanning;
  final Animation<double> scaleAnim;
  final int rawEvents;

  const _CounterHeader({
    required this.count,
    required this.isScanning,
    required this.scaleAnim,
    required this.rawEvents,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF833177),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 22),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Count
          ScaleTransition(
            scale: scaleAnim,
            child: Text(
              '$count',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 52,
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              count == 1 ? 'artículo' : 'artículos',
              style: const TextStyle(color: Colors.white70, fontSize: 15),
            ),
          ),
          const Spacer(),
          // Status indicator
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isScanning ? Colors.greenAccent : Colors.white38,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  isScanning ? 'Escaneando' : 'Detenido',
                  style: TextStyle(
                    color: isScanning ? Colors.greenAccent : Colors.white54,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupTile extends StatefulWidget {
  final _GroupedRow row;
  const _GroupTile({required this.row});

  @override
  State<_GroupTile> createState() => _GroupTileState();
}

class _GroupTileState extends State<_GroupTile> {
  bool _expanded = false;

  void _showDetail(_ConteoItem item) {
    EpcDecodeResult? decoded;
    LabelDecodeResult? labelDecoded;
    final type = detectEpcType(item.epc);
    try {
      if (type == EpcType.sgtin96) {
        decoded = decodeEpc(item.epc);
      } else if (type == EpcType.grai96) {
        labelDecoded = decodeGrai96(item.epc);
      } else if (type == EpcType.sscc96) {
        labelDecoded = decodeSscc96(item.epc);
      }
    } catch (_) {}
    showDialog(context: context, builder: (_) => _TagDetailDialog(item: item, decoded: decoded, labelDecoded: labelDecoded));
  }

  @override
  Widget build(BuildContext context) {
    final row = widget.row;
    final hasMultiple = row.quantity > 1;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // ── Main row ──────────────────────────
          InkWell(
            onTap: hasMultiple
                ? () => setState(() => _expanded = !_expanded)
                : () => _showDetail(row.items.first),
            borderRadius: BorderRadius.circular(12),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  // Left accent bar
                  Container(
                    width: 4,
                    decoration: const BoxDecoration(
                      color: Color(0xFF833177),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            row.displayCode,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (row.groupKey.startsWith('upc:')) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                _fieldLabel('SKU:'),
                                const SizedBox(width: 4),
                                _fieldValue('—'),
                                const SizedBox(width: 16),
                                _fieldLabel('Piezas:'),
                                const SizedBox(width: 4),
                                _fieldValue('—'),
                              ],
                            ),
                          ],
                          if (row.items.first.status == EpcStatus.sinEncodear) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Sin encodear',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.orange.shade800,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Quantity badge (only if more than 1)
                  if (hasMultiple)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF833177).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${row.quantity}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF833177),
                        ),
                      ),
                    ),
                  if (hasMultiple) const SizedBox(width: 8),

                  if (hasMultiple)
                    Icon(
                      _expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                      color: Colors.grey.shade400,
                      size: 22,
                    )
                  else
                    Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400, size: 20),
                  const SizedBox(width: 12),
                ],
              ),
            ),
          ),

          // ── Expanded individual tags ──────────
          if (_expanded && hasMultiple) ...[
            Divider(height: 1, color: Colors.grey.shade200),
            ...row.items.map((item) => InkWell(
              onTap: () => _showDetail(item),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.label_outline, size: 16, color: Colors.grey.shade400),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.epc,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, size: 16, color: Colors.grey.shade300),
                  ],
                ),
              ),
            )),
            const SizedBox(height: 4),
          ],
        ],
      ),
    );
  }

  Widget _fieldLabel(String text) => Text(text,
      style: TextStyle(fontSize: 12, color: Colors.grey.shade500));

  Widget _fieldValue(String text) => Text(text,
      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700));
}

class _TagDetailDialog extends StatelessWidget {
  final _ConteoItem item;
  final EpcDecodeResult? decoded;
  final LabelDecodeResult? labelDecoded;
  const _TagDetailDialog({required this.item, required this.decoded, this.labelDecoded});

  void _copy(BuildContext context, String value, String label) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('$label copiado'),
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final d = decoded;
    final l = labelDecoded;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.nfc, color: Color(0xFF833177)),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('Detalle del tag',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const Divider(height: 20),

            // EPC
            _DetailRow(
              label: 'EPC',
              value: item.epc,
              monospace: true,
              onCopy: () => _copy(context, item.epc, 'EPC'),
            ),

            if (item.status == EpcStatus.sinEncodear) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, size: 15, color: Colors.orange.shade700),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Sin encodear — header: 0x${item.epc.length >= 2 ? item.epc.substring(0, 2).toUpperCase() : "??"}',
                        style: TextStyle(fontSize: 12, color: Colors.orange.shade800),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              if (item.tid != null)
                _DetailRow(
                  label: 'TID',
                  value: item.tid!,
                  monospace: true,
                  onCopy: () => _copy(context, item.tid!, 'TID'),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 120,
                        child: Text('TID', style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500)),
                      ),
                      Text('Leyendo...', style: TextStyle(fontSize: 13, color: Colors.grey.shade400)),
                    ],
                  ),
                ),
            ] else if (d != null) ...[
              const SizedBox(height: 10),
              if (d.upcA != null)
                _DetailRow(
                  label: 'UPC-A',
                  value: d.upcA!,
                  monospace: true,
                  onCopy: () => _copy(context, d.upcA!, 'UPC-A'),
                ),
              _DetailRow(
                label: 'EAN-13',
                value: d.ean13,
                monospace: true,
                onCopy: () => _copy(context, d.ean13, 'EAN-13'),
              ),
              _DetailRow(
                label: 'GTIN-14',
                value: d.gtin14,
                monospace: true,
                onCopy: () => _copy(context, d.gtin14, 'GTIN-14'),
              ),
              const SizedBox(height: 6),
              _DetailRow(label: 'Company Prefix', value: d.companyPrefix),
              _DetailRow(label: 'Item Reference', value: d.itemReference),
              _DetailRow(label: 'Serial', value: d.serial.toString()),
            ] else if (l != null) ...[
              const SizedBox(height: 10),
              _DetailRow(
                label: 'Etiqueta',
                value: l.displayLabel,
                monospace: true,
                onCopy: () => _copy(context, l.displayLabel, 'Etiqueta'),
              ),
              _DetailRow(
                label: 'Tipo',
                value: l.type == EpcType.grai96 ? 'GRAI-96' : 'SSCC-96',
              ),
              _DetailRow(label: 'Prefijo', value: l.letter),
              _DetailRow(label: 'Número', value: l.numericPart),
            ] else ...[
              const SizedBox(height: 10),
              const Text(
                'Formato EPC no reconocido',
                style: TextStyle(color: Colors.orange, fontSize: 12),
              ),
            ],

            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // Scan metadata
            _DetailRow(label: 'Antena(s)', value: item.antennasText),
            _DetailRow(label: 'RSSI', value: '${item.rssi} dBm'),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool monospace;
  final VoidCallback? onCopy;
  const _DetailRow({required this.label, required this.value, this.monospace = false, this.onCopy});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                fontFamily: monospace ? 'monospace' : null,
              ),
            ),
          ),
          if (onCopy != null)
            GestureDetector(
              onTap: onCopy,
              child: const Icon(Icons.copy, size: 15, color: Colors.grey),
            ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isScanning;
  const _EmptyState({required this.isScanning});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isScanning ? Icons.wifi_tethering : Icons.inventory_2_outlined,
              size: 72,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              isScanning ? 'Esperando etiquetas...' : 'Presiona Iniciar escaneo\npara comenzar',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
