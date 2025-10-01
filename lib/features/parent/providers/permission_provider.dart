import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database.dart';

// Provider untuk permissions berdasarkan parent
final permissionsProvider = StreamProvider.family<List<Permission>, int>((ref, parentId) {
  final database = ref.watch(appDatabaseProvider);
  return database.watchPermissionsByParent(parentId);
});

// Provider untuk current parent
final currentParentProvider = FutureProvider<Parent?>((ref) async {
  final database = ref.watch(appDatabaseProvider);
  return await database.getParent();
});

// Provider untuk create permission
final createPermissionProvider = Provider<Future<int> Function(PermissionsCompanion)>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return database.insertPermission;
});
