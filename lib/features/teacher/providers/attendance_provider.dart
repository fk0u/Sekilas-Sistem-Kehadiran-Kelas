import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../../core/database/database.dart';

// Provider untuk attendance berdasarkan tanggal
final attendancesProvider = StreamProvider.family<List<Attendance>, DateTime>((ref, date) {
  final database = ref.watch(appDatabaseProvider);
  return database.watchAttendancesByDate(date);
});

// Provider untuk tanggal yang sedang dipilih
final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

// Provider untuk attendance status map (studentId -> status)
final attendanceMapProvider = StateProvider<Map<int, String>>((ref) => {});

// Provider untuk menambah/update attendance
final saveAttendanceProvider = Provider<Future<void> Function(int, DateTime, String, String?)>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return (studentId, date, status, notes) async {
    await database.insertAttendance(
      AttendancesCompanion.insert(
        studentId: studentId,
        date: date,
        status: status,
        notes: notes != null ? drift.Value(notes) : const drift.Value.absent(),
      ),
    );
  };
});
