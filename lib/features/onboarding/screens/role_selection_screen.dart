import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo atau Ilustrasi
              Icon(
                Icons.school,
                size: 120,
                color: AppTheme.primaryBlue,
              ),
              const SizedBox(height: 24),
              
              // Judul
              Text(
                'Selamat Datang di',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Sekilas',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: AppTheme.primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                'Sistem Kehadiran Kelas',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              
              // Tombol Guru
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.go('/teacher-onboarding');
                  },
                  icon: const Icon(Icons.person, size: 28),
                  label: const Text('Saya Guru'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Tombol Orang Tua
              SizedBox(
                width: double.infinity,
                height: 60,
                child: OutlinedButton.icon(
                  onPressed: () {
                    context.go('/parent-onboarding');
                  },
                  icon: const Icon(Icons.family_restroom, size: 28),
                  label: const Text('Saya Orang Tua'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.secondaryGreen,
                    side: const BorderSide(color: AppTheme.secondaryGreen, width: 2),
                  ),
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Info
              Text(
                'Pilih peran Anda untuk melanjutkan',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
