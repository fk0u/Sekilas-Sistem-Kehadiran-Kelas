import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/auth/auth_provider.dart';

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
  List<Map<String, dynamic>> _students = [];
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
    final storage = ref.read(localStorageProvider);
    final students = storage.getStudentsData() ?? [];
    setState(() {
      _students = students;
    });
  }

  Future<void> _loadStudentsByClass(String className) async {
    final storage = ref.read(localStorageProvider);
    final allStudents = storage.getStudentsData() ?? [];
    final filteredStudents = allStudents.where(
      (student) => student['className'] == className
    ).toList();
    
    setState(() {
      _students = filteredStudents;
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
      final storage = ref.read(localStorageProvider);
      final authNotifier = ref.read(authProvider.notifier);
      final selectedStudentId = int.parse(_selectedStudentId!);
      
      // Temukan data siswa yang dipilih
      final students = storage.getStudentsData() ?? [];
      final selectedStudent = students.firstWhere(
        (student) => student['id'] == selectedStudentId,
        orElse: () => <String, dynamic>{},
      );
      
      // Simpan data orang tua
      final parentData = {
        'id': DateTime.now().millisecondsSinceEpoch,
        'studentId': selectedStudentId,
        'name': _parentNameController.text.trim(),
        'createdAt': DateTime.now().toIso8601String(),
      };
      
      // Login sebagai orang tua menggunakan auth provider
      await authNotifier.loginAsParent(
        parentData, 
        storage.getSchoolName() ?? 'Unknown School'
      );

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
                      value: student['id'].toString(),
                      child: Text(student['name']),
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
