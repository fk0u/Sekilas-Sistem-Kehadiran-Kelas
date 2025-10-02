import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/local_storage.dart';

// Enums
enum UserRole { guru, orangTua }
enum AttendanceStatus { hadir, izin, sakit, alpa }

// Provider for the database (now using SharedPreferences via LocalStorage)
final databaseProvider = Provider<DatabaseService>((ref) {
  final localStorage = ref.watch(localStorageProvider);
  return DatabaseService(localStorage);
});

class DatabaseService {
  final LocalStorageService _localStorage;
  
  DatabaseService(this._localStorage);
  
  // Teacher methods
  Future<Map<String, dynamic>?> getTeacher() async {
    return _localStorage.getTeacherData();
  }
  
  Future<void> saveTeacher(Map<String, dynamic> teacher) async {
    await _localStorage.setTeacherData(teacher);
  }
  
  Future<void> deleteTeacher() async {
    await _localStorage.removeTeacherData();
  }
  
  // Student methods
  Future<List<Map<String, dynamic>>> getAllStudents() async {
    return _localStorage.getAllStudents();
  }
  
  Future<Map<String, dynamic>?> getStudent(String id) async {
    final students = await _localStorage.getAllStudents();
    return students.firstWhere((s) => s['id'] == id, orElse: () => {});
  }
  
  Future<void> saveStudent(Map<String, dynamic> student) async {
    await _localStorage.addOrUpdateStudent(student);
  }
  
  Future<void> deleteStudent(String id) async {
    await _localStorage.deleteStudent(id);
  }
  
  // Parent methods
  Future<Map<String, dynamic>?> getParent() async {
    return _localStorage.getParentData();
  }
  
  Future<void> saveParent(Map<String, dynamic> parent) async {
    await _localStorage.setParentData(parent);
  }
  
  // Attendance methods
  Future<List<Map<String, dynamic>>> getAttendancesByDate(DateTime date) async {
    final allAttendances = await _localStorage.getAttendanceRecords();
    final dateStr = '${date.year}-${date.month}-${date.day}';
    return allAttendances
        .where((a) => a['date']?.toString().startsWith(dateStr) ?? false)
        .toList();
  }
  
  Future<void> saveAttendance(Map<String, dynamic> attendance) async {
    await _localStorage.addOrUpdateAttendance(attendance);
  }
  
  // Permission methods
  Future<List<Map<String, dynamic>>> getAllPermissions() async {
    return _localStorage.getPermissions();
  }
  
  Future<Map<String, dynamic>?> getPermissionByQrCode(String qrCode) async {
    final permissions = await _localStorage.getPermissions();
    return permissions.firstWhere(
      (p) => p['qrCode'] == qrCode,
      orElse: () => {},
    );
  }
  
  Future<void> savePermission(Map<String, dynamic> permission) async {
    await _localStorage.addOrUpdatePermission(permission);
  }
  
  // Settings methods
  Future<String?> getSchoolName() async {
    return _localStorage.getSchoolName();
  }
  
  Future<void> setSchoolName(String name) async {
    await _localStorage.setSchoolName(name);
  }
}