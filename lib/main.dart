import 'package:flutter/material.dart';

import 'splash_screen.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'booking_form_page.dart';
import 'history_page.dart';
import 'profile_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'MotoWash77',

      /// JANGAN PAKAI HOME LAGI
      initialRoute: '/',

      routes: {
        '/': (context) => const SplashScreen(),

        '/login': (context) => const LoginPage(),

        '/home': (context) => const HomePage(),

        '/booking': (context) => const BookingFormPage(),

        '/history': (context) => const HistoryPage(),

        '/profile': (context) => const ProfilePage(),
      },
    );
  }
}
