import 'package:flutter/material.dart';

import 'splash_screen.dart';
import 'home_page.dart';
import 'booking_form_page.dart';
import 'history_page.dart';
import 'profile_page.dart';
import 'admin/admin_home_page.dart';
import 'admin/admin_login_page.dart';
import 'models/order_model.dart';
import 'models/service_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await OrderData.loadOrders();
  await ServiceData.loadServices();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'MotoWash77',

      // Users go directly to HomePage — no authentication required.
      // SplashScreen handles the admin-session check only.
      home: const SplashScreen(),

      routes: {
        '/home': (context) => const HomePage(),

        '/booking': (context) => const BookingFormPage(),

        '/history': (context) => const HistoryPage(),

        '/profile': (context) => const ProfilePage(),

        '/admin_home': (context) => const AdminHomePage(),

        '/admin_login': (context) => const AdminLoginPage(),
      },
    );
  }
}
