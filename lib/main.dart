import 'package:flutter/material.dart';
import 'package:ticket_event_management/screens/screens.dart';
import 'package:ticket_event_management/theme/theme_app.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "QR",
        theme: ThemeApp.configTheme,
        home: const HomeScreen());
  }
}
