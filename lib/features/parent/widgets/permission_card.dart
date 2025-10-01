import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/database/database.dart';
import 'package:intl/intl.dart';

class PermissionCard extends StatelessWidget {
  final Permission permission;
  final VoidCallback? onTap;

  const PermissionCard({
    super.key,
    required this.permission,
    this.onTap,
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
    return DateFormat('dd MMM yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _getTypeColor().withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getTypeIcon(),
                  color: _getTypeColor(),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      permission.permissionType == 'izin' ? 'Izin' : 'Sakit',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: _getTypeColor(),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_formatDate(permission.startDate)} - ${_formatDate(permission.endDate)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      permission.reason ?? '',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: permission.isUsed 
                      ? AppTheme.statusHadir.withOpacity(0.2)
                      : Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  permission.isUsed ? 'Terpakai' : 'Aktif',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: permission.isUsed 
                        ? AppTheme.statusHadir
                        : Colors.orange,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
