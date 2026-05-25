import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/rfid_tag.dart';
import '../services/zebra_rfid_service.dart';
import '../utils/epc_decoder.dart';

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------
class BuscarScreen extends StatefulWidget {
  final ZebraRfidService rfid;
  const BuscarScreen({super.key, required this.rfid});

  @override
  State<BuscarScreen> createState() => _BuscarScreenState();
}

class _BuscarScreenState extends State<BuscarScreen>
    with SingleTickerProviderStateMixin {
  final _inputCtrl = TextEditingController();
  final _focusNode = FocusNode();

  bool _isScanning = false;

  // Search target
  String? _targetEpc;
  String? _targetUpc;
  String? _displayQuery;

  // Signal processing
  double _rawRssi = -100;
  double _emaRssi = -100;       // Exponential Moving Average
  double _peakRssi = -100;      // Best signal ever seen in this session
  int _rssiPercent = 0;
  double _distanceMeters = -1;
  DateTime? _lastReadTime;

  // Trend detection
  final List<double> _rssiHistory = [];
  static const _historyMax = 40;
  _Trend _trend = _Trend.none;

  // Haptic timing
  Timer? _hapticTimer;
  int _lastHapticMs = 0;

  // Signal decay — makes display respond when moving away
  Timer? _decayTimer;
  DateTime _lastTagSeen = DateTime.now();

  // Animation
  late final AnimationController _pulseAnim;

  StreamSubscription<List<RfidTag>>? _tagSub;

  // RSSI calibration — Zebra handheld, detecta hasta ~5-8m
  static const _rssiMin = -75.0;
  static const _rssiMax = -30.0;

  @override
  void initState() {
    super.initState();
    _pulseAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  @override
  void dispose() {
    _pulseAnim.dispose();
    _hapticTimer?.cancel();
    _decayTimer?.cancel();
    _inputCtrl.dispose();
    _focusNode.dispose();
    _tagSub?.cancel();
    _tagSub = null;
    widget.rfid.stopInventory().catchError((_) {});
    super.dispose();
  }

  // ------------------------------------------------------------------
  // Input detection
  // ------------------------------------------------------------------
  bool _looksLikeEpc(String s) =>
      s.length == 24 && RegExp(r'^[0-9A-Fa-f]+$').hasMatch(s);

  bool _looksLikeUpc(String s) =>
      (s.length == 12 || s.length == 13) && RegExp(r'^\d+$').hasMatch(s);

  // ------------------------------------------------------------------
  // Scan control
  // ------------------------------------------------------------------
  Future<void> _startScan() async {
    final raw = _inputCtrl.text.trim().toUpperCase();
    if (raw.isEmpty) { _snack('Ingresa un código'); return; }

    if (!_looksLikeEpc(raw) && !_looksLikeUpc(raw)) {
      _snack('Código no válido');
      return;
    }

    FocusScope.of(context).unfocus();

    _tagSub?.cancel();
    _tagSub = widget.rfid.tagStream.listen(_onTags, onError: _onError);

    try {
      await widget.rfid.startInventory();
    } on PlatformException catch (e) {
      _tagSub?.cancel();
      _tagSub = null;
      _snack(e.message ?? 'Error al iniciar'); return;
    }

    setState(() {
      if (_looksLikeEpc(raw)) {
        _targetEpc = raw;
        _targetUpc = null;
        _displayQuery = raw;
      } else {
        _targetEpc = null;
        _targetUpc = raw;
        _displayQuery = raw;
      }
      _isScanning = true;
      _rawRssi = -100;
      _emaRssi = -100;
      _peakRssi = -100;
      _rssiPercent = 0;
      _distanceMeters = -1;
      _lastReadTime = null;
      _rssiHistory.clear();
      _trend = _Trend.none;
    });

    _pulseAnim.repeat(reverse: true);
    _startHapticLoop();
    _startDecayLoop();
  }

  Future<void> _stopScan() async {
    _tagSub?.cancel();
    _tagSub = null;
    _hapticTimer?.cancel();
    _decayTimer?.cancel();
    _pulseAnim.stop();
    _isScanning = false;
    try { await widget.rfid.stopInventory(); } catch (_) {}
    if (mounted) setState(() {
      _isScanning = false;
      _targetEpc = null;
      _targetUpc = null;
    });
  }

  // ------------------------------------------------------------------
  // Tag matching
  // ------------------------------------------------------------------
  bool _matches(RfidTag tag) {
    if (_targetEpc != null) return tag.epc.toUpperCase() == _targetEpc;
    if (_targetUpc != null) {
      try {
        final d = decodeEpc(tag.epc);
        final t = _targetUpc!;
        if (d.ean13 == t || d.gtin14 == t) return true;
        if (d.upcA != null && d.upcA == t) return true;
        if (t.length == 12 && d.ean13 == '0$t') return true;
        if (t.length == 13 && t.startsWith('0') && d.upcA == t.substring(1)) return true;
        return false;
      } catch (_) { return false; }
    }
    return false;
  }

  // ------------------------------------------------------------------
  // Tag processing — fast EMA signal tracking
  // ------------------------------------------------------------------
  void _onTags(List<RfidTag> tags) {
    if (!mounted || !_isScanning) return;
    final hits = tags.where(_matches).toList();
    if (hits.isEmpty) return;

    final best = hits.reduce((a, b) => a.rssi > b.rssi ? a : b);
    _rawRssi = best.rssi.toDouble();
    _lastReadTime = DateTime.now();
    _lastTagSeen = DateTime.now();

    // EMA asimétrico: sube rápido (0.5), baja más rápido aún (0.6)
    final alpha = _rawRssi >= _emaRssi ? 0.5 : 0.6;
    if (_emaRssi < -99) {
      _emaRssi = _rawRssi;
    } else {
      _emaRssi = alpha * _rawRssi + (1 - alpha) * _emaRssi;
    }

    // Peak
    if (_emaRssi > _peakRssi) _peakRssi = _emaRssi;

    // History for sparkline
    _rssiHistory.add(_emaRssi);
    if (_rssiHistory.length > _historyMax) _rssiHistory.removeAt(0);

    // Trend
    _trend = _detectTrend();

    // Update pulse speed based on signal
    final ms = _rssiPercent > 0
        ? (1400 - (_toPercent(_emaRssi) * 11)).clamp(250, 1400)
        : 1400;
    _pulseAnim.duration = Duration(milliseconds: ms);

    setState(() {
      _rssiPercent = _toPercent(_emaRssi);
      _distanceMeters = _toDistance(_emaRssi);
    });
  }

  _Trend _detectTrend() {
    if (_rssiHistory.length < 6) return _Trend.none;
    final recent = _rssiHistory.sublist(_rssiHistory.length - 3);
    final older = _rssiHistory.sublist(_rssiHistory.length - 6, _rssiHistory.length - 3);
    final recentAvg = recent.reduce((a, b) => a + b) / recent.length;
    final olderAvg = older.reduce((a, b) => a + b) / older.length;
    final diff = recentAvg - olderAvg;
    if (diff > 1.5) return _Trend.improving;
    if (diff < -1.5) return _Trend.worsening;
    return _Trend.stable;
  }

  void _onError(Object e) {
    _snack(e.toString());
    _stopScan();
  }

  // ------------------------------------------------------------------
  // Signal decay — reduce señal si no llegan lecturas
  // ------------------------------------------------------------------
  void _startDecayLoop() {
    _decayTimer?.cancel();
    _lastTagSeen = DateTime.now();
    _decayTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (!_isScanning || !mounted) return;
      final silenceMs = DateTime.now().difference(_lastTagSeen).inMilliseconds;
      if (silenceMs > 800 && _emaRssi > _rssiMin) {
        // Decae 3 dB cada 500ms de silencio — respuesta rápida al alejarse
        _emaRssi = (_emaRssi - 3.0).clamp(_rssiMin, _rssiMax);
        _rssiHistory.add(_emaRssi);
        if (_rssiHistory.length > _historyMax) _rssiHistory.removeAt(0);
        _trend = _detectTrend();
        setState(() {
          _rssiPercent = _toPercent(_emaRssi);
          _distanceMeters = _toDistance(_emaRssi);
        });
      }
    });
  }

  // ------------------------------------------------------------------
  // Signal math
  // ------------------------------------------------------------------
  double _toDistance(double rssi) {
    // txPower = RSSI típico a 1m con tag pasivo UHF y Zebra handheld
    const txPower = -55.0;
    const n = 2.0;
    return pow(10, (txPower - rssi) / (10 * n)).toDouble().clamp(0.1, 10.0);
  }

  int _toPercent(double rssi) =>
      ((rssi - _rssiMin) / (_rssiMax - _rssiMin) * 100).clamp(0, 100).round();

  // ------------------------------------------------------------------
  // Haptic feedback — vibra más rápido al acercarse
  // ------------------------------------------------------------------
  void _startHapticLoop() {
    _hapticTimer?.cancel();
    _hapticTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (!_isScanning || !mounted || _rssiPercent <= 0) return;
      final now = DateTime.now().millisecondsSinceEpoch;
      // Intervalo: 800ms (lejos) → 80ms (encima)
      final interval = (800 - (_rssiPercent * 7.2)).clamp(80, 800).toInt();
      if (now - _lastHapticMs >= interval) {
        _lastHapticMs = now;
        HapticFeedback.lightImpact();
      }
    });
  }

  // ------------------------------------------------------------------
  // UI helpers
  // ------------------------------------------------------------------
  String get _statusText {
    if (_rssiPercent <= 0) return 'Buscando señal...';
    if (_rssiPercent > 85) return 'Artículo localizado';
    if (_rssiPercent > 60) return 'Señal fuerte';
    if (_rssiPercent > 35) return 'Señal media';
    if (_rssiPercent > 15) return 'Señal débil';
    return 'Señal muy débil';
  }

  Color get _signalColor {
    if (_rssiPercent > 75) return const Color(0xFF2E7D32);
    if (_rssiPercent > 50) return const Color(0xFFE65100);
    if (_rssiPercent > 25) return const Color(0xFFFF8F00);
    if (_rssiPercent > 0) return const Color(0xFF1565C0);
    return Colors.grey;
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ------------------------------------------------------------------
  // UI
  // ------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF833177),
        foregroundColor: Colors.white,
        title: const Text('Buscar Artículo', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 16),

              // ── Search input ─────────────────────────────────────
              _SearchInput(
                controller: _inputCtrl,
                focusNode: _focusNode,
                enabled: !_isScanning,
                onSearch: _startScan,
              ),
              const SizedBox(height: 12),

              // ── Status banner ────────────────────────────────────
              if (_isScanning)
                _StatusBanner(
                  statusText: _statusText,
                  percent: _rssiPercent,
                  color: _signalColor,
                  query: _displayQuery ?? '',
                )
              else
                const _IdleBanner(),

              const SizedBox(height: 12),

              // ── Signal Radar (main visual) ───────────────────────
              Expanded(
                child: Center(
                  child: AnimatedBuilder(
                    animation: _pulseAnim,
                    builder: (_, __) => _SignalRadar(
                      percent: _rssiPercent,
                      pulseValue: _pulseAnim.value,
                      isScanning: _isScanning,
                      distanceMeters: _distanceMeters,
                      trend: _trend,
                      color: _signalColor,
                    ),
                  ),
                ),
              ),

              // ── Sparkline ────────────────────────────────────────
              if (_isScanning && _rssiHistory.length > 2) ...[
                _SparkLine(
                  values: _rssiHistory,
                  minVal: _rssiMin,
                  maxVal: _rssiMax,
                  color: _signalColor,
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Pico: ${_toPercent(_peakRssi)}%',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                    if (_lastReadTime != null)
                      Text(
                        'Última: ${DateTime.now().difference(_lastReadTime!).inSeconds}s atrás',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
              ],

              // ── Action button ────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isScanning ? _stopScan : _startScan,
                  icon: Icon(_isScanning ? Icons.stop : Icons.search),
                  label: Text(
                    _isScanning ? 'Detener búsqueda' : 'Iniciar búsqueda',
                    style: const TextStyle(fontSize: 16),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: _isScanning ? Colors.red.shade700 : const Color(0xFF833177),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// Supporting types & widgets
// ===========================================================================

enum _Trend { none, improving, worsening, stable }

// ---------------------------------------------------------------------------
// Signal Radar
// ---------------------------------------------------------------------------
class _SignalRadar extends StatelessWidget {
  final int percent;
  final double pulseValue;
  final bool isScanning;
  final double distanceMeters;
  final _Trend trend;
  final Color color;

  const _SignalRadar({
    required this.percent,
    required this.pulseValue,
    required this.isScanning,
    required this.distanceMeters,
    required this.trend,
    required this.color,
  });

  String get _distText => distanceMeters < 0
      ? '--'
      : distanceMeters < 1 ? '< 1' : distanceMeters.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, constraints) {
      final size = min(constraints.maxWidth, constraints.maxHeight).clamp(200.0, 300.0);
      return SizedBox(
        width: size,
        height: size + 60,
        child: Column(
          children: [
            SizedBox(
              width: size,
              height: size,
              child: CustomPaint(
                painter: _RadarPainter(
                  percent: percent,
                  pulseValue: pulseValue,
                  isScanning: isScanning,
                  color: color,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isScanning && percent > 0)
                        Icon(
                          trend == _Trend.improving ? Icons.north
                              : trend == _Trend.worsening ? Icons.south
                              : Icons.remove,
                          color: trend == _Trend.improving ? const Color(0xFF2E7D32)
                              : trend == _Trend.worsening ? Colors.red
                              : Colors.grey.shade400,
                          size: 26,
                        ),
                      const SizedBox(height: 2),
                      Text(
                        isScanning && percent > 0 ? '$percent%' : '--',
                        style: TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.w900,
                          color: isScanning && percent > 0 ? color : Colors.grey.shade300,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isScanning && percent > 0 ? 'señal' : 'buscando...',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.straighten, size: 16, color: Colors.grey.shade500),
                const SizedBox(width: 5),
                Text(
                  '≈ $_distText m',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isScanning && percent > 0
                        ? const Color(0xFF833177) : Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

// ---------------------------------------------------------------------------
// Radar painter
// ---------------------------------------------------------------------------
class _RadarPainter extends CustomPainter {
  final int percent;
  final double pulseValue;
  final bool isScanning;
  final Color color;

  _RadarPainter({
    required this.percent,
    required this.pulseValue,
    required this.isScanning,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final maxR = size.width / 2 - 4;

    // Background
    canvas.drawCircle(Offset(cx, cy), maxR, Paint()..color = Colors.grey.shade50);

    if (!isScanning) {
      canvas.drawCircle(Offset(cx, cy), maxR,
          Paint()..color = Colors.grey.shade300..style = PaintingStyle.stroke..strokeWidth = 2);
      return;
    }

    // Concentric signal rings (5 rings)
    const rings = 5;
    for (int i = 1; i <= rings; i++) {
      final r = maxR * i / rings;
      final threshold = (i / rings * 100).round();
      final filled = percent >= threshold;
      if (filled) {
        canvas.drawCircle(Offset(cx, cy), r,
            Paint()..color = color.withOpacity(0.06 + 0.04 * i / rings));
      }
      canvas.drawCircle(Offset(cx, cy), r,
          Paint()
            ..color = filled ? color.withOpacity(0.35) : Colors.grey.shade200
            ..style = PaintingStyle.stroke
            ..strokeWidth = filled ? 1.5 : 0.8);
    }

    // Pulse wave
    if (percent > 0) {
      final pr = maxR * (0.2 + 0.8 * pulseValue);
      canvas.drawCircle(Offset(cx, cy), pr,
          Paint()
            ..color = color.withOpacity(0.3 * (1 - pulseValue))
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3.5);
    }

    // Outer ring highlight
    canvas.drawCircle(Offset(cx, cy), maxR,
        Paint()
          ..color = percent > 0 ? color : Colors.grey.shade400
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5);
  }

  @override
  bool shouldRepaint(_RadarPainter old) =>
      old.percent != percent || old.pulseValue != pulseValue ||
      old.isScanning != isScanning || old.color != color;
}

// ---------------------------------------------------------------------------
// SparkLine
// ---------------------------------------------------------------------------
class _SparkLine extends StatelessWidget {
  final List<double> values;
  final double minVal;
  final double maxVal;
  final Color color;

  const _SparkLine({
    required this.values,
    required this.minVal,
    required this.maxVal,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(6),
      child: CustomPaint(painter: _SparkPainter(values: values, minVal: minVal, maxVal: maxVal, color: color)),
    );
  }
}

class _SparkPainter extends CustomPainter {
  final List<double> values;
  final double minVal, maxVal;
  final Color color;
  _SparkPainter({required this.values, required this.minVal, required this.maxVal, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final range = maxVal - minVal;
    if (range == 0) return;

    final path = Path();
    final fill = Path();
    final step = size.width / (values.length - 1);

    for (int i = 0; i < values.length; i++) {
      final x = i * step;
      final y = size.height * (1 - ((values[i] - minVal) / range).clamp(0.0, 1.0));
      if (i == 0) { path.moveTo(x, y); fill.moveTo(x, size.height); fill.lineTo(x, y); }
      else { path.lineTo(x, y); fill.lineTo(x, y); }
    }
    fill.lineTo(size.width, size.height); fill.close();

    canvas.drawPath(fill, Paint()..color = color.withOpacity(0.08));
    canvas.drawPath(path, Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 2..strokeCap = StrokeCap.round);

    // Dot at end
    final lastY = size.height * (1 - ((values.last - minVal) / range).clamp(0.0, 1.0));
    canvas.drawCircle(Offset((values.length - 1) * step, lastY), 3.5, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_SparkPainter old) => true;
}

// ---------------------------------------------------------------------------
// Status banner
// ---------------------------------------------------------------------------
class _StatusBanner extends StatelessWidget {
  final String statusText;
  final int percent;
  final Color color;
  final String query;

  const _StatusBanner({
    required this.statusText,
    required this.percent,
    required this.color,
    required this.query,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: percent > 0 ? color : Colors.grey.shade400,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(statusText,
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: color)),
                Text('Buscando: $query', style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Idle banner
// ---------------------------------------------------------------------------
class _IdleBanner extends StatelessWidget {
  const _IdleBanner();
  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

// ---------------------------------------------------------------------------
// Search input
// ---------------------------------------------------------------------------
class _SearchInput extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool enabled;
  final VoidCallback onSearch;

  const _SearchInput({
    required this.controller,
    required this.focusNode,
    required this.enabled,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      textCapitalization: TextCapitalization.characters,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        hintText: 'Código del artículo',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: IconButton(
          icon: const Icon(Icons.arrow_forward_rounded),
          onPressed: enabled ? onSearch : null,
          color: const Color(0xFF833177),
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFDDE2EF))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFDDE2EF))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF833177), width: 2)),
      ),
      onSubmitted: (_) { if (enabled) onSearch(); },
    );
  }
}
