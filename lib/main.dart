import 'package:flutter/material.dart';

// Import halaman
import 'splash_screen.dart';
import 'home_page.dart';
import 'profile_page.dart';
import 'booking_form_page.dart';
import 'history_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MotoWash77 App',

      theme: ThemeData(
        primaryColor: const Color(0xFF0D1B2A),
        scaffoldBackgroundColor: Colors.white,
      ),

      // HALAMAN AWAL
      home: const SplashScreen(),

      routes: {
        '/home': (context) => const HomePage(),
        '/profile': (context) => const ProfilePage(),
        '/booking': (context) => const BookingFormPage(),
        '/history': (context) => const HistoryPage(),
      },
    );
  }
}
