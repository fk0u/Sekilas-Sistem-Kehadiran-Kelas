import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/database/database.dart';
import '../../../core/theme/app_theme.dart';

class ParentOnboardingScreen extends ConsumerStatefulWidget {
  const ParentOnboardingScreen({super.key});

  @override
  ConsumerState<ParentOnboardingScreen> createState() => _ParentOnboardingScreenState();
}

class _ParentOnboardingScreenState extends ConsumerState<ParentOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _parentNameController = TextEditingController();
  final _classController = TextEditingController();
  String? _selectedStudentId;
  List<Student> _students = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  @override
  void dispose() {
    _parentNameController.dispose();
    _classController.dispose();
    super.dispose();
  }

  Future<void> _loadStudents() async {
    final database = ref.read(appDatabaseProvider);
    final students = await database.getAllStudents();
    setState(() {
      _students = students;
    });
  }

  Future<void> _loadStudentsByClass(String className) async {
    final database = ref.read(appDatabaseProvider);
    final students = await database.getStudentsByClass(className);
    setState(() {
      _students = students;
      _selectedStudentId = null;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedStudentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih siswa terlebih dahulu'),
          backgroundColor: AppTheme.statusAlpa,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final database = ref.read(appDatabaseProvider);
      
      // Simpan data orang tua
      await database.insertParent(
        ParentsCompanion.insert(
          studentId: int.parse(_selectedStudentId!),
          name: _parentNameController.text.trim(),
        ),
      );
      
      // Simpan role sebagai orang tua
      await database.setSetting('user_role', 'orang_tua');
      await database.setSetting('current_student_id', _selectedStudentId!);

      if (mounted) {
        context.go('/parent-home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: $e'),
            backgroundColor: AppTheme.statusAlpa,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Orang Tua'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/role-selection'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryGreen.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.family_restroom,
                      size: 60,
                      color: AppTheme.secondaryGreen,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Judul
                Text(
                  'Lengkapi Data Anda',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Masukkan data diri dan pilih anak Anda',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Input Nama Orang Tua
                TextFormField(
                  controller: _parentNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Orang Tua',
                    hintText: 'Contoh: Ahmad Wijaya',
                    prefixIcon: Icon(Icons.person_outline),
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
                const SizedBox(height: 24),
                
                // Input Kelas
                TextFormField(
                  controller: _classController,
                  decoration: const InputDecoration(
                    labelText: 'Kelas Anak',
                    hintText: 'Contoh: 3A, 5B',
                    prefixIcon: Icon(Icons.class_),
                  ),
                  textCapitalization: TextCapitalization.characters,
                  onChanged: (value) {
                    if (value.trim().isNotEmpty) {
                      _loadStudentsByClass(value.trim());
                    }
                  },
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Kelas wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                
                // Dropdown Pilih Siswa
                DropdownButtonFormField<String>(
                  value: _selectedStudentId,
                  decoration: const InputDecoration(
                    labelText: 'Pilih Nama Siswa',
                    hintText: 'Pilih nama anak Anda',
                    prefixIcon: Icon(Icons.child_care),
                  ),
                  items: _students.map((student) {
                    return DropdownMenuItem(
                      value: student.id.toString(),
                      child: Text(student.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedStudentId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Silakan pilih siswa';
                    }
                    return null;
                  },
                ),
                
                if (_students.isEmpty && _classController.text.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Tidak ada siswa di kelas ini. Hubungi guru untuk menambahkan.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.statusAlpa,
                      ),
                    ),
                  ),
                
                const SizedBox(height: 48),
                
                // Tombol Lanjut
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.secondaryGreen,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Lanjut'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
