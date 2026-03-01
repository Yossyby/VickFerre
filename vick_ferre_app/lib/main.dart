import 'package:flutter/material.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(const VicksStoreApp());
}

class VicksStoreApp extends StatelessWidget {
  const VicksStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Vick's Ferretería",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFF6D00)),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}