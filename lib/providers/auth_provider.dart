import 'package:flutter/foundation.dart';

import '../db/auth_repository.dart';
import '../models/models.dart';

/// Manages authentication state for the entire app.
///
/// Wrap [MaterialApp] with a [ChangeNotifierProvider] of this class.
/// Screens watch it to react to login / logout events.
class AuthProvider extends ChangeNotifier {
  final AuthRepository _repo;

  UserModel? _currentUser;
  // Start true so AuthGate shows a loading spinner on first build while
  // restoreSession() runs asynchronously.
  bool _isLoading = true;
  String? _error;

  AuthProvider(this._repo);

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get error => _error;
  UserRole get role => _currentUser?.role ?? UserRole.scanner;

  /// Called once at startup (from AuthGate.initState) to restore a saved
  /// session from secure storage.
  Future<void> restoreSession() async {
    _isLoading = true;
    notifyListeners();
    _currentUser = await _repo.restoreSession();
    _isLoading = false;
    notifyListeners();
  }

  /// Attempts to log in with [email] and [password].
  /// Returns true on success, false on failure (check [error] for message).
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final user = await _repo.login(email, password);
    _isLoading = false;

    if (user != null) {
      _currentUser = user;
      await _repo.saveSession(user);
    } else {
      _error = 'Invalid email or password. Please try again.';
    }
    notifyListeners();
    return user != null;
  }

  /// Clears the session and current user, returning to the login screen.
  Future<void> logout() async {
    await _repo.clearSession();
    _currentUser = null;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
