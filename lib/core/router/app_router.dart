import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_provider.dart';
import '../../features/onboarding/screens/role_selection_screen.dart';
import '../../features/onboarding/screens/teacher_onboarding_screen.dart';
import '../../features/onboarding/screens/parent_onboarding_screen.dart';
import '../../features/teacher/screens/teacher_home_screen.dart';
import '../../features/teacher/screens/student_management_screen.dart';
import '../../features/teacher/screens/attendance_screen.dart';
import '../../features/teacher/screens/scan_permission_screen.dart';
import '../../features/teacher/screens/report_screen.dart';
import '../../features/teacher/screens/teacher_settings_screen.dart';
import '../../features/parent/screens/parent_home_screen.dart';
import '../../features/parent/screens/create_permission_screen.dart';
import '../../features/parent/screens/permission_history_screen.dart';
import '../../features/parent/screens/parent_settings_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/role-selection',
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      
      // If authenticated, redirect to appropriate home screen
      if (authState.status == AuthStatus.authenticated) {
        if (authState.userRole == 'guru' && 
            state.fullPath != '/teacher-home' && 
            !state.fullPath!.startsWith('/student-management') &&
            !state.fullPath!.startsWith('/attendance') &&
            !state.fullPath!.startsWith('/scan-permission') &&
            !state.fullPath!.startsWith('/report') &&
            !state.fullPath!.startsWith('/teacher-settings')) {
          return '/teacher-home';
        } else if (authState.userRole == 'orangTua' && 
                  state.fullPath != '/parent-home' &&
                  !state.fullPath!.startsWith('/create-permission') &&
                  !state.fullPath!.startsWith('/permission-history') &&
                  !state.fullPath!.startsWith('/parent-settings')) {
          return '/parent-home';
        }
      }
      
      // If trying to access protected routes while not authenticated
      if (authState.status == AuthStatus.unauthenticated) {
        if (state.fullPath != '/role-selection' && 
            state.fullPath != '/teacher-onboarding' && 
            state.fullPath != '/parent-onboarding') {
          return '/role-selection';
        }
      }
      
      return null;
    },
    routes: [
      // Onboarding Routes
      GoRoute(
        path: '/role-selection',
        name: 'roleSelection',
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: '/teacher-onboarding',
        name: 'teacherOnboarding',
        builder: (context, state) => const TeacherOnboardingScreen(),
      ),
      GoRoute(
        path: '/parent-onboarding',
        name: 'parentOnboarding',
        builder: (context, state) => const ParentOnboardingScreen(),
      ),
      
      // Teacher Routes
      GoRoute(
        path: '/teacher-home',
        name: 'teacherHome',
        builder: (context, state) => const TeacherHomeScreen(),
      ),
      GoRoute(
        path: '/student-management',
        name: 'studentManagement',
        builder: (context, state) => const StudentManagementScreen(),
      ),
      GoRoute(
        path: '/attendance',
        name: 'attendance',
        builder: (context, state) => const AttendanceScreen(),
      ),
      GoRoute(
        path: '/scan-permission',
        name: 'scanPermission',
        builder: (context, state) => const ScanPermissionScreen(),
      ),
      GoRoute(
        path: '/report',
        name: 'report',
        builder: (context, state) => const ReportScreen(),
      ),
      GoRoute(
        path: '/teacher-settings',
        name: 'teacherSettings',
        builder: (context, state) => const TeacherSettingsScreen(),
      ),
      
      // Parent Routes
      GoRoute(
        path: '/parent-home',
        name: 'parentHome',
        builder: (context, state) => const ParentHomeScreen(),
      ),
      GoRoute(
        path: '/create-permission',
        name: 'createPermission',
        builder: (context, state) => const CreatePermissionScreen(),
      ),
      GoRoute(
        path: '/permission-history',
        name: 'permissionHistory',
        builder: (context, state) => const PermissionHistoryScreen(),
      ),
      GoRoute(
        path: '/parent-settings',
        name: 'parentSettings',
        builder: (context, state) => const ParentSettingsScreen(),
      ),
    ],
  );
});
