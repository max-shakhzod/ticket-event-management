import 'package:flutter/material.dart';

import '../db/ticket_repository.dart';
import '../models/models.dart';
import '../theme/colors.dart';
import '../widgets/common_ticket_info_widget.dart';
import '../widgets/top_common_buttons_widget.dart';
import 'register_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
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
  List<TicketModel> _tickets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    setState(() => _isLoading = true);
    final category = _categories[_selectedIndex];
    final tickets = await _repo.getScannedHistory(
      categoryFilter: category == 'All' ? null : category,
    );
    if (mounted) {
      setState(() {
        _tickets = tickets;
        _isLoading = false;
      });
    }
  }

  Color _colorForCategory(String category) {
    final idx = _categories.indexOf(category);
    if (idx < 0) return customGreen;
    return _categoryColors[idx];
  }

  void _viewDetails(TicketModel ticket) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            RegisterScreen(scanResult: ScanResult.alreadyUsed(ticket)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: const Text(
          'Ticketio',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
          ),
        ),
        elevation: 0.5,
        shadowColor: Colors.grey[600],
      ),
      backgroundColor: const Color(0xFFF6F6F6),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: TopCommonButtonsWidget(
              buttonLabels: _categories,
              buttonColors: _categoryColors,
              onPressed: (index) {
                setState(() => _selectedIndex = index);
                _loadTickets();
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: RefreshIndicator(
              color: customGreen,
              onRefresh: _loadTickets,
              child: _buildBody(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: customGreen));
    }

    if (_tickets.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 80),
          const Icon(Icons.history, size: 64, color: Color(0xFFD8D5D5)),
          const SizedBox(height: 16),
          Text(
            _selectedIndex == 0
                ? 'No tickets scanned yet'
                : 'No ${_categories[_selectedIndex]} tickets scanned',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF9E9E9E),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      itemCount: _tickets.length,
      itemBuilder: (context, index) {
        final ticket = _tickets[index];
        final catColor = _colorForCategory(ticket.category);
        return CommonTicketInfoWidget(
          field1: ticket.category.isEmpty ? 'Unknown' : ticket.category,
          field2: 'ID  ${ticket.ticketId}',
          buttonText: 'View Details',
          buttonColors: [catColor],
          onPressed: () => _viewDetails(ticket),
        );
      },
    );
  }
}
