import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sekilas/main.dart'; // Import main.dart untuk mengakses sharedPreferencesProvider

// Key constants
class StorageKeys {
  static const String isLoggedIn = 'is_logged_in';
  static const String userRole = 'user_role';
  static const String schoolName = 'school_name';
  static const String teacherData = 'teacher_data';
  static const String parentData = 'parent_data';
  static const String studentsData = 'students_data';
}

// Provider for local storage service
final localStorageProvider = Provider<LocalStorageService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocalStorageService(prefs);
});

class LocalStorageService {
  final SharedPreferences _prefs;

  LocalStorageService(this._prefs);

  // Auth methods
  Future<void> setLoggedIn(bool value) async {
    await _prefs.setBool(StorageKeys.isLoggedIn, value);
  }

  bool isLoggedIn() {
    return _prefs.getBool(StorageKeys.isLoggedIn) ?? false;
  }

  Future<void> setUserRole(String role) async {
    await _prefs.setString(StorageKeys.userRole, role);
  }

  String? getUserRole() {
    return _prefs.getString(StorageKeys.userRole);
  }

  // School data
  Future<void> setSchoolName(String name) async {
    await _prefs.setString(StorageKeys.schoolName, name);
  }

  String? getSchoolName() {
    return _prefs.getString(StorageKeys.schoolName);
  }

  // Teacher data
  Future<void> setTeacherData(Map<String, dynamic> teacherData) async {
    await _prefs.setString(StorageKeys.teacherData, jsonEncode(teacherData));
  }

  Map<String, dynamic>? getTeacherData() {
    final data = _prefs.getString(StorageKeys.teacherData);
    if (data != null) {
      return jsonDecode(data) as Map<String, dynamic>;
    }
    return null;
  }

  // Parent data
  Future<void> setParentData(Map<String, dynamic> parentData) async {
    await _prefs.setString(StorageKeys.parentData, jsonEncode(parentData));
  }

  Map<String, dynamic>? getParentData() {
    final data = _prefs.getString(StorageKeys.parentData);
    if (data != null) {
      return jsonDecode(data) as Map<String, dynamic>;
    }
    return null;
  }

  // Student data
  Future<void> setStudentsData(List<Map<String, dynamic>> studentsData) async {
    await _prefs.setString(StorageKeys.studentsData, jsonEncode(studentsData));
  }

  List<Map<String, dynamic>>? getStudentsData() {
    final data = _prefs.getString(StorageKeys.studentsData);
    if (data != null) {
      final List<dynamic> jsonData = jsonDecode(data);
      return jsonData.cast<Map<String, dynamic>>();
    }
    return null;
  }

  // Add/update a single student
  Future<void> addOrUpdateStudent(Map<String, dynamic> student) async {
    final students = getStudentsData() ?? [];
    final studentId = student['id'];
    
    // Check if student exists
    final index = students.indexWhere((s) => s['id'] == studentId);
    
    if (index >= 0) {
      students[index] = student;
    } else {
      students.add(student);
    }
    
    await setStudentsData(students);
  }

  // Attendance data
  Future<void> saveAttendance(Map<String, dynamic> attendanceData) async {
    final key = 'attendance_${attendanceData['date']}';
    final existingData = _prefs.getString(key);
    
    List<dynamic> attendances = [];
    if (existingData != null) {
      attendances = jsonDecode(existingData);
    }
    
    // Check if attendance for student already exists
    final studentId = attendanceData['studentId'];
    final index = attendances.indexWhere((a) => a['studentId'] == studentId);
    
    if (index >= 0) {
      attendances[index] = attendanceData;
    } else {
      attendances.add(attendanceData);
    }
    
    await _prefs.setString(key, jsonEncode(attendances));
  }

  List<Map<String, dynamic>> getAttendanceByDate(String date) {
    final key = 'attendance_$date';
    final data = _prefs.getString(key);
    
    if (data != null) {
      final List<dynamic> jsonData = jsonDecode(data);
      return jsonData.cast<Map<String, dynamic>>();
    }
    
    return [];
  }
  
  // Metode tambahan untuk mendukung DatabaseService
  
  Future<List<Map<String, dynamic>>> getAttendanceRecords() async {
    final List<Map<String, dynamic>> allAttendances = [];
    
    // Mencari semua kunci yang dimulai dengan "attendance_"
    final keys = _prefs.getKeys().where((key) => key.startsWith('attendance_'));
    
    for (final key in keys) {
      final data = _prefs.getString(key);
      if (data != null) {
        final List<dynamic> jsonData = jsonDecode(data);
        allAttendances.addAll(jsonData.cast<Map<String, dynamic>>());
      }
    }
    
    return allAttendances;
  }
  
  Future<void> addOrUpdateAttendance(Map<String, dynamic> attendance) async {
    // Format tanggal: YYYY-MM-DD
    final dateStr = attendance['date'];
    final key = 'attendance_$dateStr';
    
    final existingData = _prefs.getString(key);
    List<dynamic> attendances = [];
    
    if (existingData != null) {
      attendances = jsonDecode(existingData);
    }
    
    // Cek apakah sudah ada data kehadiran untuk siswa tersebut
    final studentId = attendance['studentId'];
    final index = attendances.indexWhere((a) => a['studentId'] == studentId);
    
    if (index >= 0) {
      attendances[index] = attendance;
    } else {
      attendances.add(attendance);
    }
    
    await _prefs.setString(key, jsonEncode(attendances));
  }
  
  // Metode untuk permission (izin)
  
  Future<List<Map<String, dynamic>>> getPermissions() async {
    final data = _prefs.getString('permissions');
    if (data != null) {
      final List<dynamic> jsonData = jsonDecode(data);
      return jsonData.cast<Map<String, dynamic>>();
    }
    return [];
  }
  
  Future<void> addOrUpdatePermission(Map<String, dynamic> permission) async {
    final permissions = await getPermissions();
    
    // Cek apakah permission dengan id yang sama sudah ada
    final permissionId = permission['id'];
    final index = permissions.indexWhere((p) => p['id'] == permissionId);
    
    if (index >= 0) {
      permissions[index] = permission;
    } else {
      permissions.add(permission);
    }
    
    await _prefs.setString('permissions', jsonEncode(permissions));
  }

  // Clear auth data (for logout)
  // Metode untuk mendukung DatabaseService
  Future<void> removeTeacherData() async {
    await _prefs.remove(StorageKeys.teacherData);
  }
  
  Future<void> removeParentData() async {
    await _prefs.remove(StorageKeys.parentData);
  }
  
  Future<List<Map<String, dynamic>>> getAllStudents() async {
    return getStudentsData() ?? [];
  }
  
  Future<void> deleteStudent(String id) async {
    final students = getStudentsData() ?? [];
    students.removeWhere((student) => student['id'].toString() == id);
    await setStudentsData(students);
  }

  Future<void> clearAll() async {
    // Only clear auth-related data but keep school name and student data
    await _prefs.remove(StorageKeys.isLoggedIn);
    await _prefs.remove(StorageKeys.userRole);
    await _prefs.remove(StorageKeys.teacherData);
    await _prefs.remove(StorageKeys.parentData);
    // Note: We don't clear school name and student data on logout
    // This allows us to keep this data for next login
  }
}