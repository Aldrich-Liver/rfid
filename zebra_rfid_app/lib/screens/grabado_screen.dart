import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/rfid_tag.dart';
import '../services/zebra_rfid_service.dart';

enum _WriteState { idle, scanning, confirm, writing, success, error }

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------
class GrabadoScreen extends StatefulWidget {
  final ZebraRfidService rfid;
  const GrabadoScreen({super.key, required this.rfid});

  @override
  State<GrabadoScreen> createState() => _GrabadoScreenState();
}

class _GrabadoScreenState extends State<GrabadoScreen> {
  final _epcCtrl = TextEditingController();
  final _focusNode = FocusNode();

  _WriteState _state = _WriteState.idle;
  String? _detectedEpc;
  String? _message;

  StreamSubscription<List<RfidTag>>? _tagSub;

  bool _looksLikeEpc(String s) =>
      s.length == 24 && RegExp(r'^[0-9A-Fa-f]+$').hasMatch(s);

  // Etiqueta "en blanco" = EPC de fábrica sin programar (todo ceros)
  bool _isBlankEpc(String epc) => RegExp(r'^0+$').hasMatch(epc);

  @override
  void dispose() {
    _tagSub?.cancel();
    _epcCtrl.dispose();
    _focusNode.dispose();
    widget.rfid.stopInventory().catchError((_) {});
    super.dispose();
  }

  // ------------------------------------------------------------------
  // Flow: escanear una etiqueta cercana y luego grabar el nuevo EPC
  // ------------------------------------------------------------------
  Future<void> _startWrite() async {
    final newEpc = _epcCtrl.text.trim().toUpperCase();
    if (!_looksLikeEpc(newEpc)) {
      _snack('El nuevo EPC debe tener 24 caracteres hexadecimales');
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _state = _WriteState.scanning;
      _detectedEpc = null;
      _message = 'Acerca la etiqueta al lector...';
    });

    _tagSub?.cancel();
    _tagSub = widget.rfid.tagStream.listen(_onTags, onError: _onError);

    try {
      await widget.rfid.startInventory();
    } on PlatformException catch (e) {
      _tagSub?.cancel();
      _tagSub = null;
      setState(() {
        _state = _WriteState.error;
        _message = e.message ?? 'Error al iniciar el escaneo';
      });
    }
  }

  void _onTags(List<RfidTag> tags) {
    if (_state != _WriteState.scanning || tags.isEmpty) return;
    final best = tags.reduce((a, b) => a.rssi > b.rssi ? a : b);
    _detectedEpc = best.epc;
    _tagSub?.cancel();
    _tagSub = null;
    widget.rfid.stopInventory().catchError((_) {});

    if (_isBlankEpc(best.epc)) {
      _writeToTag(best.epc);
    } else {
      _confirmOverwrite(best.epc);
    }
  }

  Future<void> _confirmOverwrite(String currentEpc) async {
    setState(() => _state = _WriteState.confirm);

    final overwrite = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('La etiqueta ya tiene datos'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('EPC actual grabado en la etiqueta:'),
            const SizedBox(height: 8),
            SelectableText(
              currentEpc,
              style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 14),
            const Text('¿Deseas sobrescribirlo con el nuevo EPC?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            child: const Text('Sobrescribir'),
          ),
        ],
      ),
    );

    if (!mounted) return;
    if (overwrite == true) {
      _writeToTag(currentEpc);
    } else {
      setState(() {
        _state = _WriteState.idle;
        _detectedEpc = null;
        _message = null;
      });
    }
  }

  void _onError(Object e) {
    _tagSub?.cancel();
    _tagSub = null;
    setState(() {
      _state = _WriteState.error;
      _message = e.toString();
    });
  }

  Future<void> _writeToTag(String targetEpc) async {
    final newEpc = _epcCtrl.text.trim().toUpperCase();
    setState(() {
      _state = _WriteState.writing;
      _message = 'Grabando nuevo EPC...';
    });

    try {
      await widget.rfid.writeTag(targetEpc: targetEpc, newEpc: newEpc);
      if (!mounted) return;
      setState(() {
        _state = _WriteState.success;
        _message = 'Etiqueta grabada correctamente';
      });
    } on PlatformException catch (e) {
      if (!mounted) return;
      setState(() {
        _state = _WriteState.error;
        _message = e.message ?? 'Error al grabar la etiqueta';
      });
    }
  }

  Future<void> _cancel() async {
    _tagSub?.cancel();
    _tagSub = null;
    await widget.rfid.stopInventory().catchError((_) {});
    if (!mounted) return;
    setState(() {
      _state = _WriteState.idle;
      _message = null;
    });
  }

  void _reset() {
    setState(() {
      _state = _WriteState.idle;
      _detectedEpc = null;
      _message = null;
      _epcCtrl.clear();
    });
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
    final isBusy = _state == _WriteState.scanning ||
        _state == _WriteState.writing ||
        _state == _WriteState.confirm;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF833177),
        foregroundColor: Colors.white,
        title: const Text('Grabado de Etiqueta', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Nuevo EPC (24 caracteres hex)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A2340)),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _epcCtrl,
                focusNode: _focusNode,
                enabled: !isBusy,
                textCapitalization: TextCapitalization.characters,
                style: const TextStyle(fontSize: 15, fontFamily: 'monospace'),
                maxLength: 24,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9A-Fa-f]')),
                ],
                decoration: InputDecoration(
                  hintText: 'Ej. 30340CF9A8B0C4C000001234',
                  counterText: '',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFDDE2EF))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFDDE2EF))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF833177), width: 2)),
                ),
              ),
              const SizedBox(height: 24),

              Expanded(
                child: Center(
                  child: _StatusPanel(state: _state, message: _message, detectedEpc: _detectedEpc),
                ),
              ),

              if (isBusy)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _cancel,
                    icon: const Icon(Icons.close),
                    label: const Text('Cancelar'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                )
              else if (_state == _WriteState.success || _state == _WriteState.error)
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _reset,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Grabar otra etiqueta', style: TextStyle(fontSize: 16)),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF833177),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _startWrite,
                    icon: const Icon(Icons.edit_note),
                    label: const Text('Grabar etiqueta', style: TextStyle(fontSize: 16)),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF833177),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Status panel
