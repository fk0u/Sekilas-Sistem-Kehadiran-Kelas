import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'database.g.dart';

// Enums
enum UserRole { guru, orangTua }
enum AttendanceStatus { hadir, izin, sakit, alpa }

// Tables
class Teachers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get className => text().withLength(min: 1, max: 20)();
  TextColumn get pin => text().nullable().withLength(min: 4, max: 6)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Students extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get className => text().withLength(min: 1, max: 20)();
  TextColumn get photoPath => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Parents extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get studentId => integer().references(Students, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get phone => text().nullable().withLength(max: 20)();
  TextColumn get pin => text().nullable().withLength(min: 4, max: 6)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Attendances extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get studentId => integer().references(Students, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get date => dateTime()();
  TextColumn get status => text()(); // hadir, izin, sakit, alpa
  TextColumn get notes => text().nullable()();
  IntColumn get permissionId => integer().nullable().references(Permissions, #id, onDelete: KeyAction.setNull)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
}

class Permissions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get studentId => integer().references(Students, #id, onDelete: KeyAction.cascade)();
  IntColumn get parentId => integer().references(Parents, #id, onDelete: KeyAction.cascade)();
  TextColumn get permissionType => text()(); // izin, sakit
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime()();
  TextColumn get reason => text().nullable()();
  TextColumn get attachmentPath => text().nullable()();
  TextColumn get qrCode => text()();
  BoolColumn get isUsed => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class AppSettings extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get key => text().unique()();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [
  Teachers,
  Students,
  Parents,
  Attendances,
  Permissions,
  AppSettings,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // Teacher queries
  Future<List<Teacher>> getAllTeachers() => select(teachers).get();
  Future<Teacher?> getTeacher() => select(teachers).getSingleOrNull();
  Future<int> insertTeacher(TeachersCompanion teacher) => into(teachers).insert(teacher);
  Future<bool> updateTeacher(Teacher teacher) => update(teachers).replace(teacher);
  Future<int> deleteTeacher(int id) => (delete(teachers)..where((t) => t.id.equals(id))).go();

  // Student queries
  Future<List<Student>> getAllStudents() {
    return (select(students)..orderBy([(t) => OrderingTerm.asc(t.name)])).get();
  }
  
  Future<List<Student>> getStudentsByClass(String className) {
    return (select(students)
      ..where((t) => t.className.equals(className))
      ..orderBy([(t) => OrderingTerm.asc(t.name)])).get();
  }
  
  Stream<List<Student>> watchStudentsByClass(String className) {
    return (select(students)
      ..where((t) => t.className.equals(className))
      ..orderBy([(t) => OrderingTerm.asc(t.name)])).watch();
  }
  
  Future<Student?> getStudent(int id) {
    return (select(students)..where((t) => t.id.equals(id))).getSingleOrNull();
  }
  
  Future<int> insertStudent(StudentsCompanion student) => into(students).insert(student);
  Future<bool> updateStudent(Student student) => update(students).replace(student);
  Future<int> deleteStudent(int id) => (delete(students)..where((t) => t.id.equals(id))).go();

  // Parent queries
  Future<List<Parent>> getAllParents() => select(parents).get();
  Future<Parent?> getParentByStudentId(int studentId) {
    return (select(parents)..where((t) => t.studentId.equals(studentId))).getSingleOrNull();
  }
  Future<int> insertParent(ParentsCompanion parent) => into(parents).insert(parent);
  Future<bool> updateParent(Parent parent) => update(parents).replace(parent);
  Future<int> deleteParent(int id) => (delete(parents)..where((t) => t.id.equals(id))).go();

  // Attendance queries
  Future<List<Attendance>> getAttendancesByDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    
    return (select(attendances)
      ..where((t) => t.date.isBetweenValues(startOfDay, endOfDay)))
      .get();
  }
  
  Future<List<Attendance>> getAttendancesByDateRange(DateTime start, DateTime end) {
    return (select(attendances)
      ..where((t) => t.date.isBetweenValues(start, end))
      ..orderBy([(t) => OrderingTerm.desc(t.date)]))
      .get();
  }
  
  Future<List<Attendance>> getAttendancesByStudent(int studentId) {
    return (select(attendances)
      ..where((t) => t.studentId.equals(studentId))
      ..orderBy([(t) => OrderingTerm.desc(t.date)]))
      .get();
  }
  
  Stream<List<Attendance>> watchAttendancesByDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    
    return (select(attendances)
      ..where((t) => t.date.isBetweenValues(startOfDay, endOfDay)))
      .watch();
  }
  
  Future<int> insertAttendance(AttendancesCompanion attendance) => into(attendances).insert(attendance);
  Future<bool> updateAttendance(Attendance attendance) => update(attendances).replace(attendance);
  Future<int> deleteAttendance(int id) => (delete(attendances)..where((t) => t.id.equals(id))).go();

  // Permission queries
  Future<List<Permission>> getAllPermissions() {
    return (select(permissions)..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).get();
  }
  
  Future<List<Permission>> getPermissionsByStudent(int studentId) {
    return (select(permissions)
      ..where((t) => t.studentId.equals(studentId))
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
      .get();
  }
  
  Future<Permission?> getPermissionByQrCode(String qrCode) {
    return (select(permissions)..where((t) => t.qrCode.equals(qrCode))).getSingleOrNull();
  }
  
  Stream<List<Permission>> watchPermissionsByStudent(int studentId) {
    return (select(permissions)
      ..where((t) => t.studentId.equals(studentId))
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
      .watch();
  }
  
  Future<int> insertPermission(PermissionsCompanion permission) => into(permissions).insert(permission);
  Future<bool> updatePermission(Permission permission) => update(permissions).replace(permission);
  Future<int> deletePermission(int id) => (delete(permissions)..where((t) => t.id.equals(id))).go();

  // Settings queries
  Future<AppSetting?> getSetting(String key) {
    return (select(appSettings)..where((t) => t.key.equals(key))).getSingleOrNull();
  }
  
  Future<void> setSetting(String key, String value) async {
    await into(appSettings).insertOnConflictUpdate(
      AppSettingsCompanion.insert(
        key: key,
        value: value,
        updatedAt: DateTime.now(),
      ),
    );
  }
  
  Future<int> deleteSetting(String key) {
    return (delete(appSettings)..where((t) => t.key.equals(key))).go();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'sekilas_db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

// Provider
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError();
});
