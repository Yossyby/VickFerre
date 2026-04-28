import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart'; // Importante para la conexión
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'firebase_options.dart';

void main() async {
  // 1. Asegura que los widgets de Flutter estén listos antes de iniciar Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inicializa Firebase (esto es asíncrono, por eso usamos 'await')
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);

  runApp(const VicksStoreApp());
}

class VicksStoreApp extends StatefulWidget {
  const VicksStoreApp({super.key});

  @override
  State<VicksStoreApp> createState() => _VicksStoreAppState();
}

class _VicksStoreAppState extends State<VicksStoreApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _setThemeMode(bool isDarkMode) {
    setState(() {
      _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    });
  }

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
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFF6D00), brightness: Brightness.dark),
        scaffoldBackgroundColor: const Color(0xFF121212),
        useMaterial3: true,
      ),
      themeMode: _themeMode,
      home: AuthWrapper(
        themeMode: _themeMode,
        onThemeModeChanged: _setThemeMode,
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  final ThemeMode themeMode;
  final ValueChanged<bool> onThemeModeChanged;

  const AuthWrapper({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFFFF6D00)),
            ),
          );
        }

        if (snapshot.hasData) {
          return MainScreen(
            themeMode: themeMode,
            onThemeModeChanged: onThemeModeChanged,
          );
        }

        return const LoginScreen();
      },
    );
  }
}
