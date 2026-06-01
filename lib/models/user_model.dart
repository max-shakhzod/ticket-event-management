/// Defines the access roles within the Ticketio application.
///
/// - [superAdmin]: Full access — manage events, staff, reports, and scanning.
/// - [eventManager]: Manage their assigned event — view dashboard, history, import tickets.
/// - [scanner]: Scan-only access — cannot navigate to history, settings, or reports.
enum UserRole {
  superAdmin,
  eventManager,
  scanner;

  /// Parse a role from its string name (case-insensitive).
  static UserRole fromString(String value) {
    switch (value.toLowerCase()) {
      case 'superadmin':
      case 'super_admin':
        return UserRole.superAdmin;
      case 'eventmanager':
      case 'event_manager':
        return UserRole.eventManager;
      case 'scanner':
        return UserRole.scanner;
      default:
        return UserRole.scanner;
    }
  }

  String get displayName {
    switch (this) {
      case UserRole.superAdmin:
        return 'Super Admin';
      case UserRole.eventManager:
        return 'Event Manager';
      case UserRole.scanner:
        return 'Scanner';
    }
  }
}

/// Represents a staff user within the Ticketio system.
class UserModel {
  final int? id; // SQLite auto-increment primary key
  final String userId;
  final String name;
  final String email;
  final UserRole role;
  final String? assignedEventId;
  final bool isActive;

  const UserModel({
    this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    this.assignedEventId,
    this.isActive = true,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as int?,
        userId: json['userId'] as String? ?? '',
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        role: UserRole.fromString(json['role'] as String? ?? 'scanner'),
        assignedEventId: json['assignedEventId'] as String?,
        isActive: (json['isActive'] as int?) == 1,
      );

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'name': name,
        'email': email,
        'role': role.name,
        'assignedEventId': assignedEventId,
        'isActive': isActive ? 1 : 0,
      };

  UserModel copyWith({
    int? id,
    String? userId,
    String? name,
    String? email,
    UserRole? role,
    String? assignedEventId,
    bool? isActive,
  }) {
    return UserModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      assignedEventId: assignedEventId ?? this.assignedEventId,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() =>
      'UserModel(userId: $userId, name: $name, role: ${role.displayName})';
}
