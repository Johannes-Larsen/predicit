import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  // Versioned key: if the saved session shape changes later, the app can
  // migrate or ignore old auth data instead of crashing on stale data.
  static const String _key = 'auth_v1';

  /// Saves a mock session token. In this teaching app the token is only the
  /// username; never persist the plaintext password.
  Future<void> save(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, token);
  }

  Future<String?> load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  Future<void> clear() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
