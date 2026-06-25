import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Tentang MotoWash77",
          style: TextStyle(
            color: Color(0xFF0D1B2A),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF0D1B2A),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            
            // LOGO & IDENTITAS
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // App Icon Container
                  Container(
                    width: 90,
                    height: 90,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0D1B2A), Color(0xFF1B263B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0D1B2A).withOpacity(0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      "assets/images/splash.png",
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    "MotoWash77",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D1B2A),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Versi 1.0.0",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Aplikasi Booking Steam Motor",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 10),

            // DESKRIPSI SINGKAT CARD
            _buildSectionCard(
              title: "Tentang Aplikasi",
              child: Text(
                "MotoWash77 merupakan aplikasi booking steam motor yang memudahkan pelanggan melakukan pemesanan layanan cuci motor secara online tanpa harus melakukan login.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
              ),
            ),
            
            const SizedBox(height: 20),

            // FITUR UTAMA CARD
            _buildSectionCard(
              title: "Fitur Utama",
              child: Column(
                children: [
                  _buildFeatureItem("🚿", "Booking Online"),
                  _buildFeatureItem("📜", "Riwayat Booking"),
                  _buildFeatureItem("🔔", "Notifikasi Realtime"),
                  _buildFeatureItem("🏍", "Profil Kendaraan"),
                  _buildFeatureItem("💳", "Pembayaran COD & Transfer"),
                  _buildFeatureItem("⭐", "Sistem Member & Level"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // YANG BARU (CHANGELOG) CARD
            _buildSectionCard(
              title: "Yang Baru di Versi Ini",
              child: Column(
                children: [
                  _buildChangelogItem("Tampilan baru yang lebih modern"),
                  _buildChangelogItem("Sistem member Bronze, Silver, dan Gold"),
                  _buildChangelogItem("Riwayat booking berdasarkan plat kendaraan"),
                  _buildChangelogItem("Dashboard admin dengan statistik real-time"),
                  _buildChangelogItem("Manajemen pelanggan & loyalitas"),
                  _buildChangelogItem("CRUD katalog layanan steam"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // INFORMASI AKADEMIK & APLIKASI
            _buildSectionCard(
              title: "Informasi Aplikasi",
              child: Column(
                children: [
                  _buildInfoRow("Versi", "1.0.0"),
                  _buildDivider(),
                  _buildInfoRow("Developer", "Kelompok 5"),
                  _buildDivider(),
                  _buildInfoRow("Program Studi", "Sistem Informasi"),
                  _buildDivider(),
                  _buildInfoRow("Universitas", "Universitas Cipasung Tasikmalaya"),
                  _buildDivider(),
                  _buildInfoRow("Tahun", "2026"),
                ],
              ),
            ),

            const SizedBox(height: 35),

            // COPYRIGHT FOOTER
            Text(
              "© 2026 MotoWash77",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "All Rights Reserved",
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D1B2A),
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String emoji, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF4F7FB),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0D1B2A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChangelogItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: Colors.green,
            size: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF0D1B2A),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 12,
      color: Colors.grey.shade100,
      thickness: 1,
    );
  }
}
