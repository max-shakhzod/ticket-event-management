import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ticket_event_management/db/auth_repository.dart';
import 'package:ticket_event_management/db/db_admin.dart';
import 'package:ticket_event_management/models/models.dart';
import 'package:ticket_event_management/providers/auth_provider.dart';
import 'package:ticket_event_management/screens/screens.dart';
import 'package:ticket_event_management/theme/colors.dart';
import 'package:ticket_event_management/theme/theme_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DBAdmin().database; // initialise DB + run migrations
  final authRepo = AuthRepository();
  await authRepo.seedDefaultAdmin(); // no-op if any user already exists

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(authRepo)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ticketio',
      theme: ThemeApp.configTheme,
      home: const AuthGate(),
    );
  }
}

/// Watches [AuthProvider] and renders the appropriate screen based on auth state.
///
/// - Loading  → splash spinner
/// - Not logged in → [LoginScreen]
/// - Logged in as scanner → [ScannerScreen] (scan-only root)
/// - Logged in as admin / event manager → [HomeScreen]
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    // Restore session after the first frame so context is available.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().restoreSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF6F6F6),
        body: Center(
          child: CircularProgressIndicator(color: customGreen),
        ),
      );
    }

    if (!auth.isLoggedIn) return const LoginScreen();

    return switch (auth.role) {
      UserRole.scanner => const ScannerScreen(),
      _ => const HomeScreen(),
    };
  }
}
