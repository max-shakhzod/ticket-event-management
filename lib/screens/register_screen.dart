import 'package:flutter/material.dart';
import 'package:ticket_event_management/screens/screens.dart';
import 'package:ticket_event_management/theme/colors.dart';
import 'package:ticket_event_management/widgets/common_button_widget.dart';
import '../custom_icons/icon.dart';

class RegisterScreen extends StatelessWidget {
  final String url;

  const RegisterScreen({super.key, required this.url});

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
          onTap: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => const HomeScreen(),
              ),
              (route) => false,
            );
          },
        ),
        elevation: 0.5,
        shadowColor: Colors.grey[600],
      ),
      body: Container(
        color: const Color(0XFFF6F6F6),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              _buildTicketContainer(),
              const SizedBox(height: 80),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: CommonButtonWidget(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ScannerScreen(),
                      ),
                    );
                  },
                  text: "Scan Other Ticket",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTicketContainer() {
    return Container(
      width: 331,
      height: 453,
      decoration: BoxDecoration(
        color: customWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(width: 1, color: const Color(0xFFD8D5D5)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              'Ticket Verified',
              style: TextStyle(
                fontFamily: 'Montserrat-Regular',
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Icon(Icons.check_circle, color: customGreen, size: 100),
          const SizedBox(height: 20),
          const Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 15),
              child: Row(
                children: [
                  Icon(MyFlutterApp.vector, size: 15),
                  SizedBox(width: 15),
                  Text(
                    'Ticket Details',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTicketInfoRow('Ticket ID :'),
                  _buildTicketInfoRow('Section :'),
                  _buildTicketInfoRow('Seat :'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketInfoRow(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40),
      child: Text(
        label,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
      ),
    );
  }
}