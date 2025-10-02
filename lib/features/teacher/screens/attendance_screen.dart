import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/database/database.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/loading_widget.dart';
import '../widgets/student_grid_item.dart';
import '../providers/student_provider.dart';
import '../providers/attendance_provider.dart';

class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  final Map<int, AttendanceStatus> _attendanceMap = {};
  final Map<int, String> _notesMap = {};

  @override
  void initState() {
    super.initState();
    _loadCurrentClass();
  }

  Future<void> _loadCurrentClass() async {
    final database = ref.read(appDatabaseProvider);
    final teacher = await database.getTeacher();
    if (teacher != null) {
      ref.read(currentClassProvider.notifier).state = teacher.className;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final currentDate = ref.read(selectedDateProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null && picked != currentDate) {
      ref.read(selectedDateProvider.notifier).state = picked;
      _attendanceMap.clear();
      _notesMap.clear();
    }
  }

  void _toggleStatus(int studentId, AttendanceStatus currentStatus) {
    setState(() {
      AttendanceStatus newStatus;
      switch (currentStatus) {
        case AttendanceStatus.none:
          newStatus = AttendanceStatus.hadir;
          break;
        case AttendanceStatus.hadir:
          newStatus = AttendanceStatus.izin;
          break;
        case AttendanceStatus.izin:
          newStatus = AttendanceStatus.sakit;
          break;
        case AttendanceStatus.sakit:
          newStatus = AttendanceStatus.alpa;
          break;
        case AttendanceStatus.alpa:
          newStatus = AttendanceStatus.none;
          break;
      }
      _attendanceMap[studentId] = newStatus;
    });
  }

  void _markAllPresent(List<Student> students) {
    setState(() {
      for (var student in students) {
        _attendanceMap[student.id] = AttendanceStatus.hadir;
      }
    });
  }

  Future<void> _saveAttendance() async {
    if (_attendanceMap.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Belum ada data absensi yang diisi')),
      );
      return;
    }

    final database = ref.read(appDatabaseProvider);
    final selectedDate = ref.read(selectedDateProvider);

    try {
      for (var entry in _attendanceMap.entries) {
        if (entry.value != AttendanceStatus.none) {
          String status = '';
          switch (entry.value) {
            case AttendanceStatus.hadir:
              status = 'hadir';
              break;
            case AttendanceStatus.izin:
              status = 'izin';
              break;
            case AttendanceStatus.sakit:
              status = 'sakit';
              break;
            case AttendanceStatus.alpa:
              status = 'alpa';
              break;
            case AttendanceStatus.none:
              continue;
          }
          
          if (status.isEmpty) continue;

          await database.insertAttendance(
            AttendancesCompanion.insert(
              studentId: entry.key,
              date: selectedDate,
              status: status,
              notes: _notesMap[entry.key] != null 
                ? drift.Value(_notesMap[entry.key]!)
                : const drift.Value.absent(),
            ),
          );
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Absensi berhasil disimpan'),
            backgroundColor: AppTheme.statusHadir,
          ),
        );
        setState(() {
          _attendanceMap.clear();
          _notesMap.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.statusAlpa,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedDateProvider);
    final className = ref.watch(currentClassProvider);
    final studentsAsync = ref.watch(studentsProvider(className));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Absensi Harian'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
            tooltip: 'Pilih Tanggal',
          ),
        ],
      ),
      body: Column(
        children: [
          // Date Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.1),
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.primaryBlue.withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                Text(
                  _formatDate(selectedDate),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryBlue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Kelas $className',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),

          // Students Grid
          Expanded(
            child: studentsAsync.when(
              data: (students) {
                if (students.isEmpty) {
                  return const EmptyStateWidget(
                    title: 'Belum Ada Siswa',
                    message: 'Tambahkan siswa terlebih dahulu di menu Kelola Siswa',
                    icon: Icons.people_outline,
                  );
                }

                return Column(
                  children: [
                    // Quick Action Button
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _markAllPresent(students),
                              icon: const Icon(Icons.done_all),
                              label: const Text('Tandai Semua Hadir'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Legend
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildLegendItem('Hadir', AppTheme.statusHadir),
                          _buildLegendItem('Izin', AppTheme.statusIzin),
                          _buildLegendItem('Sakit', AppTheme.statusSakit),
                          _buildLegendItem('Alpa', AppTheme.statusAlpa),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Students Grid
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: students.length,
                        itemBuilder: (context, index) {
                          final student = students[index];
                          final status = _attendanceMap[student.id] ?? AttendanceStatus.none;
                          
                          return StudentGridItem(
                            student: student,
                            status: status,
                            onTap: () => _toggleStatus(student.id, status),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
              loading: () => const LoadingWidget(message: 'Memuat data siswa...'),
              error: (error, stack) => Center(
                child: Text('Error: $error'),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveAttendance,
        icon: const Icon(Icons.save),
        label: const Text('Simpan Absensi'),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11),
        ),
      ],
    );
  }
}
