import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_page.dart';
import 'history_page.dart';
import 'profile_page.dart';
import 'models/order_model.dart';
import 'models/service_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'src/file_image_helper.dart' as file_image_helper;

Widget _buildServiceImage(String path, {double? height, double? width, BoxFit? fit}) {
  if (path.startsWith('assets/')) {
    return Image.asset(
      path,
      height: height,
      width: width,
      fit: fit,
      errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade200),
    );
  } else {
    return file_image_helper.fileImage(
      path,
      height: height,
      width: width,
      fit: fit,
    );
  }
}

class BookingFormPage extends StatefulWidget {
  const BookingFormPage({super.key});

  @override
  State<BookingFormPage> createState() => _BookingFormPageState();
}

class _BookingFormPageState extends State<BookingFormPage> {
  List<Map<String, dynamic>> services = [];

  @override
  void initState() {
    super.initState();
    _loadDynamicServices();
  }

  void _loadDynamicServices() async {
    await ServiceData.loadServices();
    setState(() {
      services = ServiceData.services.map((s) => {
        "name": s.name,
        "image": s.image,
        "price": s.name == 'Wash & Wax' ? "Mulai Rp 15.000" : _formatPriceString(s.price),
      }).toList();
    });
  }

  String _formatPriceString(int price) {
    final cleanPrice = price.toString();
    if (cleanPrice.length <= 3) return 'Rp $cleanPrice';
    final buffer = StringBuffer();
    int count = 0;
    for (int i = cleanPrice.length - 1; i >= 0; i--) {
      buffer.write(cleanPrice[i]);
      count++;
      if (count == 3 && i > 0) {
        buffer.write('.');
        count = 0;
      }
    }
    return 'Rp ${buffer.toString().split('').reversed.join('')}';
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,

        title: const Text(
          "Booking Layanan",
          style: TextStyle(
            color: Color(0xFF0D1B2A),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      /// ================= BODY =================
      body: ListView.builder(
        padding: const EdgeInsets.all(18),
        itemCount: services.length,

        itemBuilder: (context, index) {
          final service = services[index];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BookingDetailPage(service: service),
                ),
              );
            },

            child: Container(
              margin: const EdgeInsets.only(bottom: 22),

              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),

              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),

                child: Stack(
                  children: [
                    /// IMAGE
                    SizedBox(
                      height: 240,
                      width: double.infinity,

                      child: _buildServiceImage(
                        service["image"],
                        fit: BoxFit.cover,
                      ),
                    ),

                    /// OVERLAY
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withValues(alpha: 0.8),
                              Colors.transparent,
                            ],

                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ),
                    ),

                    /// CONTENT
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 20,

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),

                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),

                                  borderRadius: BorderRadius.circular(14),
                                ),

                                child: const Icon(
                                  Icons.local_car_wash,
                                  color: Colors.white,
                                ),
                              ),

                              const Spacer(),

                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),

                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(30),
                                ),

                                child: const Text(
                                  "Best Seller",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          Text(
                            service["name"],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Colors.white70,
                                size: 18,
                              ),

                              const SizedBox(width: 6),

                              Expanded(
                                child: Text(
                                  "Singaparna, Tasikmalaya",
                                  style: const TextStyle(color: Colors.white70),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  service["price"],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),

                              const SizedBox(width: 8),

                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 10,
                                ),

                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(30),
                                ),

                                child: const Text(
                                  "Pesan",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),

      /// ================= NAVIGATION =================
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(15),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),

          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20),
          ],
        ),

        child: BottomNavigationBar(
          currentIndex: 1,

          backgroundColor: Colors.transparent,
          elevation: 0,

          type: BottomNavigationBarType.fixed,

          selectedItemColor: const Color(0xFF0D1B2A),
          unselectedItemColor: Colors.grey,

          onTap: (index) {
            if (index == 0) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            }

            if (index == 2) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HistoryPage()),
              );
            }

            if (index == 3) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
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

/// =======================================================
/// DETAIL PAGE
/// =======================================================

class BookingDetailPage extends StatefulWidget {
  final Map<String, dynamic> service;

  const BookingDetailPage({super.key, required this.service});

  @override
  State<BookingDetailPage> createState() => _BookingDetailPageState();
}

class _BookingDetailPageState extends State<BookingDetailPage> {
  final TextEditingController namaController = TextEditingController();

