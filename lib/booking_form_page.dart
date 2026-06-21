import 'package:flutter/material.dart';

import 'home_page.dart';
import 'history_page.dart';
import 'profile_page.dart';
import 'order_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class BookingFormPage extends StatelessWidget {
  const BookingFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> services = [
      {
        "name": "Wash & Wax",
        "image": "assets/images/cucimotor.jpg",
        "price": "Mulai Rp 15.000",
      },

      {
        "name": "Body Detailing",
        "image": "assets/images/detailing.jpg",
        "price": "Rp 50.000",
      },

      {
        "name": "Engine Detailing",
        "image": "assets/images/detailing engine.jpg",
        "price": "Rp 100.000",
      },

      {
        "name": "Full Detailing",
        "image": "assets/images/detailing full.jpg",
        "price": "Rp 150.000",
      },

      {
        "name": "Polish Body",
        "image": "assets/images/polish body.jpg",
        "price": "Rp 150.000",
      },
    ];

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
                    color: Colors.black.withOpacity(0.06),
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

                      child: Image.asset(service["image"], fit: BoxFit.cover),
                    ),

                    /// OVERLAY
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.8),
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
                                  color: Colors.white.withOpacity(0.15),

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

                          const Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Colors.white70,
                                size: 18,
                              ),

                              SizedBox(width: 6),

                              Text(
                                "Singaparna, Tasikmalaya",
                                style: TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          Row(
                            children: [
                              Text(
                                service["price"],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const Spacer(),

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
            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20),
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
    DateTime? picked = await showDatePicker(
      context: context,

      initialDate: DateTime.now(),

      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      tanggalController.text = "${picked.day}-${picked.month}-${picked.year}";
    }
  }

  /// ================= TIME =================
  Future<void> _selectTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      waktuController.text = picked.format(context);
    }
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
          "Detail Booking",
          style: TextStyle(
            color: Color(0xFF0D1B2A),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),

        children: [
          /// IMAGE
          ClipRRect(
            borderRadius: BorderRadius.circular(30),

            child: Image.asset(
              widget.service["image"],
              height: 230,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(height: 24),

          Text(
            widget.service["name"],
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 30),

          /// FORM
          Container(
            padding: const EdgeInsets.all(22),

            decoration: BoxDecoration(
              color: Colors.white,

              borderRadius: BorderRadius.circular(30),

              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 18,
                ),
              ],
            ),

            child: Column(
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

                /// TIPE MOTOR
                TextField(
                  controller: tipeMotorController,

                  onChanged: (value) {
                    if (widget.service["name"] == "Wash & Wax") {
                      cekKategoriMotor(value);
                    }
                  },

                  decoration: _decoration(
                    "Tipe Motor",
                    hint: "Contoh : Beat / NMAX",
                    icon: Icons.motorcycle,
                  ),
                ),

                /// KHUSUS WASH & WAX
                if (widget.service["name"] == "Wash & Wax") ...[
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: infoCard(
                          "Kategori",
                          kategoriMotor,
                          Icons.category,
                          Colors.blue,
                        ),
                      ),

                      const SizedBox(width: 16),

                      Expanded(
                        child: infoCard(
                          "Harga",
                          hargaMotor,
                          Icons.payments,
                          Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 20),

                /// DATE
                TextField(
                  controller: tanggalController,
                  readOnly: true,
                  onTap: _selectDate,

                  decoration: _decoration(
                    "Tanggal Booking",
                    icon: Icons.calendar_month,
                  ),
                ),

                const SizedBox(height: 18),

                /// TIME
                TextField(
                  controller: waktuController,
                  readOnly: true,
                  onTap: _selectTime,

                  decoration: _decoration(
                    "Jam Booking",
                    icon: Icons.access_time,
                  ),
                ),

                const SizedBox(height: 18),

                /// CATATAN
                TextField(
                  controller: catatanController,
                  maxLines: 3,

                  decoration: _decoration(
                    "Catatan Tambahan",
                    icon: Icons.notes,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          /// PAYMENT
          const Text(
            "Metode Pembayaran",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: paymentCard(
                  title: "Transfer",
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

                  color: const Color.fromARGB(255, 21, 38, 51),

                  onTap: () {
                    setState(() {
                      paymentMethod = "Bayar Ditempat";
                    });
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 35),

          /// BUTTON
          SizedBox(
            height: 58,

            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D1B2A),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),

              onPressed: () async {
                // VALIDASI FORM
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

                String hargaFinal = "";
                final invoice = "INV${DateTime.now().millisecondsSinceEpoch}";

                /// HARGA
                if (widget.service["name"] == "Wash & Wax") {
                  hargaFinal = hargaMotor;
                } else {
                  hargaFinal = widget.service["price"];
                }

                OrderData.orders.add(
                  OrderModel(
                    invoice: invoice,
                    nama: namaController.text,
                    layanan: widget.service["name"],
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

                final requestBody = {
                  "invoice": invoice,
                  "nama": namaController.text,
                  "layanan": widget.service["name"],
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
                    print("Error : ${response.statusCode}");
                  }
                } catch (e) {
                  print("Exception : $e");
                }

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

              child: const Text(
                "PESAN SEKARANG",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  /// ================= INFO CARD =================
  Widget infoCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: color.withOpacity(0.08),

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
        duration: const Duration(milliseconds: 300),

        padding: const EdgeInsets.all(20),

        decoration: BoxDecoration(
          color: active ? color : Colors.white,

          borderRadius: BorderRadius.circular(24),

          border: Border.all(color: active ? color : Colors.grey.shade300),
        ),

        child: Column(
          children: [
            Icon(icon, size: 34, color: active ? Colors.white : Colors.black87),

            const SizedBox(height: 10),

            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,

                color: active ? Colors.white : Colors.black87,
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
      hintText: hint,

      prefixIcon: Icon(icon),

      filled: true,
      fillColor: const Color(0xFFF4F7FB),

      contentPadding: const EdgeInsets.symmetric(vertical: 18),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),

        borderSide: BorderSide.none,
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),

        borderSide: const BorderSide(color: Color(0xFF0D1B2A)),
      ),
    );
  }
}
