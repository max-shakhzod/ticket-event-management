import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'package:ticket_event_management/custom_icons/icon.dart';
import 'package:ticket_event_management/db/ticket_repository.dart';
import 'package:ticket_event_management/models/models.dart';
import 'package:ticket_event_management/providers/auth_provider.dart';
import 'package:ticket_event_management/screens/screens.dart';
import 'package:ticket_event_management/theme/colors.dart';
import 'package:ticket_event_management/widgets/common_button_widget.dart';
import 'package:ticket_event_management/widgets/top_common_buttons_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _repo = TicketRepository();

  static const _categories = ['All', 'VIP', 'Free', 'Cat 1', 'Cat 2'];
  static const _categoryColors = [
    Color(0xFF32BAA5),
    Color(0xFF3E477D),
    Color(0xFFFFA726),
    Color(0xFF5C6BC0),
    Color(0xFFFF4081),
  ];

  int _selectedIndex = 0;
  Map<String, dynamic> _stats = {'total': 0, 'scanned': 0, 'byCategory': {}};
  List<TicketModel> _recentTickets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final category = _categories[_selectedIndex];
    final results = await Future.wait([
      _repo.getStats(),
      _repo.getScannedHistory(
        categoryFilter: category == 'All' ? null : category,
        limit: 20,
      ),
    ]);
    if (mounted) {
      setState(() {
        _stats = results[0] as Map<String, dynamic>;
        _recentTickets = results[1] as List<TicketModel>;
        _isLoading = false;
      });
    }
  }

  void _logout() {
    Navigator.of(context).popUntil((route) => route.isFirst);
    context.read<AuthProvider>().logout();
  }

  Color _colorForCategory(String category) {
    final idx = _categories.indexOf(category);
    if (idx < 0) return customGreen;
    return _categoryColors[idx];
  }

  @override
  Widget build(BuildContext context) {
    final total = _stats['total'] as int? ?? 0;
    final scanned = _stats['scanned'] as int? ?? 0;
    final pct = total == 0 ? 0.0 : (scanned / total).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: customWhite,
        title: const Text(
          'Ticketio',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Montserrat-Regular',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            tooltip: 'Sign out',
            onPressed: _logout,
          ),
        ],
        elevation: 0.2,
        shadowColor: Colors.grey[600],
      ),
      backgroundColor: customWhite,
      body: RefreshIndicator(
        color: customGreen,
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats card
              if (!_isLoading)
                _StatsCard(total: total, scanned: scanned, pct: pct),
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 30),
                    child: CircularProgressIndicator(color: customGreen),
                  ),
                ),

              const SizedBox(height: 16),

              // Section header
              const Row(
                children: [
                  SizedBox(width: 8),
                  Icon(MyFlutterApp.vector, size: 15),
                  SizedBox(width: 12),
                  Text(
                    'Scanned Ticket',
                    style: TextStyle(
                      fontFamily: 'Montserrat-Regular',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Category filter buttons
              TopCommonButtonsWidget(
                onPressed: (index) {
                  setState(() => _selectedIndex = index);
                  _loadData();
                },
                buttonLabels: _categories,
                buttonColors: _categoryColors,
              ),
              const SizedBox(height: 12),

              // Ticket list or empty state
              if (!_isLoading && _recentTickets.isEmpty)
                Center(child: _buildEmptyState(context)),

              if (!_isLoading && _recentTickets.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _recentTickets.length,
                  itemBuilder: (context, index) {
                    final ticket = _recentTickets[index];
                    final catColor = _colorForCategory(ticket.category);
                    return _TicketRow(
                      ticket: ticket,
                      categoryColor: catColor,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RegisterScreen(
                            scanResult: ScanResult.alreadyUsed(ticket),
                          ),
                        ),
                      ),
                    );
                  },
                ),

              const SizedBox(height: 24),

              // Action buttons
              Center(
                child: CommonButtonWidget(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ScannerScreen()),
                  ),
                  text: 'Scan Ticket',
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const HistoryScreen()),
                  ).then((_) => _loadData()),
                  child: const Text(
                    'View history',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: customGreen,
                      fontSize: 14.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Text(
            'There seems to be\nnothing here',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF53BF9D),
              fontSize: 18.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SvgPicture.asset(
          'assets/images/Empty-amico.svg',
          width: MediaQuery.of(context).size.width * 0.65,
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _StatsCard extends StatelessWidget {
  final int total;
  final int scanned;
  final double pct;

  const _StatsCard({
    required this.total,
    required this.scanned,
    required this.pct,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatPill(
                label: 'Scanned',
                value: '$scanned',
                color: customGreen,
              ),
              _StatPill(
                label: 'Total',
                value: '$total',
                color: const Color(0xFF9E9E9E),
              ),
              _StatPill(
                label: 'Attendance',
                value: '${(pct * 100).toStringAsFixed(0)}%',
                color: const Color(0xFF5C6BC0),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 8,
              backgroundColor: const Color(0xFFE0E0E0),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(customGreen),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatPill({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: color,
            fontFamily: 'Montserrat',
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF9E9E9E),
            fontFamily: 'Montserrat',
          ),
        ),
      ],
    );
  }
}

class _TicketRow extends StatelessWidget {
  final TicketModel ticket;
  final Color categoryColor;
  final VoidCallback onTap;

  const _TicketRow({
    required this.ticket,
    required this.categoryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFEEEEEE)),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: categoryColor.withValues(alpha: 0.15),
          child: Text(
            ticket.category.isNotEmpty
                ? ticket.category.substring(0, 1).toUpperCase()
                : '?',
            style: TextStyle(
              color: categoryColor,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
        title: Text(
          ticket.holderName.isNotEmpty ? ticket.holderName : ticket.ticketId,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Montserrat',
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          ticket.category,
          style: TextStyle(
            fontSize: 12,
            color: categoryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Color(0xFFBDBDBD)),
        onTap: onTap,
      ),
    );
  }
}
