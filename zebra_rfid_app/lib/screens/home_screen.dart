import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/reader_info.dart';
import '../services/zebra_rfid_service.dart';
import '../widgets/reader_status_card.dart';
import 'conteo_screen.dart';
import 'buscar_screen.dart';
import 'grabado_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _rfid = ZebraRfidService();

  bool _isConnected = false;
  bool _isLoading = false;
  ReaderInfo? _readerInfo;

  Map<String, int>? _powerInfo;
  bool _powerLoading = false;

  @override
  void initState() {
    super.initState();
    _rfid.init();
    _requestPermissions();
  }

  @override
  void dispose() {
    _rfid.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------------
  // Permissions
  // ------------------------------------------------------------------

  Future<bool> _requestPermissions() async {
    final perms = defaultTargetPlatform == TargetPlatform.iOS
        ? [Permission.bluetooth, Permission.locationWhenInUse]
        : [Permission.bluetoothScan, Permission.bluetoothConnect, Permission.locationWhenInUse];

    final statuses = await perms.request();
    return statuses.values.every(
      (s) => s == PermissionStatus.granted || s == PermissionStatus.limited,
    );
  }

  // ------------------------------------------------------------------
  // Connect / Disconnect
  // ------------------------------------------------------------------

  Future<void> _connect() async {
    if (_isLoading) return; // prevent double-tap
    setState(() => _isLoading = true);
    try {
      final granted = await _requestPermissions();
      if (!granted) {
        _showError('Permisos de Bluetooth/Ubicación necesarios para conectar el lector');
        return;
      }
      await _rfid.connect();
      final info = await _rfid.getReaderInfo();
      if (mounted) {
        setState(() {
          _isConnected = true;
          _readerInfo = info;
        });
      }
      if (defaultTargetPlatform == TargetPlatform.iOS) _loadPower();
    } on PlatformException catch (e) {
      _showError(e.message ?? 'Error al conectar');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _disconnect() async {
    if (_isLoading) return; // prevent double-tap
    setState(() => _isLoading = true);
    try {
      await _rfid.disconnect();
      setState(() {
        _isConnected = false;
        _readerInfo = null;
        _powerInfo = null;
      });
    } on PlatformException catch (e) {
      _showError(e.message ?? 'Error al desconectar');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadPower() async {
    if (!_isConnected) return;
    setState(() => _powerLoading = true);
    try {
      await _rfid.stopInventory();
      await Future.delayed(const Duration(milliseconds: 100));
      final info = await _rfid.getAntennaPower();
      if (mounted) setState(() => _powerInfo = info);
    } on PlatformException catch (e) {
      _showError(e.message ?? 'Error al leer potencia');
    } finally {
      if (mounted) setState(() => _powerLoading = false);
    }
  }

  Future<void> _setPower(int newPower) async {
    setState(() => _powerLoading = true);
    try {
      final applied = await _rfid.setAntennaPower(newPower);
      await _loadPower();
      if (mounted && applied != newPower) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('El lector aplicó $applied (se pidió $newPower)'),
        ));
      }
    } on PlatformException catch (e) {
      _showError(e.message ?? 'Error al configurar potencia');
      if (mounted) setState(() => _powerLoading = false);
    }
  }

  void _showPowerDialog() {
    if (_powerInfo == null) return;
    final min = _powerInfo!['minPower']!;
    final max = _powerInfo!['maxPower']!;
    final step = _powerInfo!['powerStep']!;
    final controller = TextEditingController(text: '${_powerInfo!['currentPower']}');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Configurar potencia'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mín: $min · Máx: $max · Paso: $step',
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Nueva potencia',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              final val = int.tryParse(controller.text);
              if (val == null || val < min || val > max) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Valor inválido (debe ser entre $min y $max)'),
                ));
                return;
              }
              Navigator.pop(ctx);
              _setPower(val);
            },
            child: const Text('Aplicar'),
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
  // Navigate
  // ------------------------------------------------------------------

  void _goToConteo() {
    if (!_isConnected) { _showError('Conecta un lector primero'); return; }
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => ConteoScreen(rfid: _rfid),
    ));
  }

  void _goToBuscar() {
    if (!_isConnected) { _showError('Conecta un lector primero'); return; }
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => BuscarScreen(rfid: _rfid),
    ));
  }

  void _goToGrabado() {
    if (!_isConnected) { _showError('Conecta un lector primero'); return; }
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => GrabadoScreen(rfid: _rfid),
    ));
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
        title: const Row(
          children: [
            Icon(Icons.wifi_tethering, color: Colors.white),
            SizedBox(width: 10),
            Text('RFID Búsqueda y Conteo', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Reader card ──────────────────────────────────────
              ReaderStatusCard(
                isConnected: _isConnected,
                info: _readerInfo,
                isLoading: _isLoading,
                onConnect: _connect,
                onDisconnect: _disconnect,
              ),
              if (_isConnected && defaultTargetPlatform == TargetPlatform.iOS) ...
                [
                  const SizedBox(height: 16),
                  _PowerCard(
                    powerInfo: _powerInfo,
                    isLoading: _powerLoading,
                    onEdit: _showPowerDialog,
                    onRefresh: _loadPower,
                  ),
                ],
              const SizedBox(height: 32),

              // ── Section title ────────────────────────────────────
              const Text(
                'Funciones',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A2340),
                ),
              ),
              const SizedBox(height: 14),

              // ── Action buttons (same height) ─────────────────────
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _ActionCard(
                        icon: Icons.inventory_2_outlined,
                        label: 'Conteo',
                        description: 'Escanea y cuenta artículos',
                        color: const Color(0xFF833177),
                        enabled: _isConnected,
                        onTap: _goToConteo,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _ActionCard(
                        icon: Icons.location_searching,
                        label: 'Buscar',
                        description: 'Localiza un artículo',
                        color: const Color(0xFF0070C0),
                        enabled: _isConnected,
                        onTap: _goToBuscar,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _ActionCard(
                        icon: Icons.edit_note,
                        label: 'Grabado',
                        description: 'Graba un nuevo EPC en la etiqueta',
                        color: const Color(0xFF2E7D32),
                        enabled: _isConnected,
                        onTap: _goToGrabado,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Tip ──────────────────────────────────────────────
              if (!_isConnected)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.amber.shade700, size: 20),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Conecta el lector RFID para habilitar las funciones.',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Power card
// ---------------------------------------------------------------------------

class _PowerCard extends StatelessWidget {
  final Map<String, int>? powerInfo;
  final bool isLoading;
  final VoidCallback onEdit;
  final VoidCallback onRefresh;

  const _PowerCard({
    required this.powerInfo,
    required this.isLoading,
    required this.onEdit,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final current = powerInfo?['currentPower'];
    final min = powerInfo?['minPower'];
    final max = powerInfo?['maxPower'];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF833177).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.settings_input_antenna, color: Color(0xFF833177), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Potencia de antena',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A2340))),
                const SizedBox(height: 2),
                isLoading
                    ? const SizedBox(height: 14, width: 14, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(
                        current != null
                            ? '$current dBm  (rango $min – $max)'
                            : 'No disponible',
                        style: TextStyle(
                          fontSize: 12,
                          color: current != null ? Colors.grey.shade700 : Colors.grey.shade400,
                        ),
                      ),
                if (!isLoading && max != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Potencia máxima soportada: $max dBm',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            color: Colors.grey.shade500,
            tooltip: 'Actualizar',
            onPressed: isLoading ? null : onRefresh,
          ),
          IconButton(
            icon: const Icon(Icons.edit, size: 20),
            color: const Color(0xFF833177),
            tooltip: 'Cambiar potencia',
            onPressed: (isLoading || current == null) ? null : onEdit,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Action card button
// ---------------------------------------------------------------------------

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final Color color;
  final bool enabled;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.description,
    required this.color,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = enabled ? color : Colors.grey.shade400;

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: enabled ? 1.0 : 0.55,
        child: Container(
          decoration: BoxDecoration(
            color: effectiveColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: enabled
                ? [BoxShadow(color: effectiveColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
                : null,
          ),
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.white),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