  final TextEditingController tanggalController = TextEditingController();

  final TextEditingController waktuController = TextEditingController();

  final TextEditingController noPolisiController = TextEditingController();

  final TextEditingController tipeMotorController = TextEditingController();

  final TextEditingController catatanController = TextEditingController();

  String paymentMethod = "Transfer Bank";

  String kategoriMotor = "-";

  String hargaMotor = "Rp 15.000";

  final Set<String> selectedServiceNames = {};

  int _parsePrice(String priceStr) {
    String clean = priceStr.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(clean) ?? 0;
  }

  String _formatPrice(int price) {
    final cleanPrice = price.toString();
    if (cleanPrice.length <= 3) return 'Rp $cleanPrice';
    final buffer = StringBuffer();
    int count = 0;
    for (int i = cleanPrice.length - 1; i >= 0; i--) {
      buffer.write(cleanPrice[i]);
      count++;
      if (count == 3 && i > 0) {
        buffer.write('.');
        count = 0;
      }
    }
    return 'Rp ${buffer.toString().split('').reversed.join('')}';
  }

  int _calculateTotal() {
    int total = 0;
    for (var service in ServiceData.services) {
      if (selectedServiceNames.contains(service.name)) {
        if (service.name == "Wash & Wax") {
          total += _parsePrice(hargaMotor);
        } else {
          total += service.price;
        }
      }
    }
    return total;
  }

