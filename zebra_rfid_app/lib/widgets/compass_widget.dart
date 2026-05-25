import 'dart:math';
import 'package:flutter/material.dart';

/// Compass-style widget showing direction and distance to a RFID tag.
///
/// States:
///  - !isSearching            → static arrow pointing up, muted colors
///  - isSearching + no target → gentle pulse animation (signal scanning)
///  - isSearching + target    → directed arrow pointing to tag
class CompassWidget extends StatefulWidget {
  final bool isSearching;
  final double? targetBearing;   // 0-360°, null = target not locked yet
  final double deviceHeading;    // current compass heading (0-360°)
  final double distanceMeters;   // -1 if unknown
  final int rssiPercent;         // 0-100
  final double compassSize;      // diameter of the compass circle

  const CompassWidget({
    super.key,
    required this.isSearching,
    required this.targetBearing,
    required this.deviceHeading,
    required this.distanceMeters,
    required this.rssiPercent,
    this.compassSize = 260,
  });

  @override
  State<CompassWidget> createState() => _CompassWidgetState();
}

class _CompassWidgetState extends State<CompassWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  // Arrow angle relative to device heading (0 = points up/forward)
  double _arrowAngle() {
    final target = widget.targetBearing;
    if (target == null) return 0;
    final relative = (target - widget.deviceHeading + 360) % 360;
    return relative * pi / 180;
  }

  @override
  Widget build(BuildContext context) {
    final hasTarget = widget.isSearching && widget.targetBearing != null;
    final distText = widget.distanceMeters < 0
        ? '--'
        : widget.distanceMeters < 10
            ? widget.distanceMeters.toStringAsFixed(1)
            : widget.distanceMeters.toStringAsFixed(0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: widget.compassSize,
          height: widget.compassSize,
          child: widget.isSearching && widget.targetBearing == null
              // Scanning but no lock yet → pulse the ring
              ? AnimatedBuilder(
                  animation: _pulseCtrl,
                  builder: (_, __) => CustomPaint(
                    painter: _CompassPainter(
                      arrowAngle: 0,
                      rssiPercent: widget.rssiPercent,
                      active: true,
                      locked: false,
                      pulseValue: _pulseCtrl.value,
                    ),
                  ),
                )
              // Static (idle or locked target)
              : CustomPaint(
                  painter: _CompassPainter(
                    arrowAngle: _arrowAngle(),
                    rssiPercent: widget.rssiPercent,
                    active: widget.isSearching,
                    locked: hasTarget,
                    pulseValue: 0,
                  ),
                ),
        ),
        const SizedBox(height: 16),

        // Distance
        Text(
          '$distText m',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: hasTarget ? const Color(0xFF833177) : Colors.grey.shade400,
            height: 1,
          ),
        ),
        const Text(
          'distancia estimada',
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),
        const SizedBox(height: 16),

        // Signal bar — only shown when searching
        if (widget.isSearching) _SignalBar(percent: widget.rssiPercent),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Custom Painter
// ---------------------------------------------------------------------------

class _CompassPainter extends CustomPainter {
  final double arrowAngle;  // radians
  final int rssiPercent;
  final bool active;        // currently scanning
  final bool locked;        // target bearing found
  final double pulseValue;  // 0-1 for pulse animation

