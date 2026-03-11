import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Importante para la conexión
import 'screens/main_screen.dart';
import 'firebase_options.dart';

void main() async {
  // 1. Asegura que los widgets de Flutter estén listos antes de iniciar Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inicializa Firebase (esto es asíncrono, por eso usamos 'await')
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);

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