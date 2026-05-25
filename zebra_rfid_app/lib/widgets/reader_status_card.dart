import 'package:flutter/material.dart';
import '../models/reader_info.dart';

class ReaderStatusCard extends StatelessWidget {
  final bool isConnected;
  final ReaderInfo? info;
  final bool isLoading;
  final VoidCallback onConnect;
  final VoidCallback onDisconnect;

  const ReaderStatusCard({
    super.key,
    required this.isConnected,
    required this.info,
    required this.isLoading,
    required this.onConnect,
    required this.onDisconnect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.bluetooth_searching,
                  color: isConnected ? Colors.green : Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text('Lector RFID', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const Spacer(),
                _StatusChip(isConnected: isConnected),
              ],
            ),
            const Divider(height: 20),
            if (isConnected && info != null) ...[
              _InfoRow(icon: Icons.devices, label: 'Modelo', value: info!.model),
              _InfoRow(icon: Icons.badge, label: 'Nombre', value: info!.name),
              _InfoRow(icon: Icons.fingerprint, label: 'Serie', value: info!.serialNumber),
              _InfoRow(icon: Icons.memory, label: 'Firmware', value: info!.firmware),
              _InfoRow(
                icon: Icons.settings_input_antenna,
                label: 'Antenas',
                value: '${info!.numAntennas}',
              ),
              _BatteryRow(level: info!.batteryLevel, isCharging: info!.isCharging),
            ] else if (!isConnected) ...[
              const Text(
                'Sin lector conectado. Empareja la antena Zebra en\nAjustes > Bluetooth y luego toca Conectar.',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ] else
              const Center(child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: CircularProgressIndicator(strokeWidth: 2),
              )),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: isLoading
                  ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                  : FilledButton.icon(
                      onPressed: isConnected ? onDisconnect : onConnect,
                      icon: Icon(isConnected ? Icons.link_off : Icons.bluetooth_searching),
                      label: Text(isConnected ? 'Desconectar' : 'Conectar lector'),
                      style: FilledButton.styleFrom(
                        backgroundColor: isConnected
                            ? Colors.red.shade700
                            : const Color(0xFF833177),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final bool isConnected;
  const _StatusChip({required this.isConnected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isConnected ? Colors.green.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isConnected ? Colors.green : Colors.grey.shade400,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: isConnected ? Colors.green : Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            isConnected ? 'Conectado' : 'Desconectado',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isConnected ? Colors.green.shade700 : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 6),
          Text('$label: ', style: const TextStyle(fontSize: 13, color: Colors.grey)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _BatteryRow extends StatelessWidget {
  final int level;
  final bool isCharging;
  const _BatteryRow({required this.level, required this.isCharging});

  @override
  Widget build(BuildContext context) {
    if (level < 0) return const SizedBox.shrink();

    final color = level > 50
        ? Colors.green
        : level > 20
            ? Colors.orange
            : Colors.red;

    final icon = isCharging
        ? Icons.battery_charging_full
        : level > 75
            ? Icons.battery_full
            : level > 50
                ? Icons.battery_5_bar
                : level > 25
                    ? Icons.battery_3_bar
                    : Icons.battery_1_bar;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text('Batería: ', style: const TextStyle(fontSize: 13, color: Colors.grey)),
          Text(
            '$level%${isCharging ? ' ⚡' : ''}',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: level / 100,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation(color),
                minHeight: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
