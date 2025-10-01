import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' as drift;
import '../../../core/database/database.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/loading_widget.dart';
import '../widgets/student_card.dart';
import '../providers/student_provider.dart';

class StudentManagementScreen extends ConsumerStatefulWidget {
  const StudentManagementScreen({super.key});

  @override
  ConsumerState<StudentManagementScreen> createState() => _StudentManagementScreenState();
}

class _StudentManagementScreenState extends ConsumerState<StudentManagementScreen> {
  String _searchQuery = '';

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

  Future<void> _showAddStudentDialog() async {
    final nameController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Siswa Baru'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Siswa',
                  hintText: 'Contoh: Andi Wijaya',
                  prefixIcon: Icon(Icons.person),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama wajib diisi';
                  }
                  if (value.trim().length < 3) {
                    return 'Nama minimal 3 karakter';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final className = ref.read(currentClassProvider);
                final addStudent = ref.read(addStudentProvider);
                
                try {
                  await addStudent(
                    StudentsCompanion.insert(
                      name: nameController.text.trim(),
                      className: className,
                    ),
                  );
                  
                  if (context.mounted) {
                    context.pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Siswa berhasil ditambahkan'),
                        backgroundColor: AppTheme.statusHadir,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: AppTheme.statusAlpa,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditStudentDialog(Student student) async {
    final nameController = TextEditingController(text: student.name);
    final formKey = GlobalKey<FormState>();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Siswa'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Nama Siswa',
              prefixIcon: Icon(Icons.person),
            ),
            textCapitalization: TextCapitalization.words,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Nama wajib diisi';
              }
              if (value.trim().length < 3) {
                return 'Nama minimal 3 karakter';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final updateStudent = ref.read(updateStudentProvider);
                
                try {
                  await updateStudent(
                    student.copyWith(name: nameController.text.trim()),
                  );
                  
                  if (context.mounted) {
                    context.pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Siswa berhasil diupdate'),
                        backgroundColor: AppTheme.statusHadir,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: AppTheme.statusAlpa,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteStudent(Student student) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Siswa'),
        content: Text('Yakin ingin menghapus ${student.name}?'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final deleteStudent = ref.read(deleteStudentProvider);
              
              try {
                await deleteStudent(student.id);
                
                if (context.mounted) {
                  context.pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Siswa berhasil dihapus'),
                      backgroundColor: AppTheme.statusAlpa,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: AppTheme.statusAlpa,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.statusAlpa,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final className = ref.watch(currentClassProvider);
    final studentsAsync = ref.watch(studentsProvider(className));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Siswa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload),
            onPressed: () {
              // TODO: Implement import students
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Import siswa - Coming Soon')),
              );
            },
            tooltip: 'Import Siswa',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari siswa...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          
          // Students List
          Expanded(
            child: studentsAsync.when(
              data: (students) {
                final filteredStudents = students.where((student) {
                  return student.name.toLowerCase().contains(_searchQuery);
                }).toList();

                if (filteredStudents.isEmpty) {
                  return EmptyStateWidget(
                    title: 'Belum Ada Siswa',
                    message: 'Tambahkan siswa pertama dengan menekan tombol + di bawah',
                    icon: Icons.people_outline,
                    actionText: 'Tambah Siswa',
                    onAction: _showAddStudentDialog,
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: filteredStudents.length,
                  itemBuilder: (context, index) {
                    final student = filteredStudents[index];
                    return StudentCard(
                      student: student,
                      onEdit: () => _showEditStudentDialog(student),
                      onDelete: () => _confirmDeleteStudent(student),
                    );
                  },
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
        onPressed: _showAddStudentDialog,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Siswa'),
      ),
    );
  }
}
