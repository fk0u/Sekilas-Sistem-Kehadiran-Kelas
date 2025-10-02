import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/database/database.dart';
import '../../../core/auth/auth_provider.dart';
import '../../settings/providers/theme_provider.dart';

class TeacherSettingsScreen extends ConsumerWidget {
  const TeacherSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeModeProvider);
    final database = ref.watch(appDatabaseProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Setelan Guru'),
      ),
      body: ListView(
        children: [
          FutureBuilder<Map<String, dynamic>?>(
            future: database.getTeacher(),
            builder: (context, snapshot) {
              final teacherData = snapshot.data;
              final String name = teacherData != null ? teacherData['name'] ?? 'Guru' : 'Guru';
              final String className = teacherData != null ? teacherData['className'] ?? '-' : '-';
              
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.1),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AppTheme.primaryBlue,
                      child: Text(
                        name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'G',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Kelas $className',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          _buildSectionHeader(context, 'Tampilan'),
          SwitchListTile(
            title: const Text('Mode Gelap'),
            subtitle: const Text('Aktifkan tema gelap'),
            secondary: Icon(
              isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: AppTheme.primaryBlue,
            ),
            value: isDarkMode,
            onChanged: (value) {
              ref.read(themeModeProvider.notifier).toggleTheme();
            },
          ),
          const Divider(),
          _buildSectionHeader(context, 'Tentang'),
          ListTile(
            leading: const Icon(Icons.info, color: AppTheme.primaryBlue),
            title: const Text('Versi Aplikasi'),
            subtitle: const Text('v0.2.0-dev'),
          ),
          const Divider(),
          _buildSectionHeader(context, 'Akun'),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Keluar'),
            subtitle: const Text('Keluar dari akun ini'),
            onTap: () {
              _showLogoutConfirmation(context, ref);
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: AppTheme.primaryBlue,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  void _showLogoutConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Logout menggunakan auth provider
              ref.read(authProvider.notifier).logout();
            },
            child: const Text('Keluar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
