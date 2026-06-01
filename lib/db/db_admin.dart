import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/models.dart';

/// Singleton database manager for local SQLite storage.
///
/// Manages four tables:
/// - `tickets` — imported ticket records with scan status
/// - `events` — event configuration and metadata
/// - `users` — staff accounts with roles and hashed credentials
/// - `audit_logs` — immutable scan audit trail
class DBAdmin {
  static final DBAdmin _instance = DBAdmin._();
  DBAdmin._();
  factory DBAdmin() => _instance;

  Database? _myDatabase;

  Future<Database> get database => _checkDatabase();

  Future<Database> _checkDatabase() async {
    _myDatabase ??= await _initDatabase();
    return _myDatabase!;
  }

  Future<Database> _initDatabase() async {
    final Directory myDirectory = await getApplicationDocumentsDirectory();
    final String pathDatabase = join(myDirectory.path, 'TicketioDB.db');
    return await openDatabase(
      pathDatabase,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tickets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ticketId TEXT NOT NULL UNIQUE,
        holderName TEXT NOT NULL DEFAULT '',
        section TEXT NOT NULL DEFAULT '',
        seat TEXT NOT NULL DEFAULT '',
        category TEXT NOT NULL DEFAULT '',
        eventId TEXT NOT NULL DEFAULT '',
        eventName TEXT NOT NULL DEFAULT '',
        eventDate TEXT NOT NULL DEFAULT '',
        isUsed INTEGER NOT NULL DEFAULT 0,
        scannedAt TEXT,
        scannedBy TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE events (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        eventId TEXT NOT NULL UNIQUE,
        name TEXT NOT NULL,
        date TEXT NOT NULL,
        venue TEXT NOT NULL DEFAULT '',
        totalTickets INTEGER NOT NULL DEFAULT 0,
        status TEXT NOT NULL DEFAULT 'upcoming'
      )
    ''');

    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId TEXT NOT NULL UNIQUE,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        role TEXT NOT NULL DEFAULT 'scanner',
        assignedEventId TEXT,
        isActive INTEGER NOT NULL DEFAULT 1,
        passwordHash TEXT NOT NULL DEFAULT '',
        passwordSalt TEXT NOT NULL DEFAULT ''
      )
    ''');

    await db.execute('''
      CREATE TABLE audit_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ticketId TEXT NOT NULL,
        scannedBy TEXT NOT NULL,
        scannedAt TEXT NOT NULL,
        deviceInfo TEXT,
        result TEXT NOT NULL,
        eventId TEXT
      )
    ''');

    await db.execute(
        'CREATE INDEX idx_tickets_ticketId ON tickets(ticketId)');
    await db.execute(
        'CREATE INDEX idx_tickets_category ON tickets(category)');
    await db.execute(
        'CREATE INDEX idx_tickets_eventId ON tickets(eventId)');
    await db.execute(
        'CREATE INDEX idx_audit_logs_ticketId ON audit_logs(ticketId)');
    await db.execute(
        'CREATE UNIQUE INDEX idx_users_email ON users(email)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
          'ALTER TABLE users ADD COLUMN passwordHash TEXT NOT NULL DEFAULT ""');
      await db.execute(
          'ALTER TABLE users ADD COLUMN passwordSalt TEXT NOT NULL DEFAULT ""');
      await db.execute(
          'CREATE UNIQUE INDEX IF NOT EXISTS idx_users_email ON users(email)');
    }
  }

  // ---------------------------------------------------------------------------
  // Ticket operations
  // ---------------------------------------------------------------------------

  Future<TicketModel?> getTicketById(String ticketId) async {
    final db = await _checkDatabase();
    final results = await db.query(
      'tickets',
      where: 'ticketId = ?',
      whereArgs: [ticketId],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return TicketModel.fromJson(results.first);
  }

  Future<int> markTicketUsed(String ticketId, String scannedBy) async {
    final db = await _checkDatabase();
    final now = DateTime.now().toIso8601String();
    return await db.update(
      'tickets',
      {
        'isUsed': 1,
        'scannedAt': now,
        'scannedBy': scannedBy,
      },
      where: 'ticketId = ?',
      whereArgs: [ticketId],
    );
  }

  Future<List<TicketModel>> getAllTickets({
    String? category,
    String? eventId,
  }) async {
    final db = await _checkDatabase();
    final conditions = <String>[];
    final args = <dynamic>[];

    if (category != null && category.isNotEmpty && category != 'All') {
      conditions.add('category = ?');
      args.add(category);
    }
    if (eventId != null && eventId.isNotEmpty) {
      conditions.add('eventId = ?');
      args.add(eventId);
    }

    final results = await db.query(
      'tickets',
      where: conditions.isEmpty ? null : conditions.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'id DESC',
    );
    return results.map((e) => TicketModel.fromJson(e)).toList();
  }

  Future<List<TicketModel>> getScannedTickets({
    String? category,
    int? limit,
    int? offset,
  }) async {
    final db = await _checkDatabase();
    final conditions = <String>['isUsed = 1'];
    final args = <dynamic>[];

    if (category != null && category.isNotEmpty && category != 'All') {
      conditions.add('category = ?');
      args.add(category);
    }

    final results = await db.query(
      'tickets',
      where: conditions.join(' AND '),
      whereArgs: args,
      orderBy: 'scannedAt DESC',
      limit: limit,
      offset: offset,
    );
    return results.map((e) => TicketModel.fromJson(e)).toList();
  }

  Future<List<TicketModel>> searchScannedTickets(String query) async {
    final db = await _checkDatabase();
    final results = await db.query(
      'tickets',
      where: 'isUsed = 1 AND (ticketId LIKE ? OR holderName LIKE ?)',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'scannedAt DESC',
    );
    return results.map((e) => TicketModel.fromJson(e)).toList();
  }

  Future<int> insertTicket(TicketModel ticket) async {
    final db = await _checkDatabase();
    return await db.insert(
      'tickets',
      ticket.toJson(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<int> insertTickets(List<TicketModel> tickets) async {
    final db = await _checkDatabase();
    int count = 0;
    await db.transaction((txn) async {
      final batch = txn.batch();
      for (final ticket in tickets) {
        batch.insert(
          'tickets',
          ticket.toJson(),
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
      final results = await batch.commit(noResult: false);
      count = results.where((r) => r != 0).length;
    });
    return count;
  }

  Future<Map<String, dynamic>> getTicketStats({String? eventId}) async {
    final db = await _checkDatabase();
    String? where;
    List<dynamic>? whereArgs;

    if (eventId != null && eventId.isNotEmpty) {
      where = 'eventId = ?';
      whereArgs = [eventId];
    }

    final allTickets = await db.query('tickets',
        where: where, whereArgs: whereArgs);
    final scannedTickets = await db.query('tickets',
        where: '${where != null ? "$where AND " : ""}isUsed = 1',
        whereArgs: whereArgs);

    final Map<String, Map<String, int>> byCategory = {};
    for (final row in allTickets) {
      final cat = row['category'] as String? ?? 'Unknown';
      byCategory.putIfAbsent(cat, () => {'total': 0, 'scanned': 0});
      byCategory[cat]!['total'] = (byCategory[cat]!['total'] ?? 0) + 1;
    }
    for (final row in scannedTickets) {
      final cat = row['category'] as String? ?? 'Unknown';
      if (byCategory.containsKey(cat)) {
        byCategory[cat]!['scanned'] =
            (byCategory[cat]!['scanned'] ?? 0) + 1;
      }
    }

    return {
      'total': allTickets.length,
      'scanned': scannedTickets.length,
      'byCategory': byCategory,
    };
  }

  Future<int> deleteTicketsByEvent(String eventId) async {
    final db = await _checkDatabase();
    return await db.delete(
      'tickets',
      where: 'eventId = ?',
      whereArgs: [eventId],
    );
  }

  // ---------------------------------------------------------------------------
  // Audit log operations
  // ---------------------------------------------------------------------------

  Future<int> insertAuditLog({
    required String ticketId,
    required String scannedBy,
    required String result,
    String? deviceInfo,
    String? eventId,
  }) async {
    final db = await _checkDatabase();
    return await db.insert('audit_logs', {
      'ticketId': ticketId,
      'scannedBy': scannedBy,
      'scannedAt': DateTime.now().toIso8601String(),
      'deviceInfo': deviceInfo,
      'result': result,
      'eventId': eventId,
    });
  }

  Future<List<Map<String, dynamic>>> getAuditLogs({
    int? limit,
    int? offset,
  }) async {
    final db = await _checkDatabase();
    return await db.query(
      'audit_logs',
      orderBy: 'scannedAt DESC',
      limit: limit,
      offset: offset,
    );
  }

  // ---------------------------------------------------------------------------
  // Event operations
  // ---------------------------------------------------------------------------

  Future<int> insertEvent(EventModel event) async {
    final db = await _checkDatabase();
    return await db.insert(
      'events',
      event.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<EventModel>> getAllEvents() async {
    final db = await _checkDatabase();
    final results = await db.query('events', orderBy: 'date DESC');
    return results.map((e) => EventModel.fromJson(e)).toList();
  }

  Future<EventModel?> getEventById(String eventId) async {
    final db = await _checkDatabase();
    final results = await db.query(
      'events',
      where: 'eventId = ?',
      whereArgs: [eventId],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return EventModel.fromJson(results.first);
  }

  // ---------------------------------------------------------------------------
  // User operations
  // ---------------------------------------------------------------------------

  Future<int> insertUser(UserModel user) async {
    final db = await _checkDatabase();
    return await db.insert(
      'users',
      user.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Inserts a user together with their hashed password credentials.
  Future<int> insertUserWithPassword(
      UserModel user, String passwordHash, String passwordSalt) async {
    final db = await _checkDatabase();
    final data = {
      ...user.toJson(),
      'passwordHash': passwordHash,
      'passwordSalt': passwordSalt,
    };
    return await db.insert('users', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<UserModel?> getUserById(String userId) async {
    final db = await _checkDatabase();
    final results = await db.query(
      'users',
      where: 'userId = ?',
      whereArgs: [userId],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return UserModel.fromJson(results.first);
  }

  /// Returns the full user row (including passwordHash/passwordSalt) for auth.
  /// Only returns active users.
  Future<Map<String, dynamic>?> getUserByEmailWithCredentials(
      String email) async {
    final db = await _checkDatabase();
    final results = await db.query(
      'users',
      where: 'email = ? AND isActive = 1',
      whereArgs: [email],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return results.first;
  }

  Future<List<UserModel>> getAllUsers() async {
    final db = await _checkDatabase();
    final results = await db.query('users', orderBy: 'name ASC');
    return results.map((e) => UserModel.fromJson(e)).toList();
  }

  /// Returns true if at least one user account exists in the database.
  Future<bool> hasUsers() async {
    final db = await _checkDatabase();
    final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM users'));
    return (count ?? 0) > 0;
  }

  // ---------------------------------------------------------------------------
  // Utility
  // ---------------------------------------------------------------------------

  Future<void> close() async {
    final db = await _checkDatabase();
    await db.close();
    _myDatabase = null;
  }
}
