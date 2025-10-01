import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database.dart';

// Provider untuk mendapatkan semua siswa berdasarkan kelas
final studentsProvider = StreamProvider.family<List<Student>, String>((ref, className) {
  final database = ref.watch(appDatabaseProvider);
  return database.watchStudentsByClass(className);
});

// Provider untuk menambah siswa
final addStudentProvider = Provider<Future<int> Function(StudentsCompanion)>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return database.insertStudent;
});

// Provider untuk update siswa
final updateStudentProvider = Provider<Future<bool> Function(Student)>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return database.updateStudent;
});

// Provider untuk delete siswa
final deleteStudentProvider = Provider<Future<int> Function(int)>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return database.deleteStudent;
});

// Provider untuk current class name
final currentClassProvider = StateProvider<String>((ref) => '');
