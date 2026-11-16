import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';

void main() => runApp(const ElectionApp());

class ElectionApp extends StatelessWidget {
  const ElectionApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Election Commission of Sri Lanka',
    debugShowCheckedModeBanner: false,
    theme: ThemeData.light().copyWith(
      primaryColor: const Color(0xFF6B1124),
      scaffoldBackgroundColor: const Color(0xFFF4F5F9),
      cardColor: Colors.white,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF6B1124),
        secondary: Color(0xFF00A859),
        surface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF1A202C),
        elevation: 0,
      ),
    ),
    home: const DashboardScreen(),
  );
}
