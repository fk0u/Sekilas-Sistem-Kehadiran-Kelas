import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/database/database.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/permission_provider.dart';

class CreatePermissionScreen extends ConsumerStatefulWidget {
  const CreatePermissionScreen({super.key});

  @override
  ConsumerState<CreatePermissionScreen> createState() => _CreatePermissionScreenState();
}

class _CreatePermissionScreenState extends ConsumerState<CreatePermissionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  
  String _permissionType = 'izin';
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  
  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate;
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Future<void> _submitPermission() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final parentAsync = ref.read(currentParentProvider);
    final parent = parentAsync.value;
    
    if (parent == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data orang tua tidak ditemukan'),
            backgroundColor: AppTheme.statusAlpa,
          ),
        );
      }
      return;
    }

    final createPermission = ref.read(createPermissionProvider);
    
    final qrData = 'PERMISSION_${parent['studentId']}_${DateTime.now().millisecondsSinceEpoch}';

    try {
      await createPermission({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'studentId': parent['studentId'],
        'parentId': parent['id'],
        'permissionType': _permissionType,
        'startDate': _startDate.toIso8601String(),
        'endDate': _endDate.toIso8601String(),
        'reason': _reasonController.text.trim(),
        'qrCode': qrData,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Izin berhasil dibuat'),
            backgroundColor: AppTheme.statusHadir,
          ),
        );
        context.pop();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Izin'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Jenis Izin',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Izin'),
                            value: 'izin',
                            groupValue: _permissionType,
                            onChanged: (value) {
                              setState(() {
                                _permissionType = value!;
                              });
                            },
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Sakit'),
                            value: 'sakit',
                            groupValue: _permissionType,
                            onChanged: (value) {
                              setState(() {
                                _permissionType = value!;
                              });
                            },
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Periode',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      leading: const Icon(Icons.calendar_today, color: AppTheme.primaryBlue),
                      title: const Text('Tanggal Mulai'),
                      subtitle: Text(_formatDate(_startDate)),
                      onTap: _selectStartDate,
                      contentPadding: EdgeInsets.zero,
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.event, color: AppTheme.primaryBlue),
                      title: const Text('Tanggal Selesai'),
                      subtitle: Text(_formatDate(_endDate)),
                      onTap: _selectEndDate,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alasan',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _reasonController,
                      decoration: const InputDecoration(
                        hintText: 'Contoh: Keperluan keluarga / Demam tinggi',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 4,
                      textCapitalization: TextCapitalization.sentences,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Alasan wajib diisi';
                        }
                        if (value.trim().length < 10) {
                          return 'Alasan minimal 10 karakter';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _submitPermission,
                icon: const Icon(Icons.check),
                label: const Text('Buat Izin'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
