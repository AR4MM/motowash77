import 'package:flutter/material.dart';
import 'order_model.dart';

class BookingFormPage extends StatelessWidget {
  const BookingFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> services = [
      {
        "name": "Cuci Motor Biasa",
        "price": "Rp 25.000",
        "image": "assets/images/cucimotor.jpg",
      },
      {
        "name": "Cuci + Wax",
        "price": "Rp 75.000",
        "image": "assets/images/detailing.jpg",
      },
      {
        "name": "Engine Detailing",
        "price": "Rp 50.000",
        "image": "assets/images/detailing engine.jpg",
      },
      {
        "name": "Polish Body",
        "price": "Rp 100.000",
        "image": "assets/images/detailing full.jpg",
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
        iconTheme: const IconThemeData(color: Color(0xFF0D1B2A)),
      ),

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
              margin: const EdgeInsets.only(bottom: 20),

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
                              Colors.black.withOpacity(0.75),
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
                                  horizontal: 12,
                                  vertical: 7,
                                ),

                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(20),
                                ),

                                child: const Text(
                                  "Best Seller",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          Text(
                            service["name"],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Row(
                            children: const [
                              Icon(
                                Icons.location_on,
                                color: Colors.white70,
                                size: 18,
                              ),

                              SizedBox(width: 5),

                              Text(
                                "Singaparna, Tasikmalaya",
                                style: TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),

                          const SizedBox(height: 15),

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

  /// METODE PEMBAYARAN
  String paymentMethod = "Transfer Bank";

  /// DATE PICKER
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

  /// TIME PICKER
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

        iconTheme: const IconThemeData(color: Color(0xFF0D1B2A)),
      ),

      body: Column(
        children: [
          /// HEADER IMAGE
          SizedBox(
            height: 240,
            width: double.infinity,

            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    widget.service["image"],
                    fit: BoxFit.cover,
                  ),
                ),

                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.transparent,
                        ],

                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                ),

                Positioned(
                  left: 20,
                  bottom: 20,

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        widget.service["name"],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        widget.service["price"],
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),

              decoration: const BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
              ),

              child: ListView(
                children: [
                  const Text(
                    "Informasi Booking",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 20),

                  /// NAMA
                  _input(
                    "Nama Pemesan",
                    "Masukkan nama lengkap",
                    controller: namaController,
                    icon: Icons.person,
                  ),

                  /// PLAT NOMOR
                  _input(
                    "No Polisi",
                    "Z 1234 ABC",
                    controller: noPolisiController,
                    icon: Icons.credit_card,
                  ),

                  /// TIPE MOTOR
                  _input(
                    "Tipe Motor",
                    "NMAX / VARIO / PCX",
                    controller: tipeMotorController,
                    icon: Icons.motorcycle,
                  ),

                  /// TANGGAL
                  TextField(
                    controller: tanggalController,
                    readOnly: true,
                    onTap: _selectDate,

                    decoration: _decoration(
                      "Tanggal Booking",
                      icon: Icons.calendar_month,
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// WAKTU
                  TextField(
                    controller: waktuController,
                    readOnly: true,
                    onTap: _selectTime,

                    decoration: _decoration(
                      "Jam Booking",
                      icon: Icons.access_time,
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// CATATAN
                  TextField(
                    controller: catatanController,
                    maxLines: 3,

                    decoration: _decoration(
                      "Catatan Tambahan",
                      icon: Icons.notes,
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// PAYMENT
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),

                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F7FB),
                      borderRadius: BorderRadius.circular(18),
                    ),

                    child: DropdownButtonFormField<String>(
                      value: paymentMethod,

                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        labelText: "Metode Pembayaran",
                        prefixIcon: Icon(Icons.payments),
                      ),

                      items: const [
                        DropdownMenuItem(
                          value: "Transfer Bank",
                          child: Text("Transfer Bank"),
                        ),

                        DropdownMenuItem(
                          value: "Bayar Ditempat",
                          child: Text("Bayar Ditempat"),
                        ),
                      ],

                      onChanged: (value) {
                        setState(() {
                          paymentMethod = value!;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// BUTTON
                  SizedBox(
                    height: 58,

                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D1B2A),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),

                      onPressed: () {
                        if (namaController.text.isEmpty ||
                            tanggalController.text.isEmpty ||
                            waktuController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Lengkapi data booking!"),
                              backgroundColor: Colors.red,
                            ),
                          );

                          return;
                        }

                        OrderData.orders.add(
                          OrderModel(
                            invoice:
                                "INV${DateTime.now().millisecondsSinceEpoch}",

                            nama: namaController.text,

                            layanan: widget.service["name"],

                            tanggal: tanggalController.text,

                            waktu: waktuController.text,

                            harga: widget.service["price"],

                            status: paymentMethod == "Transfer Bank"
                                ? "Menunggu Pembayaran"
                                : "Sudah Dibayar",

                            payment: paymentMethod,

                            expired: DateTime.now()
                                .add(const Duration(minutes: 1))
                                .toIso8601String(),

                            noPolisi: noPolisiController.text,

                            tipeMotor: tipeMotorController.text,

                            /// WAJIB
                            buktiPembayaran: "",
                          ),
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Pesanan berhasil dibuat!"),
                            backgroundColor: Colors.green,
                          ),
                        );

                        Navigator.pop(context);
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// INPUT
  Widget _input(
    String label,
    String hint, {
    TextEditingController? controller,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),

      child: TextField(
        controller: controller,

        decoration: _decoration(label, hint: hint, icon: icon),
      ),
    );
  }

  /// DECORATION
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

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),

        borderSide: const BorderSide(color: Color(0xFF0D1B2A)),
      ),
    );
  }
}