  @override
  void initState() {
    super.initState();
    selectedServiceNames.add(widget.service["name"]);
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      namaController.text = prefs.getString('nama') ?? "";
      final savedMotor = prefs.getString('motor') ?? "";
      final savedPlat = prefs.getString('plat') ?? "";
      if (savedMotor.isNotEmpty && savedMotor != "-") {
        tipeMotorController.text = savedMotor;
        cekKategoriMotor(savedMotor);
      }
      if (savedPlat.isNotEmpty && savedPlat != "-") {
        noPolisiController.text = savedPlat;
      }
    });

    try {
      await OrderData.fetchFromApi();
    } catch (e) {
      debugPrint("Error fetching orders: $e");
    }
  }

  /// ================= CEK KATEGORI =================
  void cekKategoriMotor(String value) {
    String motor = value.toLowerCase();

    if (motor.contains("beat") ||
        motor.contains("mio") ||
        motor.contains("scoopy")) {
      kategoriMotor = "Small";
      hargaMotor = "Rp 15.000";
    } else if (motor.contains("vario") ||
        motor.contains("aerox") ||
        motor.contains("lexi")) {
      kategoriMotor = "Medium";
      hargaMotor = "Rp 25.000";
    } else if (motor.contains("nmax") ||
        motor.contains("pcx") ||
        motor.contains("xmax")) {
      kategoriMotor = "Large";
      hargaMotor = "Rp 30.000";
    } else {
      kategoriMotor = "Medium";
      hargaMotor = "Rp 25.000";
    }

    setState(() {});
  }

  /// ================= DATE =================
  Future<void> _selectDate() async {
    DateTime initial = DateTime.now();
    // Find the first date starting from today that is not booked
    while (true) {
      final dateStr = "${initial.day}-${initial.month}-${initial.year}";
      final isBooked = OrderData.orders.any((o) =>
          o.tanggal == dateStr &&
          o.status != 'Expired' &&
          o.status != 'Ditolak');
      if (!isBooked) {
        break;
      }
      initial = initial.add(const Duration(days: 1));
    }

    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: startOfToday,
      lastDate: DateTime(2030),
      selectableDayPredicate: (DateTime day) {
        // Disable already booked dates
        final dateStr = "${day.day}-${day.month}-${day.year}";
        final isBooked = OrderData.orders.any((o) =>
            o.tanggal == dateStr &&
            o.status != 'Expired' &&
            o.status != 'Ditolak');
        return !isBooked;
      },
    );

    if (picked != null && mounted) {
      setState(() {
        tanggalController.text = "${picked.day}-${picked.month}-${picked.year}";
      });
    }
  }

  /// ================= TIME =================
  Future<void> _selectTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null && mounted) {
      setState(() {
        waktuController.text = picked.format(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0D1B2A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Detail Booking",
          style: TextStyle(
            color: Color(0xFF0D1B2A),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          /// SECTION: INFORMASI PEMESAN
          const Row(
            children: [
              Icon(Icons.person_outline_rounded, color: Color(0xFF0D1B2A), size: 20),
              SizedBox(width: 8),
              Text(
                "Informasi Pemesan & Kendaraan",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D1B2A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.grey.shade100, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _input(
                  "Nama Pemesan",
                  "Masukkan nama lengkap",
                  controller: namaController,
                  icon: Icons.person,
                ),
                _input(
                  "No Polisi",
                  "Z 1234 ABC",
                  controller: noPolisiController,
                  icon: Icons.credit_card,
                ),
                TextField(
                  controller: tipeMotorController,
                  onChanged: (value) {
                    cekKategoriMotor(value);
                  },
                  decoration: _decoration(
                    "Tipe Motor",
                    hint: "Contoh: Beat / Vario / NMAX",
                    icon: Icons.motorcycle,
                  ),
                ),
                if (tipeMotorController.text.trim().isNotEmpty &&
                    selectedServiceNames.contains("Wash & Wax"))
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D1B2A).withOpacity(0.04),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF0D1B2A).withOpacity(0.08)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            size: 16,
                            color: Color(0xFF0D1B2A),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                                children: [
                                  const TextSpan(text: "Kategori Terdeteksi: "),
                                  TextSpan(
                                    text: kategoriMotor,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0D1B2A),
                                    ),
                                  ),
                                  const TextSpan(text: " (Wash & Wax: "),
                                  TextSpan(
                                    text: hargaMotor,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                  const TextSpan(text: ")"),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          /// SECTION: LAYANAN UTAMA
          const Row(
            children: [
              Icon(Icons.local_car_wash_rounded, color: Color(0xFF0D1B2A), size: 20),
              SizedBox(width: 8),
              Text(
                "Layanan Utama",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D1B2A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Main service card (non-removable, compact)
          Builder(
            builder: (context) {
              final mainServiceName = widget.service["name"] as String;
              final mainService = ServiceData.services.firstWhere(
                (s) => s.name == mainServiceName,
                orElse: () => ServiceData.services.first,
              );
              final String mainPrice = mainService.name == "Wash & Wax"
                  ? hargaMotor
                  : _formatPrice(mainService.price);

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0D1B2A), Color(0xFF1E3A5F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0D1B2A).withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Amber check icon
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.amber.shade400,
                      ),
                      child: const Icon(Icons.check, size: 12, color: Colors.white),
                    ),
                    const SizedBox(width: 10),
                    // Service image compact
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        width: 44,
                        height: 44,
                        child: _buildServiceImage(mainService.image, fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Name only (no description)
                    Expanded(
                      child: Text(
                        mainService.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    // Price + badge
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          mainPrice,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.amber,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            "✓ Layanan Utama",
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.white70,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          /// SECTION: TAMBAH LAYANAN LAINNYA
          Row(
            children: [
              const Icon(Icons.add_circle_outline_rounded, color: Color(0xFF0D1B2A), size: 20),
              const SizedBox(width: 8),
              const Text(
                "Tambah Layanan Lainnya",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D1B2A),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D1B2A).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "Opsional",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0D1B2A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Pilih layanan tambahan yang ingin Anda tambahkan",
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 12),

          // Additional services - GoFood style cards
          Column(
            children: ServiceData.services
                .where((service) => service.name != widget.service["name"])
                .map((service) {
              final isSelected = selectedServiceNames.contains(service.name);
              final String displayPrice = service.name == "Wash & Wax"
                  ? hargaMotor
                  : _formatPrice(service.price);

              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF0D1B2A) : Colors.grey.shade200,
                    width: isSelected ? 1.8 : 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        width: 52,
                        height: 52,
                        child: _buildServiceImage(service.image, fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            service.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Color(0xFF0D1B2A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            displayPrice,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // GoFood-style Tambah / Ditambahkan button
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            selectedServiceNames.remove(service.name);
                          } else {
                            selectedServiceNames.add(service.name);
                          }
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF0D1B2A) : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF0D1B2A) : Colors.grey.shade300,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isSelected ? Icons.check : Icons.add,
                              size: 13,
                              color: isSelected ? Colors.white : const Color(0xFF0D1B2A),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isSelected ? "Ditambahkan" : "Tambah",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : const Color(0xFF0D1B2A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),


          /// SECTION: JADWAL KEDATANGAN
          const Row(
            children: [
              Icon(Icons.calendar_today_rounded, color: Color(0xFF0D1B2A), size: 20),
              SizedBox(width: 8),
              Text(
                "Jadwal Kedatangan",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D1B2A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.grey.shade100, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _selectDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200, width: 1.5),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.calendar_month, size: 16, color: Color(0xFF0D1B2A)),
                                  const SizedBox(width: 6),
                                  Text(
                                    "Tanggal",
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                tanggalController.text.isEmpty ? "Pilih Tanggal" : tanggalController.text,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: tanggalController.text.isEmpty ? Colors.grey.shade400 : const Color(0xFF0D1B2A),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: GestureDetector(
                        onTap: _selectTime,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200, width: 1.5),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.access_time, size: 16, color: Color(0xFF0D1B2A)),
                                  const SizedBox(width: 6),
                                  Text(
                                    "Jam Booking",
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                waktuController.text.isEmpty ? "Pilih Jam" : waktuController.text,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: waktuController.text.isEmpty ? Colors.grey.shade400 : const Color(0xFF0D1B2A),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.only(top: 14),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Colors.blue.shade800),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Tanggal yang penuh atau hari yang sudah lewat tidak dapat dipilih.",
                          style: TextStyle(fontSize: 11, color: Colors.blue.shade900),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: catatanController,
                  maxLines: 2,
                  decoration: _decoration(
                    "Catatan Tambahan (Opsional)",
                    icon: Icons.notes,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          /// SECTION: METODE PEMBAYARAN
          const Row(
            children: [
              Icon(Icons.payment_rounded, color: Color(0xFF0D1B2A), size: 20),
              SizedBox(width: 8),
              Text(
                "Metode Pembayaran",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D1B2A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: paymentCard(
                  title: "Transfer Bank",
                  icon: Icons.account_balance,
                  active: paymentMethod == "Transfer Bank",
                  color: const Color(0xFF0D1B2A),
                  onTap: () {
                    setState(() {
                      paymentMethod = "Transfer Bank";
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: paymentCard(
                  title: "Cash",
                  icon: Icons.payments,
                  active: paymentMethod == "Bayar Ditempat",
                  color: const Color(0xFF0D1B2A),
                  onTap: () {
                    setState(() {
                      paymentMethod = "Bayar Ditempat";
                    });
                  },
                ),
              ),
            ],
          ),
          if (paymentMethod == "Transfer Bank")
            AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              margin: const EdgeInsets.only(top: 14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1B2A).withOpacity(0.04),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF0D1B2A).withOpacity(0.1),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D1B2A),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          "BCA",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Transfer Bank (Manual)",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFF0D1B2A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Nomor Rekening:",
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  // Nomor rekening besar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Nomor Rekening",
                                style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                "7771234567",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Color(0xFF0D1B2A),
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const Text(
                                "a/n MotoWash77",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Full-width copy button
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("✓ Nomor rekening berhasil disalin"),
                          duration: Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D1B2A),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.copy_rounded, size: 15, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            "Salin Nomor Rekening",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined, size: 13, color: Colors.amber),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          "Batas waktu pembayaran 30 menit setelah memesan.",
                          style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),

          /// SECTION: RINGKASAN PESANAN
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.grey.shade100, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.receipt_long_rounded, color: Color(0xFF0D1B2A), size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      "Ringkasan Pesanan",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D1B2A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Service rows with green check
                ...ServiceData.services.where((s) => selectedServiceNames.contains(s.name)).map((service) {
                  final bool isMain = service.name == widget.service["name"];
                  final String displayPrice = service.name == "Wash & Wax"
                      ? hargaMotor
                      : _formatPrice(service.price);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.green.shade500,
                          ),
                          child: const Icon(Icons.check, size: 12, color: Colors.white),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                service.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: Color(0xFF0D1B2A),
                                ),
                              ),
                              if (isMain)
                                Text(
                                  "Layanan Utama",
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.green.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Text(
                          displayPrice,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Color(0xFF0D1B2A),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 4),
                const Divider(height: 24, thickness: 1, color: Color(0xFFE2E8F0)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total Biaya",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF0D1B2A),
                      ),
                    ),
                    Text(
                      _formatPrice(_calculateTotal()),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Total Pembayaran",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatPrice(_calculateTotal()),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 5,
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D1B2A),
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: const Color(0xFF0D1B2A).withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () async {
                      if (namaController.text.trim().isEmpty ||
                          noPolisiController.text.trim().isEmpty ||
                          tipeMotorController.text.trim().isEmpty ||
                          tanggalController.text.trim().isEmpty ||
                          waktuController.text.trim().isEmpty) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            title: const Text(
                              "Data Belum Lengkap",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            content: const Text(
                              "Nama Pemesan, No Polisi, Tipe Motor, Tanggal Booking, dan Jam Booking wajib diisi.\n\nCatatan tambahan boleh dikosongkan.",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("OK"),
                              ),
                            ],
                          ),
                        );
                        return;
                      }

                      final hargaFinal = _formatPrice(_calculateTotal());
                      final invoice = "INV${DateTime.now().millisecondsSinceEpoch}";
                      final String layananFinal = selectedServiceNames.join(", ");

                      OrderData.orders.add(
                        OrderModel(
                          invoice: invoice,
                          nama: namaController.text,
                          layanan: layananFinal,
                          tanggal: tanggalController.text,
                          waktu: waktuController.text,
                          harga: hargaFinal,
                          status: paymentMethod == "Transfer Bank"
                              ? "Menunggu Pembayaran"
                              : "Menunggu Konfirmasi",
                          payment: paymentMethod,
                          expired: DateTime.now()
                              .add(const Duration(minutes: 30))
                              .toIso8601String(),
                          noPolisi: noPolisiController.text,
                          tipeMotor: tipeMotorController.text,
                          buktiPembayaran: "",
                        ),
                      );

                      await OrderData.saveOrders();

                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      prefs.setString('nama', namaController.text);
                      prefs.setString('motor', tipeMotorController.text);
                      prefs.setString('plat', noPolisiController.text);

                      int total = prefs.getInt('total_booking') ?? 0;
                      prefs.setInt('total_booking', total + 1);

                      final requestBody = {
                        "invoice": invoice,
                        "nama": namaController.text,
                        "layanan": layananFinal,
                        "tanggal": tanggalController.text,
                        "waktu": waktuController.text,
                        "harga": hargaFinal,
                        "status": paymentMethod == "Transfer Bank"
                            ? "Menunggu Pembayaran"
                            : "Menunggu Konfirmasi",
                        "payment": paymentMethod,
                        "expired": DateTime.now()
                            .add(const Duration(minutes: 30))
                            .toIso8601String(),
                        "no_polisi": noPolisiController.text,
                        "tipe_motor": tipeMotorController.text,
                        "bukti_pembayaran": "",
                      };

                      try {
                        final response = await http.post(
                          Uri.parse(
                            "http://localhost/motowash_api/insert_booking.php",
                          ),
                          headers: {"Content-Type": "application/json"},
                          body: jsonEncode(requestBody),
                        );

                        if (response.statusCode != 200) {
                          debugPrint("Error : ${response.statusCode}");
                        }
                      } catch (e) {
                        debugPrint("Exception : $e");
                      }

                      if (!context.mounted) return;

                      await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          title: const Text(
                            "Pesanan Berhasil",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          content: const Text(
                            "Pesanan Anda berhasil dibuat.\nSilakan cek riwayat pemesanan.",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                              child: const Text("OK"),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Pesan Sekarang",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded, size: 16, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ================= INFO CARD =================
  Widget infoCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),

        borderRadius: BorderRadius.circular(22),
      ),

      child: Column(
        children: [
          Icon(icon, color: color),

          const SizedBox(height: 10),

          Text(title, style: const TextStyle(color: Colors.grey)),

          const SizedBox(height: 6),

          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// ================= PAYMENT CARD =================
  Widget paymentCard({
    required String title,
    required IconData icon,
    required bool active,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF0D1B2A) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: active ? const Color(0xFF0D1B2A) : Colors.grey.shade200,
            width: 1.8,
          ),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: const Color(0xFF0D1B2A).withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.01),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 28,
              color: active ? Colors.amber : const Color(0xFF0D1B2A),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: active ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ================= INPUT =================
  Widget _input(
    String label,
    String hint, {
    TextEditingController? controller,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextField(
        controller: controller,
        decoration: _decoration(label, hint: hint, icon: icon),
      ),
    );
  }

  /// ================= DECORATION =================
  InputDecoration _decoration(
    String label, {
    String? hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400),
      prefixIcon: Icon(icon, color: const Color(0xFF0D1B2A)),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF0D1B2A), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }
}
