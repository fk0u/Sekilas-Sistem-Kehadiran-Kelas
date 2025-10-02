import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database.dart';

// Model untuk statistik attendance
class AttendanceStats {
  final int totalHadir;
  final int totalIzin;
  final int totalSakit;
  final int totalAlpa;
  final int totalSiswa;
  
  AttendanceStats({
    required this.totalHadir,
    required this.totalIzin,
    required this.totalSakit,
    required this.totalAlpa,
    required this.totalSiswa,
  });

  int get totalPresent => totalHadir + totalIzin + totalSakit;
  double get percentageHadir => totalSiswa > 0 ? (totalHadir / totalSiswa) * 100 : 0;
  double get percentageIzin => totalSiswa > 0 ? (totalIzin / totalSiswa) * 100 : 0;
  double get percentageSakit => totalSiswa > 0 ? (totalSakit / totalSiswa) * 100 : 0;
  double get percentageAlpa => totalSiswa > 0 ? (totalAlpa / totalSiswa) * 100 : 0;
}

// Provider untuk mendapatkan statistik attendance
final attendanceStatsProvider = FutureProvider.family<AttendanceStats, DateTimeRange>((ref, dateRange) async {
  final database = ref.watch(appDatabaseProvider);
  final attendances = await database.getAttendancesByDateRange(
    dateRange.start,
    dateRange.end,
  );

  int hadir = 0, izin = 0, sakit = 0, alpa = 0;

  for (var attendance in attendances) {
    switch (attendance.status) {
      case 'hadir':
        hadir++;
        break;
      case 'izin':
        izin++;
        break;
      case 'sakit':
        sakit++;
        break;
      case 'alpa':
        alpa++;
        break;
    }
  }

  // Get total students
  final teacher = await database.getTeacher();
  final students = teacher != null 
    ? await database.getStudentsByClass(teacher.className)
    : <Student>[];

  return AttendanceStats(
    totalHadir: hadir,
    totalIzin: izin,
    totalSakit: sakit,
    totalAlpa: alpa,
    totalSiswa: students.length,
  );
});

// Provider untuk date range selection
final reportDateRangeProvider = StateProvider<DateTimeRange>((ref) {
  final now = DateTime.now();
  return DateTimeRange(
    start: DateTime(now.year, now.month, 1),
    end: now,
  );
});
