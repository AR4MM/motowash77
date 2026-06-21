import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_page.dart';
import 'booking_form_page.dart';
import 'history_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  /// ================= MENU ITEM =================
  Widget menuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color color = const Color(0xFF0D1B2A),
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),

      child: Material(
        color: Colors.white,

        borderRadius: BorderRadius.circular(22),

        child: InkWell(
          borderRadius: BorderRadius.circular(22),

          onTap: onTap,

          child: Container(
            padding: const EdgeInsets.all(18),

            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),

              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),

                  blurRadius: 10,

                  offset: const Offset(0, 4),
                ),
              ],
            ),

            child: Row(
              children: [
                /// ICON
                Container(
                  padding: const EdgeInsets.all(14),

                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),

                    borderRadius: BorderRadius.circular(18),
                  ),

                  child: Icon(icon, color: color, size: 24),
                ),

                const SizedBox(width: 16),

                /// TEXT
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        title,

                        style: const TextStyle(
                          fontWeight: FontWeight.bold,

                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        subtitle,

                        style: const TextStyle(
                          color: Colors.grey,

                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 18,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),

      body: SingleChildScrollView(
        child: Column(
          children: [
            /// ================= HEADER =================
            Container(
              width: double.infinity,

              padding: const EdgeInsets.only(
                top: 65,
                left: 24,
                right: 24,
                bottom: 35,
              ),

              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0D1B2A), Color(0xFF1B263B)],

                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),

                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(35),
                  bottomRight: Radius.circular(35),
                ),
              ),

              child: Column(
                children: [
                  /// PROFILE IMAGE
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),

                        decoration: BoxDecoration(
                          shape: BoxShape.circle,

                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),

                            width: 3,
                          ),
                        ),

                        child: const CircleAvatar(
                          radius: 48,

                          backgroundImage: AssetImage(
                            "assets/images/profil.jpg",
                          ),
                        ),
                      ),

                      Positioned(
                        bottom: 0,
                        right: 0,

                        child: Container(
                          padding: const EdgeInsets.all(7),

                          decoration: BoxDecoration(
                            color: Colors.blue,

                            shape: BoxShape.circle,

                            border: Border.all(color: Colors.white, width: 2),
                          ),

                          child: const Icon(
                            Icons.edit,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  /// NAME
                  const Text(
                    "Hallo",

                    style: TextStyle(
                      color: Colors.white,

                      fontSize: 24,

                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  /// EMAIL
                  const Text(
                    "Selamat Menikmati Fitur Kami",

                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),

                  const SizedBox(height: 20),

                  /// MEMBER CARD
                  Container(
                    padding: const EdgeInsets.all(18),

                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),

                      borderRadius: BorderRadius.circular(22),

                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),

                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),

                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.2),

                            borderRadius: BorderRadius.circular(16),
                          ),

                          child: const Icon(
                            Icons.workspace_premium,

                            color: Colors.amber,
                            size: 28,
                          ),
                        ),

                        const SizedBox(width: 16),

                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              Text(
                                "Premium Member",

                                style: TextStyle(
                                  color: Colors.white,

                                  fontWeight: FontWeight.bold,

                                  fontSize: 16,
                                ),
                              ),

                              SizedBox(height: 4),

                              Text(
                                "Nikmati promo & layanan prioritas",

                                style: TextStyle(
                                  color: Colors.white70,

                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            /// ================= CONTENT =================
            Padding(
              padding: const EdgeInsets.all(20),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  /// TITLE
                  const Text(
                    "Menu Akun",

                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 20),

                  /// MENU ITEMS
                  menuItem(
                    icon: Icons.person_outline,

                    title: "Edit Profil",

                    subtitle: "Ubah nama, email, dan foto profil",

                    onTap: () {},
                  ),

                  menuItem(
                    icon: Icons.history,

                    title: "Riwayat Booking",

                    subtitle: "Lihat semua pesanan & transaksi",

                    onTap: () {
                      Navigator.push(
                        context,

                        MaterialPageRoute(
                          builder: (context) => const HistoryPage(),
                        ),
                      );
                    },
                  ),

                  menuItem(
                    icon: Icons.notifications_none,

                    title: "Notifikasi",

                    subtitle: "Atur pemberitahuan aplikasi",

                    onTap: () {},
                  ),

                  menuItem(
                    icon: Icons.settings_outlined,

                    title: "Pengaturan",

                    subtitle: "Keamanan, privasi & lainnya",

                    onTap: () {},
                  ),

                  menuItem(
                    icon: Icons.help_outline_rounded,

                    title: "Pusat Bantuan",

                    subtitle: "FAQ dan bantuan pelanggan",

                    onTap: () {},
                  ),

                  menuItem(
                    icon: Icons.info_outline,

                    title: "Tentang Aplikasi",

                    subtitle: "MotoWash77 versi 1.0.0",

                    onTap: () {},
                  ),

                  const SizedBox(height: 25),

                  /// LOGOUT BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 58,

                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D1B2A),

                        elevation: 0,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),

                      icon: const Icon(Icons.logout, color: Colors.white),

                      label: const Text(
                        "Logout",

                        style: TextStyle(
                          color: Colors.white,

                          fontWeight: FontWeight.bold,

                          fontSize: 16,
                        ),
                      ),

                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('isLoggedIn', false);

                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/login',
                          (route) => false,
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),

      /// ================= BOTTOM NAV =================
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(15),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.circular(24),

          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20),
          ],
        ),

        child: BottomNavigationBar(
          currentIndex: 3,

          backgroundColor: Colors.transparent,

          elevation: 0,

          type: BottomNavigationBarType.fixed,

          selectedItemColor: const Color(0xFF0D1B2A),

          unselectedItemColor: Colors.grey,

          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),

          onTap: (index) {
            if (index == 0) {
              Navigator.pushReplacement(
                context,

                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            } else if (index == 1) {
              Navigator.pushReplacement(
                context,

                MaterialPageRoute(
                  builder: (context) => const BookingFormPage(),
                ),
              );
            } else if (index == 2) {
              Navigator.pushReplacement(
                context,

                MaterialPageRoute(builder: (context) => const HistoryPage()),
              );
            }
          },

          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),

              label: "Home",
            ),

            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long),

              label: "Booking",
            ),

            BottomNavigationBarItem(
              icon: Icon(Icons.history),

              label: "History",
            ),

            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ],
        ),
      ),
    );
  }
}
