import 'package:flutter/material.dart';
import 'package:ticket_event_management/models/models.dart';
import 'package:ticket_event_management/theme/colors.dart';
import 'package:ticket_event_management/widgets/common_button_widget.dart';
import '../custom_icons/icon.dart';

/// Displays the result of scanning a ticket QR code.
///
/// Shows three distinct UI states:
/// - ✅ Valid — green theme, checkmark, full ticket details
/// - ❌ Invalid — red theme, X icon, not-found message
/// - ⚠️ Already Used — amber theme, warning icon, original scan info
class RegisterScreen extends StatelessWidget {
  final ScanResult scanResult;

  const RegisterScreen({super.key, required this.scanResult});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: customWhite,
        title: const Text(
          'Ticketio',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Montserrat-Regular',
            letterSpacing: 0.2,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: GestureDetector(
          child: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onTap: () => Navigator.of(context).pop(),
        ),
        elevation: 0.5,
        shadowColor: Colors.grey[600],
      ),
      body: Container(
        color: const Color(0xFFF6F6F6),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  _buildResultCard(),
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                    child: CommonButtonWidget(
                      onPressed: () => Navigator.of(context).pop(),
                      text: 'Scan Next Ticket',
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    final config = _getStatusConfig();

    return Container(
      width: 331,
      decoration: BoxDecoration(
        color: customWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(width: 1, color: const Color(0xFFD8D5D5)),
        boxShadow: [
          BoxShadow(
            color: config.color.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Status header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: config.color.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Text(
                  config.title,
                  style: TextStyle(
                    fontFamily: 'Montserrat-Regular',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: config.color,
                  ),
                ),
                const SizedBox(height: 16),
                _AnimatedStatusIcon(icon: config.icon, color: config.color),
              ],
            ),
          ),

          // Status message
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Text(
              scanResult.message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: config.color.withValues(alpha: 0.85),
              ),
            ),
          ),

          // Ticket details (only for valid and already-used)
          if (scanResult.ticket != null) ...[
            const Divider(height: 1, indent: 15, endIndent: 15),
            _buildTicketDetails(config),
          ],

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTicketDetails(_StatusConfig config) {
    final ticket = scanResult.ticket!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(MyFlutterApp.vector, size: 15),
              const SizedBox(width: 10),
              const Text(
                'Ticket Details',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildDetailRow('Ticket ID', ticket.ticketId),
          _buildDetailRow('Holder', ticket.holderName),
          _buildDetailRow('Section', ticket.section),
          _buildDetailRow('Seat', ticket.seat),
          _buildDetailRow(
            'Category',
            ticket.category,
            valueColor: _getCategoryColor(ticket.category),
          ),
          if (ticket.eventName.isNotEmpty)
            _buildDetailRow('Event', ticket.eventName),
          if (scanResult.isAlreadyUsed) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFFB74D), width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Previous Scan Info',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFE65100),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Scanned at: ${_formatTimestamp(ticket.scannedAt)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF795548),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Scanned by: ${ticket.scannedBy ?? "Unknown"}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF795548),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    if (value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF9E9E9E),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: valueColor ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _StatusConfig _getStatusConfig() {
    switch (scanResult.status) {
      case ScanStatus.valid:
        return _StatusConfig(
          title: 'Ticket Verified',
          icon: Icons.check_circle_rounded,
          color: customGreen,
        );
      case ScanStatus.invalid:
        return _StatusConfig(
          title: 'Invalid Ticket',
          icon: Icons.cancel_rounded,
          color: const Color(0xFFE53935),
        );
      case ScanStatus.alreadyUsed:
        return _StatusConfig(
          title: 'Already Scanned',
          icon: Icons.warning_amber_rounded,
          color: const Color(0xFFFFA726),
        );
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'vip':
        return const Color(0xFF3E477D);
      case 'free':
      case 'free standing':
        return const Color(0xFFFFA726);
      case 'cat 1':
        return const Color(0xFF5C6BC0);
      case 'cat 2':
        return const Color(0xFFFF4081);
      default:
        return customGreen;
    }
  }

  String _formatTimestamp(String? isoTimestamp) {
    if (isoTimestamp == null || isoTimestamp.isEmpty) return 'Unknown';
    try {
      final dt = DateTime.parse(isoTimestamp);
      final day = dt.day.toString().padLeft(2, '0');
      final month = dt.month.toString().padLeft(2, '0');
      final year = dt.year;
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      return '$day/$month/$year at $hour:$minute';
    } catch (_) {
      return isoTimestamp;
    }
  }
}

/// Configuration bundle for each scan status visual state.
class _StatusConfig {
  final String title;
  final IconData icon;
  final Color color;

  const _StatusConfig({
    required this.title,
    required this.icon,
    required this.color,
  });
}

/// An animated icon that scales in on first build for visual feedback.
class _AnimatedStatusIcon extends StatefulWidget {
  final IconData icon;
  final Color color;

  const _AnimatedStatusIcon({required this.icon, required this.color});

  @override
  State<_AnimatedStatusIcon> createState() => _AnimatedStatusIconState();
}

class _AnimatedStatusIconState extends State<_AnimatedStatusIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Icon(widget.icon, color: widget.color, size: 90),
    );
  }
}