  _CompassPainter({
    required this.arrowAngle,
    required this.rssiPercent,
    required this.active,
    required this.locked,
    required this.pulseValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = size.width / 2 - 8;

    final primaryColor = active
        ? const Color(0xFF833177)
        : Colors.grey.shade400;

    // ── Outer ring ──────────────────────────────────────────────────
    canvas.drawCircle(
      Offset(cx, cy),
      radius,
      Paint()..color = const Color(0xFFE8ECF2),
    );
    canvas.drawCircle(
      Offset(cx, cy),
      radius,
      Paint()
        ..color = primaryColor.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // ── Pulse ring (scanning, no lock) ───────────────────────────────
    if (!locked && active && pulseValue > 0) {
      canvas.drawCircle(
        Offset(cx, cy),
        radius * (0.55 + pulseValue * 0.15),
        Paint()
          ..color = primaryColor.withValues(alpha: 0.12 * (1 - pulseValue))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10,
      );
    }

    // ── Tick marks ──────────────────────────────────────────────────
    final tickPaint = Paint()
      ..color = Colors.grey.withValues(alpha: active ? 0.35 : 0.18)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 36; i++) {
      final angle = i * 10 * pi / 180;
      final isMajor = i % 9 == 0;
      final inner = radius - (isMajor ? 14 : 8);
      canvas.drawLine(
        Offset(cx + inner * sin(angle), cy - inner * cos(angle)),
        Offset(cx + (radius - 2) * sin(angle), cy - (radius - 2) * cos(angle)),
        tickPaint,
      );
    }

    // ── Cardinal letters ────────────────────────────────────────────
    const cardinals = ['N', 'E', 'S', 'O'];
    final tp = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i < 4; i++) {
      final angle = i * pi / 2;
      final d = radius - 26;
      tp.text = TextSpan(
        text: cardinals[i],
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: i == 0
              ? (active ? const Color(0xFF833177) : Colors.grey.shade400)
              : Colors.grey.shade400,
        ),
      );
      tp.layout();
      tp.paint(
        canvas,
        Offset(
          cx + d * sin(angle) - tp.width / 2,
          cy - d * cos(angle) - tp.height / 2,
        ),
      );
    }

    // ── Signal glow (locked target) ──────────────────────────────────
    if (locked && rssiPercent > 0) {
      final glowColor = _signalColor(rssiPercent);
      canvas.drawCircle(
        Offset(cx, cy),
        radius * 0.72,
        Paint()
          ..color = glowColor.withValues(alpha: rssiPercent / 300)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 12
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
    }

    // ── Arrow ────────────────────────────────────────────────────────
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(arrowAngle);

    final arrowLen  = radius * 0.58;
    final arrowTail = radius * 0.28;

    // Tail
    canvas.drawPath(
      Path()
        ..moveTo(0, arrowTail)
        ..lineTo(-7, arrowTail + 14)
        ..lineTo(7, arrowTail + 14)
        ..close(),
      Paint()
        ..color = locked
            ? Colors.red.shade400
            : Colors.grey.shade300
        ..style = PaintingStyle.fill,
    );

    // Head
    canvas.drawPath(
      Path()
        ..moveTo(0, -arrowLen)
        ..lineTo(-11, -arrowLen + 40)
        ..lineTo(0, -arrowLen + 28)
        ..lineTo(11, -arrowLen + 40)
        ..close(),
      Paint()
        ..color = primaryColor
        ..style = PaintingStyle.fill,
    );

    // Shaft
    canvas.drawLine(
      Offset(0, -arrowLen + 28),
      Offset(0, arrowTail),
      Paint()
        ..color = primaryColor
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );

    canvas.restore();

    // ── Centre circle ────────────────────────────────────────────────
    canvas.drawCircle(Offset(cx, cy), 12, Paint()..color = Colors.white);
    canvas.drawCircle(
      Offset(cx, cy),
      12,
      Paint()
        ..color = primaryColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
  }

  Color _signalColor(int pct) {
    if (pct > 66) return Colors.green;
    if (pct > 33) return Colors.orange;
    return Colors.red;
  }

  @override
  bool shouldRepaint(_CompassPainter old) =>
      old.arrowAngle != arrowAngle ||
      old.rssiPercent != rssiPercent ||
      old.active != active ||
      old.locked != locked ||
      old.pulseValue != pulseValue;
}

// ---------------------------------------------------------------------------
// Signal bar
// ---------------------------------------------------------------------------

class _SignalBar extends StatelessWidget {
  final int percent;
  const _SignalBar({required this.percent});

  Color get _color {
    if (percent > 66) return Colors.green;
    if (percent > 33) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.signal_cellular_alt, color: _color, size: 18),
            const SizedBox(width: 6),
            Text(
              'Señal: $percent%',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 200,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: percent / 100,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(_color),
              minHeight: 8,
            ),
          ),
        ),
      ],
    );
  }
}
