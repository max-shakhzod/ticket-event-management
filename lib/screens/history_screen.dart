import 'package:flutter/material.dart';
import '../widgets/common_ticket_info_widget.dart';
import 'register_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> ticketList = [
      {
        'field1': 'All',
        'field2': 'ID  1238243341',
        'buttonText': 'View Details',
        'onPressed': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const RegisterScreen(
                url: '',
              ),
            ),
          );
        },
        'buttonColors': [
          const Color(0xFF32BAA5),
        ],
      },
      {
        'field1': 'VIP',
        'field2': 'ID  1111111111',
        'buttonText': 'View Details',
        'onPressed': () {
          // Do something when the button is pressed
        },
        'buttonColors': [
          const Color(0xFF3E477D),
        ],
      },
      {
        'field1': 'Free Standing',
        'field2': 'ID  1238243341',
        'buttonText': 'View Details',
        'onPressed': () {
          // Do something when the button is pressed
        },
        'buttonColors': [
          const Color(0xFFFFA726),
        ],
      },
      {
        'field1': 'Cat 1',
        'field2': 'ID  1111111111',
        'buttonText': 'View Details',
        'onPressed': () {
          // Do something when the button is pressed
        },
        'buttonColors': [
          const Color(0xFF5C6BC0),
        ],
      },
      {
        'field1': 'Cat 2',
        'field2': 'ID  1238243341',
        'buttonText': 'View Details',
        'onPressed': () {
          // Do something when the button is pressed
        },
        'buttonColors': [
          const Color(0xFFFF4081),
        ],
      },
      {
        'field1': 'All',
        'field2': 'ID  1238243341',
        'buttonText': 'View Details',
        'onPressed': () {
          // Do something when the button is pressed
        },
        'buttonColors': [
          const Color(0xFF32BAA5),
        ],
      },
      {
        'field1': 'Cat 1',
        'field2': 'ID  1111111111',
        'buttonText': 'View Details',
        'onPressed': () {
          // Do something when the button is pressed
        },
        'buttonColors': [
          const Color(0xFF5C6BC0),
        ],
      },
      {
        'field1': 'Cat 2',
        'field2': 'ID  1238243341',
        'buttonText': 'View Details',
        'onPressed': () {
          // Do something when the button is pressed
        },
        'buttonColors': [
          const Color(0xFFFF4081),
        ],
      },
      {
        'field1': 'Free Standing',
        'field2': 'ID  1238243341',
        'buttonText': 'View Details',
        'onPressed': () {
          // Do something when the button is pressed
        },
        'buttonColors': [
          const Color(0xFFFFA726),
        ],
      },
      {
        'field1': 'Cat 1',
        'field2': 'ID  1111111111',
        'buttonText': 'View Details',
        'onPressed': () {
          // Do something when the button is pressed
        },
        'buttonColors': [
          const Color(0xFF5C6BC0),
        ],
      },
    ];

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
          ),
        ),
        elevation: 0.5,
        shadowColor: Colors.grey[600],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: ListView(
            children: ticketList.map((ticketData) {
              return CommonTicketInfoWidget(
                field1: ticketData['field1'],
                field2: ticketData['field2'],
                buttonText: ticketData['buttonText'],
                buttonColors: ticketData['buttonColors'] as List<Color>,
                onPressed: ticketData['onPressed'],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
