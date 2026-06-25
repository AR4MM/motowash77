import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'models/order_model.dart';

class VehicleModel {
  String motor;
  String plat;

  VehicleModel({required this.motor, required this.plat});

  Map<String, dynamic> toJson() => {'motor': motor, 'plat': plat};

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      motor: json['motor'] as String? ?? '',
      plat: json['plat'] as String? ?? '',
    );
  }
}

class MyVehiclesPage extends StatefulWidget {
  const MyVehiclesPage({super.key});

  @override
  State<MyVehiclesPage> createState() => _MyVehiclesPageState();
}

class _MyVehiclesPageState extends State<MyVehiclesPage> {
  Future<void> _contactAdminWhatsApp(String invoice, String type) async {
    const nomorAdmin = "6289512345678"; // realistic WA number
    String pesan = "";
    if (type == "tanya") {
      pesan = "Halo Admin MotoWash77, saya ingin menanyakan pesanan saya dengan invoice $invoice.";
    } else if (type == "pembayaran") {
      pesan = "Halo Admin MotoWash77, saya ingin konfirmasi pembayaran.";
    } else {
      pesan = "Halo Admin MotoWash77, saya ingin bertanya mengenai layanan.";
    }

    final url = Uri.parse(
      "https://wa.me/$nomorAdmin?text=${Uri.encodeComponent(pesan)}",
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Tidak dapat membuka WhatsApp")),
        );
      }
    }
  }

  List<VehicleModel> vehicles = [];
  int selectedIndex = 0;
  bool isLoading = true;

  // Active vehicle keys (synced with profile and booking pages)
  String activeMotor = "";
  String activePlat = "";
  String namaUser = "";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    namaUser = prefs.getString('nama') ?? "";
    activeMotor = prefs.getString('motor') ?? "";
    activePlat = prefs.getString('plat') ?? "";

    // Fetch orders realtime from API filtered by name
    await OrderData.fetchFromApi(nama: namaUser);

    final raw = prefs.getString('daftar_kendaraan');
    if (raw != null && raw.isNotEmpty) {
      try {
        final List<dynamic> list = jsonDecode(raw);
        vehicles = list.map((item) => VehicleModel.fromJson(item)).toList();
      } catch (e) {
        vehicles = [];
      }
    }

    // Fallback if list is empty but single active vehicle exists
    if (vehicles.isEmpty && activeMotor.isNotEmpty && activeMotor != "-") {
      vehicles.add(VehicleModel(motor: activeMotor, plat: activePlat));
      await _saveVehiclesList();
    }

    // Determine currently active index
    selectedIndex = 0;
    for (int i = 0; i < vehicles.length; i++) {
      if (vehicles[i].plat.replaceAll(' ', '').toLowerCase() ==
          activePlat.replaceAll(' ', '').toLowerCase()) {
        selectedIndex = i;
        break;
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _saveVehiclesList() async {
    final prefs = await SharedPreferences.getInstance();
    final data = vehicles.map((v) => v.toJson()).toList();
    await prefs.setString('daftar_kendaraan', jsonEncode(data));
  }

  Future<void> _setActiveVehicle(int index) async {
    if (index < 0 || index >= vehicles.length) return;
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedIndex = index;
      activeMotor = vehicles[index].motor;
      activePlat = vehicles[index].plat;
    });
    await prefs.setString('motor', activeMotor);
    await prefs.setString('plat', activePlat);
  }

  List<OrderModel> _getVehicleOrders(String plat) {
    final cleanPlat = plat.replaceAll(' ', '').toLowerCase();
    final lowerName = namaUser.trim().toLowerCase();
    return OrderData.orders.reversed
        .where((o) =>
            o.noPolisi.replaceAll(' ', '').toLowerCase() == cleanPlat &&
            (lowerName.isEmpty || o.nama.trim().toLowerCase() == lowerName))
        .toList();
  }

  String _calculateMemberLevel(List<OrderModel> orders) {
    final selesai = orders
        .where((o) => o.status == 'Selesai' || o.status == 'Sudah Dibayar')
        .length;
    if (selesai >= 20) return "Platinum";
    if (selesai >= 10) return "Gold";
    if (selesai >= 5) return "Silver";
    return "Bronze";
  }

  Color _getMemberColor(String level) {
    switch (level) {
      case "Platinum":
        return Colors.blue.shade800;
      case "Gold":
        return Colors.amber.shade700;
      case "Silver":
        return Colors.grey.shade600;
      default:
        return Colors.orange.shade700;
    }
  }

  void _showAddVehicleDialog() {
    final motorController = TextEditingController();
    final platController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text(
            "Tambah Kendaraan",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: motorController,
                  decoration: InputDecoration(
                    labelText: "Tipe Motor",
                    hintText: "Contoh: Yamaha NMAX",
                    prefixIcon: const Icon(Icons.motorcycle_rounded),
                    filled: true,
                    fillColor: const Color(0xFFF4F7FB),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) =>
                      value == null || value.trim().isEmpty ? "Tipe motor harus diisi" : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: platController,
                  decoration: InputDecoration(
                    labelText: "Nomor Polisi",
                    hintText: "Contoh: B 1234 ABC",
                    prefixIcon: const Icon(Icons.pin_outlined),
                    filled: true,
                    fillColor: const Color(0xFFF4F7FB),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) =>
                      value == null || value.trim().isEmpty ? "Nomor polisi harus diisi" : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D1B2A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final newVehicle = VehicleModel(
                    motor: motorController.text.trim(),
                    plat: platController.text.trim().toUpperCase(),
                  );
                  setState(() {
                    vehicles.add(newVehicle);
                  });
                  await _saveVehiclesList();
                  if (vehicles.length == 1) {
                    await _setActiveVehicle(0);
                  } else {
                    // Set active to the newly added vehicle by default
                    await _setActiveVehicle(vehicles.length - 1);
                  }
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text("Simpan", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }



  void _deleteVehicle(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Hapus Kendaraan", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text("Apakah Anda yakin ingin menghapus kendaraan ${vehicles[index].motor} (${vehicles[index].plat})?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        vehicles.removeAt(index);
      });
      await _saveVehiclesList();
      if (vehicles.isEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('motor', '-');
        await prefs.setString('plat', '-');
        setState(() {
          selectedIndex = 0;
          activeMotor = "-";
          activePlat = "-";
        });
      } else {
        if (index == selectedIndex) {
          await _setActiveVehicle(0);
        } else if (selectedIndex > index) {
          setState(() {
            selectedIndex--;
          });
        }
      }
    }
  }

  String _getDisplayStatus(String status, String payment) {
    if (status == 'Diproses') {
      return 'Dikonfirmasi';
    }
    if (status == 'Sudah Dibayar' || status == 'Selesai') {
      final lowerPayment = payment.toLowerCase();
      if (lowerPayment.contains('transfer')) {
        return 'Selesai';
      } else if (lowerPayment.contains('ditempat') || lowerPayment.contains('cod')) {
        return 'Selesai & Sudah Dibayar';
      }
      return 'Selesai';
    }
    return status;
  }

  Color _getStatusColor(String status) {
    if (status.contains("Selesai") || status.contains("Sudah Dibayar")) return Colors.green;
    if (status.contains("Diproses") || status.contains("Dikonfirmasi")) return Colors.blue;
    if (status.contains("Ditolak")) return Colors.red;
    return Colors.orange;
  }

  void _showOrderDetailSheet(OrderModel order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 60,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Center(
                  child: Text(
                    "Detail Riwayat Layanan",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F7FB),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      _detailRow("Invoice", order.invoice),
                      _detailRow("Layanan", order.layanan),
                      _detailRow("Tanggal", order.tanggal),
                      _detailRow("Jam", order.waktu),
                      _detailRow("Tipe Motor", order.tipeMotor),
                      _detailRow("No Polisi", order.noPolisi),
                      _detailRow("Pembayaran", order.payment),
                      _detailRow("Total Harga", order.harga),
                      _detailRow("Status Pemesanan", _getDisplayStatus(order.status, order.payment)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () => _contactAdminWhatsApp(order.invoice, "tanya"),
                    icon: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white),
                    label: const Text("Hubungi CS via WhatsApp", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D1B2A),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Tutup", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 13),
            ),
          ),
          Expanded(
            flex: 7,
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedVehicle = vehicles.isNotEmpty && selectedIndex < vehicles.length
        ? vehicles[selectedIndex]
        : null;

    final vehicleOrders = selectedVehicle != null
        ? _getVehicleOrders(selectedVehicle.plat)
        : <OrderModel>[];

    final memberLevel = selectedVehicle != null
        ? _calculateMemberLevel(vehicleOrders)
        : "Bronze";

    // Count only completed orders for the stat card
    final totalSelesai = vehicleOrders
        .where((o) => o.status == 'Selesai' || o.status == 'Sudah Dibayar')
        .length;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Kendaraan Saya",
          style: TextStyle(
            color: Color(0xFF0D1B2A),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0D1B2A), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: Color(0xFF0D1B2A), size: 24),
            onPressed: _showAddVehicleDialog,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Horizontal list of vehicles
                if (vehicles.isNotEmpty)
                  Container(
                    height: 130,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      scrollDirection: Axis.horizontal,
                      itemCount: vehicles.length,
                      itemBuilder: (context, index) {
                        final v = vehicles[index];
                        final isSelected = index == selectedIndex;
                        return GestureDetector(
                          onTap: () => _setActiveVehicle(index),
                          child: Container(
                            width: 200,
                            margin: const EdgeInsets.only(right: 14),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? const LinearGradient(
                                      colors: [Color(0xFF0D1B2A), Color(0xFF1B263B)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : null,
                              color: isSelected ? null : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? Colors.transparent : Colors.grey.shade200,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Icon(
                                      Icons.motorcycle_rounded,
                                      color: isSelected ? Colors.white : const Color(0xFF0D1B2A),
                                      size: 26,
                                    ),
                                    if (v.plat == activePlat)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade600,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Text(
                                          "Utama",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const Spacer(),
                                Text(
                                  v.motor,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : const Color(0xFF0D1B2A),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  v.plat,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white70 : Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                if (vehicles.isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.motorcycle_rounded, size: 75, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          const Text(
                            "Belum ada kendaraan terdaftar",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0D1B2A),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.add, color: Colors.white),
                            label: const Text("Tambah Kendaraan", style: TextStyle(color: Colors.white)),
                            onPressed: _showAddVehicleDialog,
                          ),
                        ],
                      ),
                    ),
                  ),

                if (selectedVehicle != null) ...[
                  // Details section for the selected vehicle
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. DETAIL KENDARAAN (with edit & delete options)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "👤 Detail Kendaraan",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Row(
                                children: [
                                  if (vehicles.length > 1)
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
                                      onPressed: () => _deleteVehicle(selectedIndex),
                                    ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.motorcycle, color: Colors.grey),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text("Tipe Motor", style: TextStyle(fontSize: 12, color: Colors.grey)),
                                        Text(selectedVehicle.motor, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                      ],
                                    ),
                                  ],
                                ),
                                const Divider(height: 24),
                                Row(
                                  children: [
                                    const Icon(Icons.pin, color: Colors.grey),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text("Nomor Polisi", style: TextStyle(fontSize: 12, color: Colors.grey)),
                                        Text(selectedVehicle.plat, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // 2. MEMBER & TOTAL BOOKING STATS
                          Row(
                            children: [
                              // Member card
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.grey.shade200),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: _getMemberColor(memberLevel).withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(Icons.star_rounded, color: _getMemberColor(memberLevel), size: 24),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text("⭐ Member", style: TextStyle(fontSize: 11, color: Colors.grey)),
                                            Text(
                                              memberLevel,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: _getMemberColor(memberLevel),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Total Booking card
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.grey.shade200),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Icon(Icons.calendar_today_rounded, color: Colors.green, size: 20),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text("📅 Total Booking", style: TextStyle(fontSize: 11, color: Colors.grey)),
                                            Text(
                                              "${vehicleOrders.length} Booking (${totalSelesai} Selesai)",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: Colors.green,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // 3. RIWAYAT LAYANAN KENDARAAN
                          const Text(
                            "📜 Riwayat Layanan Kendaraan",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 12),
                          if (vehicleOrders.isEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: const Column(
                                children: [
                                  Icon(Icons.notes_rounded, color: Colors.grey, size: 36),
                                  SizedBox(height: 10),
                                  Text(
                                    "Belum ada riwayat layanan untuk kendaraan ini",
                                    style: TextStyle(color: Colors.grey, fontSize: 13),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          if (vehicleOrders.isNotEmpty)
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: vehicleOrders.length,
                              itemBuilder: (context, index) {
                                final order = vehicleOrders[index];
                                final displayStatus = _getDisplayStatus(order.status, order.payment);
                                final statusColor = _getStatusColor(displayStatus);
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.grey.shade200),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                    title: Text(
                                      order.layanan,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    subtitle: Text(
                                      "${order.tanggal} @ ${order.waktu}",
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                    trailing: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          order.harga,
                                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: statusColor.withOpacity(0.12),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            displayStatus,
                                            style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 9),
                                          ),
                                        ),
                                      ],
                                    ),
                                    onTap: () => _showOrderDetailSheet(order),
                                  ),
                                );
                              },
                            ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}
