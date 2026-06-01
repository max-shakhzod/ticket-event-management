import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/models.dart';
import 'db_admin.dart';

/// Handles authentication: password hashing, login verification, and
/// session persistence via flutter_secure_storage.
class AuthRepository {
  final DBAdmin _db;
  final FlutterSecureStorage _storage;

  static const _keyUserId = 'ticketio_user_id';

  AuthRepository({DBAdmin? db, FlutterSecureStorage? storage})
      : _db = db ?? DBAdmin(),
        _storage = storage ?? const FlutterSecureStorage();

  // ---------------------------------------------------------------------------
  // Password helpers
  // ---------------------------------------------------------------------------

  String _generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  String _hashPassword(String password, String salt) {
    final bytes = utf8.encode(salt + password);
    return sha256.convert(bytes).toString();
  }

  String _generateUserId() {
    final random = Random.secure();
    final ts = DateTime.now().millisecondsSinceEpoch;
    final rand = random.nextInt(999999).toString().padLeft(6, '0');
    return 'USR-$ts-$rand';
  }

  // ---------------------------------------------------------------------------
  // Auth operations
  // ---------------------------------------------------------------------------

  /// Verifies credentials against the database.
  /// Returns the [UserModel] on success, or null on failure.
  Future<UserModel?> login(String email, String password) async {
    final row =
        await _db.getUserByEmailWithCredentials(email.toLowerCase().trim());
    if (row == null) return null;

    final storedHash = row['passwordHash'] as String? ?? '';
    final storedSalt = row['passwordSalt'] as String? ?? '';

    if (storedHash.isEmpty) return null;

    final inputHash = _hashPassword(password, storedSalt);
    if (inputHash != storedHash) return null;

    return UserModel.fromJson(row);
  }

  /// Creates a new staff user with a hashed password.
  Future<void> createUser({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    String? assignedEventId,
  }) async {
    final salt = _generateSalt();
    final hash = _hashPassword(password, salt);
    final user = UserModel(
      userId: _generateUserId(),
      name: name,
      email: email.toLowerCase().trim(),
      role: role,
      assignedEventId: assignedEventId,
    );
    await _db.insertUserWithPassword(user, hash, salt);
  }

  /// Seeds a default super-admin account if no users exist.
  /// Default credentials: admin@ticketio.com / Admin1234!
  Future<void> seedDefaultAdmin() async {
    final exists = await _db.hasUsers();
    if (exists) return;

    await createUser(
      name: 'Super Admin',
      email: 'admin@ticketio.com',
      password: 'Admin1234!',
      role: UserRole.superAdmin,
    );
  }

  // ---------------------------------------------------------------------------
  // Session management
  // ---------------------------------------------------------------------------

  /// Persists the logged-in user's ID to secure storage.
  Future<void> saveSession(UserModel user) async {
    await _storage.write(key: _keyUserId, value: user.userId);
  }

  /// Restores a previously saved session. Returns null if no session exists
  /// or the user record is no longer in the database.
  Future<UserModel?> restoreSession() async {
    final userId = await _storage.read(key: _keyUserId);
    if (userId == null) return null;
    return await _db.getUserById(userId);
  }

  /// Removes the saved session from secure storage.
  Future<void> clearSession() async {
    await _storage.delete(key: _keyUserId);
  }
}
