import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/local_storage.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
}

class AuthState {
  final AuthStatus status;
  final String? userRole;
  final String? schoolName;

  AuthState({
    required this.status,
    this.userRole,
    this.schoolName,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? userRole,
    String? schoolName,
  }) {
    return AuthState(
      status: status ?? this.status,
      userRole: userRole ?? this.userRole,
      schoolName: schoolName ?? this.schoolName,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final LocalStorageService _storage;
  
  AuthNotifier(this._storage) : super(AuthState(status: AuthStatus.initial)) {
    // Check auth state on initialization
    checkAuthState();
  }

  Future<void> checkAuthState() async {
    final isLoggedIn = _storage.isLoggedIn();
    print('Checking auth state - isLoggedIn: $isLoggedIn');
    
    if (!isLoggedIn) {
      print('Not logged in, setting state to unauthenticated');
      state = AuthState(status: AuthStatus.unauthenticated);
      return;
    }
    
    final userRole = _storage.getUserRole();
    final schoolName = _storage.getSchoolName();
    print('User is logged in - Role: $userRole, School: $schoolName');
    
    if (userRole != null && schoolName != null) {
      state = AuthState(
        status: AuthStatus.authenticated,
        userRole: userRole,
        schoolName: schoolName,
      );
    } else {
      state = AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> loginAsTeacher(Map<String, dynamic> teacherData, String schoolName) async {
    print('Logging in as teacher - Name: ${teacherData['name']}, School: $schoolName');
    await _storage.setTeacherData(teacherData);
    await _storage.setSchoolName(schoolName);
    await _storage.setUserRole('guru');
    await _storage.setLoggedIn(true);
    
    print('Teacher login completed - Setting state to authenticated');
    state = AuthState(
      status: AuthStatus.authenticated,
      userRole: 'guru',
      schoolName: schoolName,
    );
  }

  Future<void> loginAsParent(Map<String, dynamic> parentData, String schoolName) async {
    print('Logging in as parent - Name: ${parentData['name']}, School: $schoolName');
    await _storage.setParentData(parentData);
    await _storage.setSchoolName(schoolName);
    await _storage.setUserRole('orangTua');
    await _storage.setLoggedIn(true);
    
    print('Parent login completed - Setting state to authenticated');
    state = AuthState(
      status: AuthStatus.authenticated,
      userRole: 'orangTua',
      schoolName: schoolName,
    );
  }

  Future<void> logout() async {
    await _storage.clearAll();
    
    state = AuthState(status: AuthStatus.unauthenticated);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final storage = ref.watch(localStorageProvider);
  return AuthNotifier(storage);
});