import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const ZebraRfidApp());
}

class ZebraRfidApp extends StatelessWidget {
  const ZebraRfidApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zebra RFID',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF833177)),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
