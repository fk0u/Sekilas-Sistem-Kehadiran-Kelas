import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/database.dart';

class ThemeModeNotifier extends StateNotifier<bool> {
  final AppDatabase database;
  
  ThemeModeNotifier(this.database) : super(false) {
    _loadThemeMode();
  }
  
  Future<void> _loadThemeMode() async {
    final setting = await database.getSetting('dark_mode');
    if (setting != null) {
      state = setting.value == 'true';
    }
  }
  
  Future<void> toggleTheme() async {
    state = !state;
    await database.setSetting('dark_mode', state.toString());
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, bool>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return ThemeModeNotifier(database);
});
