import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';

void main() => runApp(const ElectionApp());

class ElectionApp extends StatelessWidget {
  const ElectionApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'SL Election 2024',
    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark().copyWith(
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF4A90D9),
        surface: Color(0xFF0F1525),
      ),
      scaffoldBackgroundColor: const Color(0xFF0A0E1A),
    ),
    home: const DashboardScreen(),
  );
}