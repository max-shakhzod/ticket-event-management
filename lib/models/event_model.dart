/// Represents an event with its configuration and ticket capacity.
class EventModel {
  final int? id; // SQLite auto-increment primary key
  final String eventId;
  final String name;
  final String date; // ISO 8601 date string
  final String venue;
  final int totalTickets;
  final String status; // upcoming, live, ended

  const EventModel({
    this.id,
    required this.eventId,
    required this.name,
    required this.date,
    required this.venue,
    required this.totalTickets,
    this.status = 'upcoming',
  });

  factory EventModel.fromJson(Map<String, dynamic> json) => EventModel(
        id: json['id'] as int?,
        eventId: json['eventId'] as String? ?? '',
        name: json['name'] as String? ?? '',
        date: json['date'] as String? ?? '',
        venue: json['venue'] as String? ?? '',
        totalTickets: json['totalTickets'] as int? ?? 0,
        status: json['status'] as String? ?? 'upcoming',
      );

  Map<String, dynamic> toJson() => {
        'eventId': eventId,
        'name': name,
        'date': date,
        'venue': venue,
        'totalTickets': totalTickets,
        'status': status,
      };

  EventModel copyWith({
    int? id,
    String? eventId,
    String? name,
    String? date,
    String? venue,
    int? totalTickets,
    String? status,
  }) {
    return EventModel(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      name: name ?? this.name,
      date: date ?? this.date,
      venue: venue ?? this.venue,
      totalTickets: totalTickets ?? this.totalTickets,
      status: status ?? this.status,
    );
  }

  @override
  String toString() =>
      'EventModel(eventId: $eventId, name: $name, status: $status)';
}
