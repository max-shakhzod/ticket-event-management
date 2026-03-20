import 'package:flutter/material.dart';
import 'package:ticket_event_management/custom_icons/icon.dart';
import 'package:ticket_event_management/screens/screens.dart';
import 'package:ticket_event_management/theme/colors.dart';
import 'package:ticket_event_management/widgets/common_button_widget.dart';
import 'package:ticket_event_management/widgets/top_common_buttons_widget.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

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
        elevation: 0.2,
        shadowColor: Colors.grey[600],
      ),
      backgroundColor: customWhite,
      body: Container(
        color: const Color(0XFFF6F6F6),
        child: SafeArea(
          child: Container(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                const Align(
                  alignment: Alignment.topLeft,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 8,
                      ),
                      Icon(
                        MyFlutterApp.vector,
                        size: 15,
                      ),
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
                ),
                const SizedBox(
                  height: 15.0,
                ),
                TopCommonButtonsWidget(
                  onPressed: (int index) {
                    // Handle button press
                  },
                  buttonLabels: const [
                    'All',
                    'VIP',
                    'Free',
                    'Cat 1',
                    'Cat 2',
                  ],
                  buttonColors: const [
                    Color(0xFF32BAA5),
                    Color(0xFF3E477D),
                    Color(0xFFFFA726),
                    Color(0xFF5C6BC0),
                    Color(0xFFFF4081),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 30.0),
                  child: Text(
                    "There seems to be \n nothing here",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF53BF9D),
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SvgPicture.asset(
                  "assets/images/Empty-amico.svg",
                  width: width * 0.70,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 60),
                  child: CommonButtonWidget(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ScannerScreen(),
                        ),
                      );
                    },
                    text: "Scan Ticket",
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HistoryScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "View history",
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
      ),
    );
  }
}
