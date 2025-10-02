import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import '../../../core/database/database.dart';
import '../../../core/theme/app_theme.dart';

class PermissionDetailScreen extends StatelessWidget {
  final Permission permission;

  const PermissionDetailScreen({
    super.key,
    required this.permission,
  });

  Color _getTypeColor() {
    switch (permission.permissionType) {
      case 'izin':
        return AppTheme.statusIzin;
      case 'sakit':
        return AppTheme.statusSakit;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon() {
    switch (permission.permissionType) {
      case 'izin':
        return Icons.assignment;
      case 'sakit':
        return Icons.medical_services;
      default:
        return Icons.info;
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Izin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fitur share - Coming Soon')),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // QR Code Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: QrImageView(
                      data: permission.qrCode,
                      version: QrVersions.auto,
                      size: 200,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tunjukkan QR ini ke guru',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Type Card
          Card(
            child: ListTile(
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _getTypeColor().withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getTypeIcon(),
                  color: _getTypeColor(),
                ),
              ),
              title: const Text('Jenis'),
              subtitle: Text(
                permission.permissionType == 'izin' ? 'Izin' : 'Sakit',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: _getTypeColor(),
                ),
              ),
            ),
          ),

          // Date Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_month,
                        color: _getTypeColor(),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Periode',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildDateRow('Mulai', permission.startDate),
                  const Divider(height: 24),
                  _buildDateRow('Selesai', permission.endDate),
                ],
              ),
            ),
          ),

          // Reason Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.description,
                        color: _getTypeColor(),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Alasan',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    permission.reason ?? '-',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),

          // Status Card
          Card(
            child: ListTile(
              leading: Icon(
                permission.isUsed ? Icons.check_circle : Icons.pending,
                color: permission.isUsed ? AppTheme.statusHadir : Colors.orange,
                size: 32,
              ),
              title: const Text('Status'),
              subtitle: Text(
                permission.isUsed ? 'Sudah digunakan' : 'Belum digunakan',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: permission.isUsed ? AppTheme.statusHadir : Colors.orange,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Save QR Button
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Simpan QR - Coming Soon')),
              );
            },
            icon: const Icon(Icons.download),
            label: const Text('Simpan QR Code'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRow(String label, DateTime date) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
        Text(
          _formatDate(date),
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
