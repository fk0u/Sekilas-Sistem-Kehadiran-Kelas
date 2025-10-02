import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database.dart';
import '../../../core/storage/local_storage.dart';

// Provider untuk attendance berdasarkan tanggal
final attendancesProvider = FutureProvider.family<List<Map<String, dynamic>>, DateTime>((ref, date) {
  final database = ref.watch(databaseProvider);
  return database.getAttendancesByDate(date);
});

// Provider untuk tanggal yang sedang dipilih
final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

// Provider untuk attendance status map (studentId -> status)
final attendanceMapProvider = StateProvider<Map<String, String>>((ref) => {});

// Provider untuk menambah/update attendance
final saveAttendanceProvider = Provider<Future<void> Function(String, DateTime, String, String?)>((ref) {
  final database = ref.watch(databaseProvider);
  return (studentId, date, status, notes) async {
    await database.saveAttendance({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'studentId': studentId,
      'date': date.toIso8601String(),
      'status': status,
      'notes': notes,
      'createdAt': DateTime.now().toIso8601String(),
    });
  };
});
