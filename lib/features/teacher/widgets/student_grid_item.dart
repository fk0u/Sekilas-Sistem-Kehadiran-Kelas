import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/database/database.dart';

enum AttendanceStatus { hadir, izin, sakit, alpa, none }

class StudentGridItem extends StatelessWidget {
  final Student student;
  final AttendanceStatus status;
  final VoidCallback onTap;

  const StudentGridItem({
    super.key,
    required this.student,
    required this.status,
    required this.onTap,
  });

  Color _getStatusColor() {
    switch (status) {
      case AttendanceStatus.hadir:
        return AppTheme.statusHadir;
      case AttendanceStatus.izin:
        return AppTheme.statusIzin;
      case AttendanceStatus.sakit:
        return AppTheme.statusSakit;
      case AttendanceStatus.alpa:
        return AppTheme.statusAlpa;
      case AttendanceStatus.none:
        return Colors.grey.shade300;
    }
  }

  IconData _getStatusIcon() {
    switch (status) {
      case AttendanceStatus.hadir:
        return Icons.check_circle;
      case AttendanceStatus.izin:
        return Icons.assignment;
      case AttendanceStatus.sakit:
        return Icons.medical_services;
      case AttendanceStatus.alpa:
        return Icons.cancel;
      case AttendanceStatus.none:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: status == AttendanceStatus.none ? 1 : 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _getStatusColor(),
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Avatar
              Stack(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: _getStatusColor().withOpacity(0.2),
                    child: Text(
                      student.name.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(),
                      ),
                    ),
                  ),
                  if (status != AttendanceStatus.none)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Icon(
                          _getStatusIcon(),
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Name
              Text(
                student.name,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
