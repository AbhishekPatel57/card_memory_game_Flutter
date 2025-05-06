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

  static Future<String> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userName') ?? 'User';
  }
  static Future<void> saveName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', name);
  }

  static Future<String> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('email') ?? 'example@gmail.com';
  }
  
  static Future<void> saveEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
  }

  static Future<String> getNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('number') ?? '+91 1234567890';
  }

  static Future<void> saveNumber(String number) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('number', number);
  }
}
