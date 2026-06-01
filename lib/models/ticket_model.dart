import 'dart:convert';

/// Represents a single event ticket with all associated metadata.
///
/// Tickets are stored locally in SQLite and synced to a remote backend.
/// A ticket can be in one of three states:
/// - Unused: [isUsed] is false
/// - Used: [isUsed] is true, with [scannedAt] and [scannedBy] populated
/// - Invalid: ticket ID not found in the database (handled externally)
class TicketModel {
  final int? id; // SQLite auto-increment primary key
  final String ticketId;
  final String holderName;
  final String section;
  final String seat;
  final String category; // VIP, Free, Cat 1, Cat 2
  final String eventId;
  final String eventName;
  final String eventDate;
  final bool isUsed;
  final String? scannedAt; // ISO 8601 timestamp
  final String? scannedBy; // userId of scanner

  const TicketModel({
    this.id,
    required this.ticketId,
    required this.holderName,
    required this.section,
    required this.seat,
    required this.category,
    required this.eventId,
    required this.eventName,
    required this.eventDate,
    this.isUsed = false,
    this.scannedAt,
    this.scannedBy,
  });

  /// Creates a [TicketModel] from a SQLite row map.
  factory TicketModel.fromJson(Map<String, dynamic> json) => TicketModel(
        id: json['id'] as int?,
        ticketId: json['ticketId'] as String? ?? '',
        holderName: json['holderName'] as String? ?? '',
        section: json['section'] as String? ?? '',
        seat: json['seat'] as String? ?? '',
        category: json['category'] as String? ?? '',
        eventId: json['eventId'] as String? ?? '',
        eventName: json['eventName'] as String? ?? '',
        eventDate: json['eventDate'] as String? ?? '',
        isUsed: (json['isUsed'] as int?) == 1,
        scannedAt: json['scannedAt'] as String?,
        scannedBy: json['scannedBy'] as String?,
      );

  /// Parses a scanned QR code payload into a [TicketModel].
  ///
  /// Supports two formats:
  /// 1. **JSON**: `{"ticketId":"TKT-001","holderName":"John",...}`
  /// 2. **Plain ticket ID**: `TKT-001` (returns a minimal model for DB lookup)
  ///
  /// Returns `null` if the payload cannot be parsed.
  static TicketModel? fromQrPayload(String rawValue) {
    final trimmed = rawValue.trim();
    if (trimmed.isEmpty) return null;

    // Attempt JSON parse first
    if (trimmed.startsWith('{')) {
      try {
        final Map<String, dynamic> json = jsonDecode(trimmed);
        if (json['ticketId'] == null || (json['ticketId'] as String).isEmpty) {
          return null;
        }
        return TicketModel(
          ticketId: json['ticketId'] as String,
          holderName: json['holderName'] as String? ?? '',
          section: json['section'] as String? ?? '',
          seat: json['seat'] as String? ?? '',
          category: json['category'] as String? ?? '',
          eventId: json['eventId'] as String? ?? '',
          eventName: json['eventName'] as String? ?? '',
          eventDate: json['eventDate'] as String? ?? '',
        );
      } catch (_) {
        return null;
      }
    }

    // Treat as plain ticket ID string
    return TicketModel(
      ticketId: trimmed,
      holderName: '',
      section: '',
      seat: '',
      category: '',
      eventId: '',
      eventName: '',
      eventDate: '',
    );
  }

  /// Converts to a map suitable for SQLite insertion.
  /// Excludes [id] since it's auto-incremented.
  Map<String, dynamic> toJson() => {
        'ticketId': ticketId,
        'holderName': holderName,
        'section': section,
        'seat': seat,
        'category': category,
        'eventId': eventId,
        'eventName': eventName,
        'eventDate': eventDate,
        'isUsed': isUsed ? 1 : 0,
        'scannedAt': scannedAt,
        'scannedBy': scannedBy,
      };

  /// Returns a copy of this model with the given fields replaced.
  TicketModel copyWith({
    int? id,
    String? ticketId,
    String? holderName,
    String? section,
    String? seat,
    String? category,
    String? eventId,
    String? eventName,
    String? eventDate,
    bool? isUsed,
    String? scannedAt,
    String? scannedBy,
  }) {
    return TicketModel(
      id: id ?? this.id,
      ticketId: ticketId ?? this.ticketId,
      holderName: holderName ?? this.holderName,
      section: section ?? this.section,
      seat: seat ?? this.seat,
      category: category ?? this.category,
      eventId: eventId ?? this.eventId,
      eventName: eventName ?? this.eventName,
      eventDate: eventDate ?? this.eventDate,
      isUsed: isUsed ?? this.isUsed,
      scannedAt: scannedAt ?? this.scannedAt,
      scannedBy: scannedBy ?? this.scannedBy,
    );
  }

  @override
  String toString() =>
      'TicketModel(ticketId: $ticketId, holder: $holderName, category: $category, isUsed: $isUsed)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TicketModel &&
          runtimeType == other.runtimeType &&
          ticketId == other.ticketId;

  @override
  int get hashCode => ticketId.hashCode;
}
