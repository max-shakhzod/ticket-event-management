import 'ticket_model.dart';

/// The three possible outcomes when scanning a QR code against the database.
enum ScanStatus {
  /// Ticket exists and has not been used yet — admission granted.
  valid,

  /// QR payload could not be matched to any ticket in the database.
  invalid,

  /// Ticket was already scanned — shows who scanned it and when.
  alreadyUsed,
}

/// Encapsulates the result of validating a scanned QR code.
///
/// Returned by [TicketRepository.validateAndScanTicket] and consumed
/// by [RegisterScreen] to display the appropriate UI state.
class ScanResult {
  final ScanStatus status;

  /// The ticket data. Non-null for [ScanStatus.valid] and [ScanStatus.alreadyUsed].
  /// Null for [ScanStatus.invalid].
  final TicketModel? ticket;

  /// A human-readable message describing the scan outcome.
  final String message;

  const ScanResult({
    required this.status,
    this.ticket,
    required this.message,
  });

  /// Factory for a successful scan.
  factory ScanResult.valid(TicketModel ticket) => ScanResult(
        status: ScanStatus.valid,
        ticket: ticket,
        message: 'Ticket verified — admission granted',
      );

  /// Factory for an unrecognized QR code.
  factory ScanResult.invalid() => ScanResult(
        status: ScanStatus.invalid,
        ticket: null,
        message: 'Ticket not found in the database',
      );

  /// Factory for a ticket that was already scanned.
  factory ScanResult.alreadyUsed(TicketModel ticket) => ScanResult(
        status: ScanStatus.alreadyUsed,
        ticket: ticket,
        message:
            'This ticket was already scanned on ${ticket.scannedAt ?? "unknown date"} by ${ticket.scannedBy ?? "unknown"}',
      );

  bool get isValid => status == ScanStatus.valid;
  bool get isInvalid => status == ScanStatus.invalid;
  bool get isAlreadyUsed => status == ScanStatus.alreadyUsed;
}
