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
      });
    } on PlatformException catch (e) {
      _showError(e.message ?? 'Error al desconectar');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
