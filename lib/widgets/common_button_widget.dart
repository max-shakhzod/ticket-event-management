// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:ticket_event_management/custom_icons/scan_custom_icon_icons.dart';
import 'package:ticket_event_management/theme/colors.dart';

class CommonButtonWidget extends StatelessWidget {
  Function? onPressed;
  String text;
  double width;
  double height;

  CommonButtonWidget({
    super.key,
    required this.onPressed,
    required this.text,
    this.width = 350.0,
    this.height = 50.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton.icon(
        icon: const Icon(
          ScanCustomIcon.scanIcon,
          color: Colors.white,
          size: 25,
          weight: 10,
        ),
        label: Text(
          text,
          style: const TextStyle(
            color: customWhite,
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        onPressed: () {
          onPressed != null ? onPressed!() : null;
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: customGreen,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(69.0),
          ),
        ),
      ),
    );
  }
}
