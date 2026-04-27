import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden');
});

class SettingsNotifier extends Notifier<Map<String, dynamic>> {
  @override
  Map<String, dynamic> build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return {
      'read_receipts': prefs.getBool('read_receipts') ?? true,
      'show_last_seen': prefs.getBool('show_last_seen') ?? true,
      'message_tones': prefs.getBool('message_tones') ?? true,
      'vibrate': prefs.getBool('vibrate') ?? true,
      'high_quality_media': prefs.getBool('high_quality_media') ?? false,
    };
  }

  void updateSetting(String key, dynamic value) {
    final prefs = ref.read(sharedPreferencesProvider);
    if (value is bool) {
      prefs.setBool(key, value);
    } else if (value is String) {
      prefs.setString(key, value);
    } else if (value is int) {
      prefs.setInt(key, value);
    }
    state = {...state, key: value};
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, Map<String, dynamic>>(() {
  return SettingsNotifier();
});
