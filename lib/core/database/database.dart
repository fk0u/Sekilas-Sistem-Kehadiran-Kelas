import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../storage/local_storage.dart';

// Enums untuk menjaga kompatibilitas dengan kode lama
enum UserRole { guru, orangTua }
enum AttendanceStatus { none, hadir, izin, sakit, alpa }

// Models as Map<String, dynamic> to replace drift models
// Ini untuk memudahkan migrasi dari SQLite ke SharedPreferences

// Teacher Model
class Teacher {
  final int id;
  final String name;
  final String className;
  final DateTime createdAt;
  
  Teacher({
    required this.id,
    required this.name, 
    required this.className,
    required this.createdAt,
  });
  
  // Factory method untuk konversi dari Map (SharedPreferences)
  factory Teacher.fromMap(Map<String, dynamic> map) {
    return Teacher(
      id: map['id'],
      name: map['name'],
      className: map['className'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
  
  // Method untuk konversi ke Map (SharedPreferences)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'className': className,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

// Student Model
class Student {
  final int id;
  final String name;
  final String className;
  final DateTime createdAt;
  
  Student({
    required this.id,
    required this.name,
    required this.className,
    required this.createdAt,
  });
  
  // Factory method untuk konversi dari Map (SharedPreferences)
  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'],
      name: map['name'],
      className: map['className'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
  
  // Method untuk konversi ke Map (SharedPreferences)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'className': className,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

// Parent Model
class Parent {
  final int id;
  final int studentId;
  final String name;
  final String? phone;
  final DateTime createdAt;
  
  Parent({
    required this.id,
    required this.studentId,
    required this.name,
    this.phone,
    required this.createdAt,
  });
  
  // Factory method untuk konversi dari Map (SharedPreferences)
  factory Parent.fromMap(Map<String, dynamic> map) {
    return Parent(
      id: map['id'],
      studentId: map['studentId'],
      name: map['name'],
      phone: map['phone'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
  
  // Method untuk konversi ke Map (SharedPreferences)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'name': name,
      'phone': phone,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

// Permission Model
class Permission {
  final int id;
  final int studentId;
  final int parentId;
  final String reason;
  final DateTime startDate;
  final DateTime endDate;
  final String qrCode;
  final bool isUsed;
  final DateTime createdAt;
  
  Permission({
    required this.id,
    required this.studentId,
    required this.parentId,
    required this.reason,
    required this.startDate,
    required this.endDate,
    required this.qrCode,
    required this.isUsed,
    required this.createdAt,
  });
  
  // Factory method untuk konversi dari Map (SharedPreferences)
  factory Permission.fromMap(Map<String, dynamic> map) {
    return Permission(
      id: map['id'],
      studentId: map['studentId'],
      parentId: map['parentId'],
      reason: map['reason'],
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
      qrCode: map['qrCode'],
      isUsed: map['isUsed'] ?? false,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
  
  // Method untuk konversi ke Map (SharedPreferences)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'parentId': parentId,
      'reason': reason,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'qrCode': qrCode,
      'isUsed': isUsed,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

// Provider for the database (now using SharedPreferences via LocalStorage)
final databaseProvider = Provider<DatabaseService>((ref) {
  final localStorage = ref.watch(localStorageProvider);
  return DatabaseService(localStorage);
});

// Alias untuk provider database untuk kompatibilitas dengan kode lama
final appDatabaseProvider = databaseProvider;

class DatabaseService {
  final LocalStorageService _localStorage;
  
  DatabaseService(this._localStorage);
  
  // Teacher methods
  Future<Teacher?> getTeacher() async {
    final data = await _localStorage.getTeacherData();
    if (data != null && data.isNotEmpty) {
      return Teacher.fromMap(data);
    }
    return null;
  }
  
  Future<void> saveTeacher(Map<String, dynamic> teacher) async {
    await _localStorage.setTeacherData(teacher);
  }
  
  Future<void> updateTeacher(Teacher teacher) async {
    await _localStorage.setTeacherData(teacher.toMap());
  }
  
  Future<void> deleteTeacher() async {
    await _localStorage.removeTeacherData();
  }
  
  // Student methods
  Future<List<Student>> getAllStudents() async {
    final data = await _localStorage.getAllStudents();
    return data.map((e) => Student.fromMap(e)).toList();
  }
  
  Future<List<Student>> getStudentsByClass(String className) async {
    final allStudents = await getAllStudents();
    return allStudents.where((s) => s.className == className).toList();
  }
  
  Future<Student?> getStudentById(int id) async {
    final students = await _localStorage.getAllStudents();
    final studentData = students.firstWhere((s) => s['id'] == id, orElse: () => {});
    if (studentData.isNotEmpty) {
      return Student.fromMap(studentData);
    }
    return null;
  }
  
  Future<Student?> getStudent(String id) async {
    return getStudentById(int.parse(id));
  }
  
  Future<void> saveStudent(Map<String, dynamic> student) async {
    await _localStorage.addOrUpdateStudent(student);
  }
  
  Future<int> insertStudent(Map<String, dynamic> student) async {
    student['id'] = DateTime.now().millisecondsSinceEpoch;
    student['createdAt'] = DateTime.now().toIso8601String();
    await _localStorage.addOrUpdateStudent(student);
    return student['id'];
  }
  
  Future<bool> updateStudent(Student student) async {
    await _localStorage.addOrUpdateStudent(student.toMap());
    return true;
  }
  
  Future<void> deleteStudent(String id) async {
    await _localStorage.deleteStudent(id);
  }
  
  Future<int> deleteStudentById(int id) async {
    await _localStorage.deleteStudent(id.toString());
    return 1;
  }
  
  // Parent methods
  Future<Parent?> getParent() async {
    final data = await _localStorage.getParentData();
    if (data != null && data.isNotEmpty) {
      return Parent.fromMap(data);
    }
    return null;
  }
  
  Future<void> saveParent(Map<String, dynamic> parent) async {
    await _localStorage.setParentData(parent);
  }
  
  Stream<List<Permission>> watchPermissionsByParent(int parentId) async* {
    // Initial data
    yield await getPermissionsByParent(parentId);
    
    // In a real app, we would set up a listener for changes
    // but since SharedPreferences doesn't support observers,
    // this is a one-time emission
  }
  
  Future<List<Permission>> getPermissionsByParent(int parentId) async {
    final permissions = await _localStorage.getPermissions();
    return permissions
      .where((p) => p['parentId'] == parentId)
      .map((p) => Permission.fromMap(p))
      .toList();
  }
  
  Stream<List<Student>> watchStudentsByClass(String className) async* {
    // Initial data
    yield await getStudentsByClass(className);
    
    // In a real app, we would set up a listener for changes
    // but since SharedPreferences doesn't support observers,
    // this is a one-time emission
  }
  
  // Attendance methods
  Future<List<Map<String, dynamic>>> getAttendancesByDate(DateTime date) async {
    final dateStr = '${date.year}-${date.month}-${date.day}';
    return _localStorage.getAttendanceByDate(dateStr);
  }
  
  Future<List<Map<String, dynamic>>> getAttendancesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final allAttendances = await _localStorage.getAttendanceRecords();
    
    return allAttendances.where((a) {
      final attendanceDate = DateTime.parse(a['date']);
      return attendanceDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
             attendanceDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }
  
  Future<void> saveAttendance(Map<String, dynamic> attendance) async {
    await _localStorage.addOrUpdateAttendance(attendance);
  }
  
  Future<int> insertAttendance(Map<String, dynamic> attendance) async {
    attendance['id'] = DateTime.now().millisecondsSinceEpoch;
    attendance['createdAt'] = DateTime.now().toIso8601String();
    await _localStorage.addOrUpdateAttendance(attendance);
    return attendance['id'];
  }
  
  // Permission methods
  Future<List<Permission>> getAllPermissions() async {
    final data = await _localStorage.getPermissions();
    return data.map((e) => Permission.fromMap(e)).toList();
  }
  
  Future<Permission?> getPermissionByQrCode(String qrCode) async {
    final permissions = await _localStorage.getPermissions();
    final permissionData = permissions.firstWhere(
      (p) => p['qrCode'] == qrCode,
      orElse: () => {},
    );
    
    if (permissionData.isNotEmpty) {
      return Permission.fromMap(permissionData);
    }
    
    return null;
  }
  
  Future<void> savePermission(Map<String, dynamic> permission) async {
    await _localStorage.addOrUpdatePermission(permission);
  }
  
  Future<int> insertPermission(Map<String, dynamic> permission) async {
    permission['id'] = DateTime.now().millisecondsSinceEpoch;
    permission['createdAt'] = DateTime.now().toIso8601String();
    permission['isUsed'] = false;
    await _localStorage.addOrUpdatePermission(permission);
    return permission['id'];
  }
  
  Future<bool> updatePermission(Permission permission) async {
    await _localStorage.addOrUpdatePermission(permission.toMap());
    return true;
  }
  
  // Settings methods
  Future<String?> getSchoolName() async {
    return _localStorage.getSchoolName();
  }
  
  Future<void> setSchoolName(String name) async {
    await _localStorage.setSchoolName(name);
  }
}