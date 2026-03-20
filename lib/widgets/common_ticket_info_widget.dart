import 'package:flutter/material.dart';
import 'package:ticket_event_management/theme/colors.dart';

class CommonTicketInfoWidget extends StatefulWidget {
  final String field1;
  final String field2;
  final String buttonText;
  final List<Color> buttonColors;
  final VoidCallback? onPressed;

  const CommonTicketInfoWidget({
    super.key,
    required this.field1,
    required this.field2,
    required this.buttonText,
    required this.buttonColors,
    this.onPressed,
  });

  @override
  // ignore: library_private_types_in_public_api
  _CommonTicketInfoWidgetState createState() => _CommonTicketInfoWidgetState();
}

class _CommonTicketInfoWidgetState extends State<CommonTicketInfoWidget> {
  Color? containerColor;

  @override
  void initState() {
    super.initState();
    if (widget.buttonColors.isNotEmpty) {
      containerColor = widget.buttonColors[0];
    } else {
      containerColor = customGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            vertical: 8.0), // Adjust vertical padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 37.0,
              color: widget.buttonColors.isNotEmpty
                  ? widget.buttonColors[0]
                  : customGreen,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      widget.field1,
                      style: const TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12.0), // Add space between the containers
            Container(
              height: 37.0,
              color: customWhite,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      widget.field2,
                      style: const TextStyle(
                        fontSize: 12.0,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: widget.onPressed,
                    child: Text(
                      widget.buttonText,
                      style: const TextStyle(
                        fontSize: 12.0,
                        color: Color.fromARGB(255, 29, 20, 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
