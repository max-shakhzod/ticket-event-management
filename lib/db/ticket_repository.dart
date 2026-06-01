import '../models/models.dart';
import 'db_admin.dart';

/// Repository that provides a clean API for ticket operations.
///
/// Abstracts over [DBAdmin] and encapsulates business logic such as
/// scan validation. In later phases, this will also manage sync between
/// local SQLite and a remote backend (Firebase Firestore / REST API).
class TicketRepository {
  final DBAdmin _db;

  TicketRepository({DBAdmin? db}) : _db = db ?? DBAdmin();

  /// Validates a scanned QR code and processes the ticket.
  ///
  /// Flow:
  /// 1. Parse the raw QR value to extract a ticket ID.
  /// 2. Look up the ticket in the local database.
  /// 3. Return one of three outcomes:
  ///    - [ScanResult.valid] — ticket found, not yet used → mark as used
  ///    - [ScanResult.alreadyUsed] — ticket found, already scanned
  ///    - [ScanResult.invalid] — ticket not found in database
  Future<ScanResult> validateAndScanTicket(
    String rawQrValue, {
    String scannedBy = 'local_user',
  }) async {
    // Step 1: Parse QR payload
    final parsed = TicketModel.fromQrPayload(rawQrValue);
    if (parsed == null) {
      await _logScan(
        ticketId: rawQrValue,
        scannedBy: scannedBy,
        result: 'invalid_parse',
      );
      return ScanResult.invalid();
    }

    // Step 2: Database lookup
    final existing = await _db.getTicketById(parsed.ticketId);
    if (existing == null) {
      await _logScan(
        ticketId: parsed.ticketId,
        scannedBy: scannedBy,
        result: 'invalid_not_found',
      );
      return ScanResult.invalid();
    }

    // Step 3: Check if already used
    if (existing.isUsed) {
      await _logScan(
        ticketId: parsed.ticketId,
        scannedBy: scannedBy,
        result: 'already_used',
      );
      return ScanResult.alreadyUsed(existing);
    }

    // Step 4: Mark as used
    await _db.markTicketUsed(parsed.ticketId, scannedBy);
    final updatedTicket = existing.copyWith(
      isUsed: true,
      scannedAt: DateTime.now().toIso8601String(),
      scannedBy: scannedBy,
    );

    await _logScan(
      ticketId: parsed.ticketId,
      scannedBy: scannedBy,
      result: 'valid',
      eventId: existing.eventId,
    );

    return ScanResult.valid(updatedTicket);
  }

  /// Retrieves scan history, optionally filtered by category.
  Future<List<TicketModel>> getScannedHistory({
    String? categoryFilter,
    int? limit,
    int? offset,
  }) {
    return _db.getScannedTickets(
      category: categoryFilter,
      limit: limit,
      offset: offset,
    );
  }

  /// Searches scanned tickets by ticket ID or holder name.
  Future<List<TicketModel>> searchHistory(String query) {
    return _db.searchScannedTickets(query);
  }

  /// Retrieves all tickets (scanned and unscanned).
  Future<List<TicketModel>> getAllTickets({
    String? category,
    String? eventId,
  }) {
    return _db.getAllTickets(category: category, eventId: eventId);
  }

  /// Retrieves scan statistics.
  Future<Map<String, dynamic>> getStats({String? eventId}) {
    return _db.getTicketStats(eventId: eventId);
  }

  /// Imports a batch of tickets into the database.
  Future<int> importTickets(List<TicketModel> tickets) {
    return _db.insertTickets(tickets);
  }

  /// Private helper to record every scan attempt in the audit log.
  Future<void> _logScan({
    required String ticketId,
    required String scannedBy,
    required String result,
    String? eventId,
  }) async {
    try {
      await _db.insertAuditLog(
        ticketId: ticketId,
        scannedBy: scannedBy,
        result: result,
        eventId: eventId,
      );
    } catch (_) {
      // Audit log failures should not break the scan flow
    }
  }
}
