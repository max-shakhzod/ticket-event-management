import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ticket_event_management/theme/colors.dart';

class ThemeApp {
  static final ThemeData configTheme = ThemeData.from(
    colorScheme: const ColorScheme.light(
      surface: customWhite, // Use surface instead of background
      // Add more color scheme customization here if needed
    ),
    textTheme: GoogleFonts.montserratTextTheme(),
  );
}
