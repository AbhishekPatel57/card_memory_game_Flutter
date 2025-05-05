import 'package:shared_preferences/shared_preferences.dart';

class StorageHelper {
  static const _keyUnlockedLevel = 'unlocked_level';

  static Future<int> getUnlockedLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyUnlockedLevel) ?? 1;
  }

  static Future<void> saveUnlockedLevel(int level) async {
    final prefs = await SharedPreferences.getInstance();
    int current = prefs.getInt(_keyUnlockedLevel) ?? 1;
    if (level > current) {
      await prefs.setInt(_keyUnlockedLevel, level);
    }
  }
}
