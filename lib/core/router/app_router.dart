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
      
      // Saat aplikasi baru dibuka, periksa status autentikasi
      if (authState.status == AuthStatus.initial) {
        // Masih dalam proses pengecekan auth state, tidak melakukan redirect dulu
        return null;
      }
      
      // Handle authenticated state - auto login ke halaman utama
      if (authState.status == AuthStatus.authenticated) {
        // Daftar rute yang diperbolehkan untuk masing-masing peran
        final teacherAllowedRoutes = [
          '/teacher-home', 
          '/student-management', 
          '/attendance', 
          '/scan-permission', 
          '/report', 
          '/teacher-settings'
        ];
        
        final parentAllowedRoutes = [
          '/parent-home', 
          '/create-permission', 
          '/permission-history', 
          '/parent-settings'
        ];
        
        // Redirect guru ke halaman guru
        if (authState.userRole == 'guru') {
          bool isOnTeacherRoute = false;
          for (var route in teacherAllowedRoutes) {
            if (state.fullPath == route || state.fullPath!.startsWith(route)) {
              isOnTeacherRoute = true;
              break;
            }
          }
          
          if (!isOnTeacherRoute) {
            // Jika tidak berada di halaman guru, redirect ke home guru
            print('Redirecting to teacher home');
            return '/teacher-home';
          }
        } 
        // Redirect orang tua ke halaman orang tua
        else if (authState.userRole == 'orangTua') {
          bool isOnParentRoute = false;
          for (var route in parentAllowedRoutes) {
            if (state.fullPath == route || state.fullPath!.startsWith(route)) {
              isOnParentRoute = true;
              break;
            }
          }
          
          if (!isOnParentRoute) {
            // Jika tidak berada di halaman orang tua, redirect ke home orang tua
            print('Redirecting to parent home');
            return '/parent-home';
          }
        }
      }
      
      // Handle unauthenticated state - redirect ke halaman login/role selection
      if (authState.status == AuthStatus.unauthenticated) {
        final publicRoutes = ['/role-selection', '/teacher-onboarding', '/parent-onboarding'];
        if (!publicRoutes.contains(state.fullPath)) {
          print('Redirecting to role selection');
          return '/role-selection';
        }
      }
      
      // Tidak perlu redirect
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
