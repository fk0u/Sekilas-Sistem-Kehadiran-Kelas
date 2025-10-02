import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/loading_widget.dart';
import '../widgets/student_local_card.dart';

class StudentManagementScreen extends ConsumerStatefulWidget {
  const StudentManagementScreen({super.key});

  @override
  ConsumerState<StudentManagementScreen> createState() => _StudentManagementScreenState();
}

class _StudentManagementScreenState extends ConsumerState<StudentManagementScreen> {
  String _searchQuery = '';
  String _currentClass = '';
  List<Map<String, dynamic>> _students = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentClass();
  }

  Future<void> _loadCurrentClass() async {
    setState(() => _isLoading = true);
    
    final storage = ref.read(localStorageProvider);
    final teacher = storage.getTeacherData();
    if (teacher != null) {
      setState(() {
        _currentClass = teacher['className'] ?? '';
      });
      await _loadStudents();
    }
    
    setState(() => _isLoading = false);
  }
  
  Future<void> _loadStudents() async {
    final storage = ref.read(localStorageProvider);
    final allStudents = storage.getStudentsData() ?? [];
    final filteredStudents = allStudents.where((student) => 
      student['className'] == _currentClass
    ).toList();
    
    // Urutkan berdasarkan sortOrder
    filteredStudents.sort((a, b) => (a['sortOrder'] as int? ?? 0).compareTo(b['sortOrder'] as int? ?? 0));
    
    setState(() {
      _students = filteredStudents;
    });
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
                final storage = ref.read(localStorageProvider);
                
                try {
                  // Buat data siswa baru
                  final newStudent = {
                    'id': DateTime.now().millisecondsSinceEpoch,
                    'name': nameController.text.trim(),
                    'className': _currentClass,
                    'photoPath': null,
                    'sortOrder': _students.length,
                    'createdAt': DateTime.now().toIso8601String(),
                  };
                  
                  // Tambahkan ke storage
                  await storage.addOrUpdateStudent(newStudent);
                  
                  // Refresh daftar siswa
                  await _loadStudents();
                  
                  if (mounted) {
                    context.pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Siswa berhasil ditambahkan'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    context.pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Gagal menambahkan siswa: $e'),
                        backgroundColor: Colors.red,
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

  Future<void> _showEditStudentDialog(Map<String, dynamic> student) async {
    final nameController = TextEditingController(text: student['name']);
    final formKey = GlobalKey<FormState>();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Siswa'),
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
                final storage = ref.read(localStorageProvider);
                
                try {
                  // Update data siswa
                  final updatedStudent = {
                    ...student,
                    'name': nameController.text.trim(),
                    'updatedAt': DateTime.now().toIso8601String(),
                  };
                  
                  // Simpan ke storage
                  await storage.addOrUpdateStudent(updatedStudent);
                  
                  // Refresh daftar siswa
                  await _loadStudents();
                  
                  if (mounted) {
                    context.pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Data siswa berhasil diperbarui'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    context.pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Gagal memperbarui data siswa: $e'),
                        backgroundColor: Colors.red,
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

  Future<void> _confirmDeleteStudent(Map<String, dynamic> student) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Apakah Anda yakin ingin menghapus ${student['name']}?'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final storage = ref.read(localStorageProvider);
              
              try {
                // Ambil daftar siswa saat ini
                final allStudents = storage.getStudentsData() ?? [];
                
                // Filter untuk menghapus siswa yang dipilih
                final updatedStudents = allStudents.where((s) => s['id'] != student['id']).toList();
                
                // Simpan daftar baru
                await storage.setStudentsData(updatedStudents);
                
                // Refresh daftar
                await _loadStudents();
                
                if (mounted) {
                  context.pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Siswa berhasil dihapus'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  context.pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal menghapus siswa: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredStudents() {
    if (_searchQuery.isEmpty) {
      return _students;
    }
    
    final query = _searchQuery.toLowerCase();
    return _students.where((student) => 
      student['name'].toString().toLowerCase().contains(query)
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredStudents = _getFilteredStudents();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Siswa'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header dan pencarian
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kelas: $_currentClass',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari siswa...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ],
            ),
          ),
          
          // Daftar siswa
          Expanded(
            child: _isLoading
                ? const LoadingWidget(message: 'Memuat daftar siswa...')
                : filteredStudents.isEmpty
                    ? const EmptyStateWidget(
                        icon: Icons.people,
                        title: 'Daftar Siswa Kosong',
                        message: 'Belum ada siswa di kelas ini',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 100),
                        itemCount: filteredStudents.length,
                        itemBuilder: (context, index) {
                          final student = filteredStudents[index];
                          return StudentLocalCard(
                            student: student,
                            onTap: () => _showEditStudentDialog(student),
                            onEdit: () => _showEditStudentDialog(student),
                            onDelete: () => _confirmDeleteStudent(student),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddStudentDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}