import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../data/auth_storage.dart';
import '../models/user.dart';

class AuthModel extends ChangeNotifier {
  AuthModel({AuthStorage? storage}) : _storage = storage ?? AuthStorage();

  final AuthStorage _storage;

  User? _currentUser;

  User? get currentUser => _currentUser;
  bool get isSignedIn => _currentUser != null;

  /// Loads any persisted mock session token. A missing token is the normal
  /// first-launch/signed-out state, not an error.
  Future<void> load() async {
    final String? token = await _storage.load();
    if (token == null) {
      return;
    }

    final User? user = await _userByUsername(token);
    if (user == null) {
      await _storage.clear();
      return;
    }

    _currentUser = user;
    notifyListeners();
  }

  Future<bool> signIn(String username, String password) async {
    final User? user = await _userByUsername(username);
    if (user == null || user.password != password) {
      return false;
    }

    _currentUser = user;
    // This mock token represents an authenticated session. We deliberately
    // do not store the password, even in this insecure teaching app.
    await _storage.save(user.username);
    notifyListeners();
    return true;
  }

  Future<void> signOut() async {
    _currentUser = null;
    await _storage.clear();
    notifyListeners();
  }

  Future<User?> _userByUsername(String username) async {
    final String raw = await rootBundle.loadString('assets/data/users.json');
    final Map<String, dynamic> data = jsonDecode(raw) as Map<String, dynamic>;
    final List<dynamic> users = data['users'] as List<dynamic>;

    for (final dynamic item in users) {
      final User user = User.fromJson(item as Map<String, dynamic>);
      if (user.username == username) {
        return user;
      }
    }

    return null;
  }
}
