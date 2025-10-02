import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Key constants
class StorageKeys {
  static const String isLoggedIn = 'is_logged_in';
  static const String userRole = 'user_role';
  static const String schoolName = 'school_name';
  static const String teacherData = 'teacher_data';
  static const String parentData = 'parent_data';
  static const String studentsData = 'students_data';
}

// Provider for SharedPreferences
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize sharedPreferencesProvider in main.dart');
});

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

  // Clear auth data (for logout)
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