// ---------------------------------------------------------------------------
class _StatusPanel extends StatelessWidget {
  final _WriteState state;
  final String? message;
  final String? detectedEpc;

  const _StatusPanel({required this.state, required this.message, required this.detectedEpc});

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case _WriteState.idle:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.nfc, size: 72, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Ingresa el nuevo EPC y presiona\n"Grabar etiqueta" para comenzar',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
            ),
          ],
        );
      case _WriteState.scanning:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 64, height: 64,
              child: CircularProgressIndicator(strokeWidth: 4, color: Color(0xFF833177)),
            ),
            const SizedBox(height: 20),
            Text(message ?? '', textAlign: TextAlign.center, style: const TextStyle(fontSize: 15)),
          ],
        );
      case _WriteState.confirm:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning_amber_rounded, size: 72, color: Colors.orange.shade600),
            const SizedBox(height: 16),
            Text(
              'La etiqueta ya contiene un EPC',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.orange.shade800, fontWeight: FontWeight.w600),
            ),
            if (detectedEpc != null) ...[
              const SizedBox(height: 6),
              Text(detectedEpc!,
                  style: TextStyle(fontSize: 12, fontFamily: 'monospace', color: Colors.grey.shade600)),
            ],
          ],
        );
      case _WriteState.writing:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 64, height: 64,
              child: CircularProgressIndicator(strokeWidth: 4, color: Color(0xFF833177)),
            ),
            const SizedBox(height: 20),
            Text(message ?? '', textAlign: TextAlign.center, style: const TextStyle(fontSize: 15)),
            if (detectedEpc != null) ...[
              const SizedBox(height: 6),
              Text('Etiqueta: $detectedEpc',
                  style: TextStyle(fontSize: 12, fontFamily: 'monospace', color: Colors.grey.shade600)),
            ],
          ],
        );
      case _WriteState.success:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, size: 72, color: Colors.green.shade600),
            const SizedBox(height: 16),
            Text(message ?? '', textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        );
      case _WriteState.error:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 72, color: Colors.red.shade600),
            const SizedBox(height: 16),
            Text(message ?? 'Ocurrió un error', textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.red.shade700)),
          ],
        );
    }
  }
}
