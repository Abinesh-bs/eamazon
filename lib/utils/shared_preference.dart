import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceHelper {
  static late SharedPreferences _prefs;

  static Future<SharedPreferences> init() async {
    _prefs = await SharedPreferences.getInstance();
    return _prefs;
  }

  // Sets
  static Future<bool> setBool(String key, bool value) async =>
      await _prefs.setBool(key, value);

  static Future<bool> setDouble(String key, double value) async =>
      await _prefs.setDouble(key, value);

  static Future<bool> setInt(String key, int value) async =>
      await _prefs.setInt(key, value);

  static Future<bool> setString(String key, String value) async =>
      await _prefs.setString(key, value);

  static Future<bool> setStringList(String key, List<String> value) async =>
      await _prefs.setStringList(key, value);

  // Gets
  static bool? getBool(String key) => _prefs.getBool(key);

  static double? getDouble(String key) => _prefs.getDouble(key);

  static int? getInt(String key) => _prefs.getInt(key);

  static String? getString(String key) => _prefs.getString(key);

  static List<String>? getStringList(String key) => _prefs.getStringList(key);

  // Deletes..
  static Future<bool>? remove(String key) async => await _prefs.remove(key);

  static Future<bool> clear() async => await _prefs.clear();

  static String? getThemeMode() {
    return getString('theme_mode');
  }

  static void setThemeMode(String mode) {
    setString('theme_mode', mode);
  }

  static String? getUserId() {
    return getString('user_id');
  }

  static void setUserId(String userId) {
    setString('user_id', userId);
  }

  static String? getFirebaseToken() {
    return getString('fcm_token');
  }

  static void setFirebaseToken(String token) {
    setString('fcm_token', token);
  }

  static String? getAuthToken() {
    return getString('auth_token');
  }

  static void setAuthToken(String token) {
    setString('auth_token', token);
  }

  static Future<void> setCategories(List<String> categories) async {
    final stringList = categories.map((e) => e.toString()).toList();
    await setStringList('selected_category', stringList);
  }

  static List<String>? getCategories() {
    final stringList = getStringList('selected_category');
    if (stringList == null) return null;

    return stringList;
  }
}
