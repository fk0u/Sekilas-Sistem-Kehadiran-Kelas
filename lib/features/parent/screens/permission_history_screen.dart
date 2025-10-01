import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/loading_widget.dart';
import '../widgets/permission_card.dart';
import '../providers/permission_provider.dart';

class PermissionHistoryScreen extends ConsumerWidget {
  const PermissionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parentAsync = ref.watch(currentParentProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Izin'),
      ),
      body: parentAsync.when(
        data: (parent) {
          if (parent == null) {
            return const Center(
              child: Text('Data orang tua tidak ditemukan'),
            );
          }

          final permissionsAsync = ref.watch(permissionsProvider(parent.id));

          return permissionsAsync.when(
            data: (permissions) {
              if (permissions.isEmpty) {
                return const EmptyStateWidget(
                  title: 'Belum Ada Izin',
                  message: 'Riwayat izin yang Anda buat akan muncul di sini',
                  icon: Icons.assignment_outlined,
                );
              }

              final sortedPermissions = permissions.toList()
                ..sort((a, b) => b.id.compareTo(a.id));

              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: sortedPermissions.length,
                itemBuilder: (context, index) {
                  final permission = sortedPermissions[index];
                  return PermissionCard(
                    permission: permission,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Detail izin - Coming Soon'),
                        ),
                      );
                    },
                  );
                },
              );
            },
            loading: () => const LoadingWidget(message: 'Memuat riwayat...'),
            error: (error, stack) => Center(
              child: Text('Error: $error'),
            ),
          );
        },
        loading: () => const LoadingWidget(),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }
}
