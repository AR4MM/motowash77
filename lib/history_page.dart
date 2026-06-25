import 'dart:async';
import 'dart:convert';
import 'src/file_image_helper.dart' as file_image_helper;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'home_page.dart';
import 'booking_form_page.dart';
import 'profile_page.dart';
import 'models/order_model.dart';


class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  Timer? timer;

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

  bool _isLoading = true;
  String _namaUser = '';
  String _platUser = '';

  List<OrderModel> _getUserOrders() {
    if (_namaUser.trim().isEmpty || _platUser.trim().isEmpty || _platUser.trim() == '-') return [];
    final lowerName = _namaUser.trim().toLowerCase();
    final cleanPlat = _platUser.replaceAll(' ', '').toLowerCase();
    return OrderData.orders
        .where((o) =>
            o.nama.trim().toLowerCase() == lowerName &&
            o.noPolisi.replaceAll(' ', '').toLowerCase() == cleanPlat)
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _initData();

    /// REALTIME TIMER — refreshes every 5 seconds from API
    timer = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (_namaUser.trim().isEmpty || _platUser.trim().isEmpty || _platUser.trim() == '-') return;
      await OrderData.fetchFromApi(nama: _namaUser, noPolisi: _platUser);
      if (mounted) setState(() {});
    });
  }

  Future<void> _initData() async {
    final prefs = await SharedPreferences.getInstance();
    _namaUser = prefs.getString('nama') ?? '';
    _platUser = prefs.getString('plat') ?? '';
    if (_namaUser.trim().isNotEmpty && _platUser.trim().isNotEmpty && _platUser.trim() != '-') {
      await OrderData.fetchFromApi(nama: _namaUser, noPolisi: _platUser);
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<bool> uploadBuktiPembayaran(String invoice, XFile pickedFile) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://localhost/motowash_api/upload_bukti.php'),
      );

      final fileName = pickedFile.name;
      final fileBytes = await pickedFile.readAsBytes();

      request.fields['invoice'] = invoice;
      request.fields['file_name'] = fileName;
      request.files.add(
        http.MultipartFile.fromBytes(
          'bukti_pembayaran',
          fileBytes,
          filename: fileName,
        ),
      );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        debugPrint('Upload bukti sukses: $responseBody');
        return true;
      }

      debugPrint('Upload bukti gagal: ${response.statusCode} ${responseBody}');
      return false;
    } catch (e) {
      debugPrint('Upload bukti error: $e');
      return false;
    }
  }

  /// ================= COUNTDOWN =================
  String getCountdown(String tanggal, String waktu) {
    try {
      final splitTanggal = tanggal.split("-");

      int day = int.parse(splitTanggal[0]);
      int month = int.parse(splitTanggal[1]);
      int year = int.parse(splitTanggal[2]);

      TimeOfDay time = parseTime(waktu);

      DateTime bookingDate = DateTime(year, month, day, time.hour, time.minute);

      Duration diff = bookingDate.difference(DateTime.now());

      if (diff.isNegative) {
        return "Booking Expired";
      }

      int days = diff.inDays;
      int hours = diff.inHours % 24;
      int minutes = diff.inMinutes % 60;
      int seconds = diff.inSeconds % 60;

      return "$days Hari "
          "${hours.toString().padLeft(2, '0')}:"
          "${minutes.toString().padLeft(2, '0')}:"
          "${seconds.toString().padLeft(2, '0')}";
    } catch (e) {
      return "Format Salah";
    }
  }

  /// ================= PARSE TIME =================
  TimeOfDay parseTime(String value) {
    value = value.toUpperCase();

    bool isPM = value.contains("PM");

    value = value.replaceAll("AM", "").replaceAll("PM", "").trim();

    List<String> parts = value.split(":");

    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);

    if (isPM && hour < 12) {
      hour += 12;
    }

    if (!isPM && hour == 12) {
      hour = 0;
    }

    return TimeOfDay(hour: hour, minute: minute);
  }

  String getDisplayStatus(String status, String payment) {
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

  /// ================= STATUS COLOR =================
  Color statusColor(String status) {
    switch (status) {
      case "Menunggu Konfirmasi":
      case "Menunggu Pembayaran":
        return Colors.orange;

      case "Diproses":
      case "Dikonfirmasi":
        return Colors.blue;

      case "Sudah Dibayar":
      case "Selesai":
      case "Selesai & Sudah Dibayar":
        return Colors.green;

      case "Expired":
      case "Ditolak":
      case "Dibatalkan":
        return Colors.red;

      default:
        return Colors.orange;
    }
  }

  /// ================= STATUS ICON =================
  IconData statusIcon(String status) {
    switch (status) {
      case "Menunggu Konfirmasi":
      case "Menunggu Pembayaran":
        return Icons.access_time_filled;

      case "Diproses":
      case "Dikonfirmasi":
        return Icons.play_circle_filled;

      case "Sudah Dibayar":
      case "Selesai":
      case "Selesai & Sudah Dibayar":
        return Icons.check_circle;

      case "Expired":
      case "Ditolak":
      case "Dibatalkan":
        return Icons.cancel;

      default:
        return Icons.info;
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
          "Riwayat Booking",
          style: TextStyle(
            color: Color(0xFF0D1B2A),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _getUserOrders().isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  Icon(
                    Icons.history_toggle_off,
                    size: 90,
                    color: Colors.grey.shade400,
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    "Belum Ada Booking",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Booking layanan terlebih dahulu",
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(18),
              itemCount: _getUserOrders().length,

              itemBuilder: (context, index) {
                final order = _getUserOrders().reversed.toList()[index];

                String countdown = getCountdown(order.tanggal, order.waktu);

                /// AUTO EXPIRED
                if (countdown == "Booking Expired" &&
                    order.status != "Sudah Dibayar") {
                  order.status = "Expired";
                }

                final displayStatus = getDisplayStatus(order.status, order.payment);

                return Container(
                  margin: const EdgeInsets.only(bottom: 24),

                  decoration: BoxDecoration(
                    color: Colors.white,

                    borderRadius: BorderRadius.circular(30),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),

                  child: Column(
                    children: [
                      /// ================= HEADER =================
                      Container(
                        padding: const EdgeInsets.all(20),

                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF0D1B2A), Color(0xFF1B4F9C)],
                          ),

                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(30),
                          ),
                        ),

                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),

                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),

                                borderRadius: BorderRadius.circular(18),
                              ),

                              child: const Icon(
                                Icons.local_car_wash,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),

                            const SizedBox(width: 16),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  Text(
                                    order.layanan,

                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  Text(
                                    order.invoice,

                                    style: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),

                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),

                                borderRadius: BorderRadius.circular(30),
                              ),

                              child: Text(
                                order.payment,

                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      /// ================= CONTENT =================
                      Padding(
                        padding: const EdgeInsets.all(22),

                        child: Column(
                          children: [
                            infoRow(Icons.person, "Nama", order.nama),

                            infoRow(Icons.motorcycle, "Motor", order.tipeMotor),

                            infoRow(
                              Icons.credit_card,
                              "No Polisi",
                              order.noPolisi,
                            ),

                            infoRow(
                              Icons.calendar_month,
                              "Tanggal",
                              order.tanggal,
                            ),

                            infoRow(Icons.access_time, "Jam", order.waktu),

                            const SizedBox(height: 22),

                            /// STATUS
                            Container(
                              padding: const EdgeInsets.all(18),

                              decoration: BoxDecoration(
                                color: statusColor(
                                  displayStatus,
                                ).withOpacity(0.12),

                                borderRadius: BorderRadius.circular(22),
                              ),

                              child: Row(
                                children: [
                                  Icon(
                                    statusIcon(displayStatus),
                                    color: statusColor(displayStatus),
                                    size: 30,
                                  ),

                                  const SizedBox(width: 14),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,

                                      children: [
                                        const Text(
                                          "Status Pemesanan",
                                          style: TextStyle(color: Colors.grey),
                                        ),

                                        const SizedBox(height: 4),

                                        Text(
                                          displayStatus,

                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color: statusColor(displayStatus),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 14),

                            // ===== PROGRESS TRACKER =====
                            Builder(builder: (ctx2) {
                              int activeStep;
                              if (order.status == 'Expired' || order.status == 'Ditolak' || order.status == 'Dibatalkan') {
                                activeStep = -1;
                              } else if (order.status == 'Selesai' || order.status == 'Sudah Dibayar') {
                                activeStep = 3;
                              } else if (order.status == 'Diproses') {
                                activeStep = 2;
                              } else if (order.status == 'Menunggu Konfirmasi' || order.status == 'Menunggu Pembayaran') {
                                activeStep = 1;
                              } else {
                                activeStep = 0;
                              }
                              const stepLabels = ['Booking\nDibuat', 'Menunggu\nKonfirmasi', 'Sedang\nDiproses', 'Selesai'];
                              const stepIcons = [Icons.add_circle_outline, Icons.hourglass_empty_rounded, Icons.settings_outlined, Icons.verified_outlined];
                              if (activeStep == -1) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.red.shade100)),
                                  child: Row(children: [
                                    Icon(Icons.cancel_outlined, color: Colors.red.shade400, size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(
                                      order.status == 'Ditolak' 
                                          ? 'Booking ditolak oleh admin' 
                                          : (order.status == 'Dibatalkan' 
                                              ? 'Booking dibatalkan oleh Anda' 
                                              : 'Booking telah kedaluwarsa'),
                                      style: TextStyle(fontSize: 12, color: Colors.red.shade700, fontWeight: FontWeight.w600))),
                                  ]),
                                );
                              }
                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade100)),
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  const Text('Progress Booking', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0D1B2A))),
                                  const SizedBox(height: 14),
                                  Row(children: List.generate(4, (i) {
                                    final isDone = i <= activeStep;
                                    final isActive = i == activeStep;
                                    return Expanded(child: Row(children: [
                                      Expanded(child: Column(children: [
                                        AnimatedContainer(
                                          duration: const Duration(milliseconds: 300),
                                          width: 36, height: 36,
                                          decoration: BoxDecoration(shape: BoxShape.circle,
                                            color: isDone ? (isActive ? Colors.green.shade500 : Colors.green.shade100) : Colors.grey.shade100,
                                            border: Border.all(color: isDone ? Colors.green.shade400 : Colors.grey.shade300, width: 2)),
                                          child: Icon(isDone ? Icons.check : stepIcons[i], size: 16,
                                            color: isDone ? (isActive ? Colors.white : Colors.green.shade600) : Colors.grey.shade400),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(stepLabels[i], textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 9, fontWeight: isDone ? FontWeight.w700 : FontWeight.w400,
                                            color: isDone ? const Color(0xFF0D1B2A) : Colors.grey.shade400, height: 1.3)),
                                      ])),
                                      if (i < 3) Expanded(child: Container(height: 2, margin: const EdgeInsets.only(bottom: 28),
                                        decoration: BoxDecoration(color: i < activeStep ? Colors.green.shade300 : Colors.grey.shade200, borderRadius: BorderRadius.circular(2)))),
                                    ]));
                                  })),
                                ]),
                              );
                            }),

                            const SizedBox(height: 22),

                            if (order.status != "Sudah Dibayar" &&
                                order.status != "Selesai" &&
                                order.status != "Ditolak" &&
                                order.status != "Dibatalkan" &&
                                order.status != "Expired") ...[
                              /// COUNTDOWN
                              Container(
                                padding: const EdgeInsets.all(20),

                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.blue.shade700,
                                      Colors.blue.shade400,
                                    ],
                                  ),

                                  borderRadius: BorderRadius.circular(24),
                                ),

                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(14),

                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.18),

                                        borderRadius: BorderRadius.circular(18),
                                      ),

                                      child: const Icon(
                                        Icons.timer,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                    ),

                                    const SizedBox(width: 16),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,

                                        children: [
                                          const Text(
                                            "Countdown Booking",
                                            style: TextStyle(
                                              color: Colors.white70,
                                            ),
                                          ),

                                          const SizedBox(height: 6),

                                          Text(
                                            countdown,

                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 24),
                            ],

                            /// TOTAL
                            Container(
                              padding: const EdgeInsets.all(20),

                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.08),

                                borderRadius: BorderRadius.circular(24),
                              ),

                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(14),

                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.15),

                                      borderRadius: BorderRadius.circular(18),
                                    ),

                                    child: const Icon(
                                      Icons.payments,
                                      color: Colors.green,
                                    ),
                                  ),

                                  const SizedBox(width: 16),

                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,

                                      children: [
                                        Text(
                                          "Total Pembayaran",
                                          style: TextStyle(color: Colors.grey),
                                        ),

                                        SizedBox(height: 4),

                                        Text(
                                          "Harus Dibayar",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  Text(
                                    order.harga,

                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 22),

                            /// BUTTON DETAIL
                            SizedBox(
                              width: double.infinity,
                              height: 54,

                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0D1B2A),

                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),

                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,

                                    builder: (context) {
                                      return StatefulBuilder(
                                        builder: (context, setModalState) {
                                          return Container(
                                            padding: const EdgeInsets.all(24),

                                            decoration: const BoxDecoration(
                                              color: Colors.white,

                                              borderRadius:
                                                  BorderRadius.vertical(
                                                    top: Radius.circular(32),
                                                  ),
                                            ),

                                            child: SingleChildScrollView(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,

                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,

                                                children: [
                                                  Center(
                                                    child: Container(
                                                      width: 60,
                                                      height: 6,

                                                      decoration: BoxDecoration(
                                                        color: Colors
                                                            .grey
                                                            .shade300,

                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              20,
                                                            ),
                                                      ),
                                                    ),
                                                  ),

                                                  const SizedBox(height: 24),

                                                  const Center(
                                                    child: Text(
                                                      "Detail Pemesanan",
                                                      style: TextStyle(
                                                        fontSize: 24,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),

                                                  const SizedBox(height: 26),

                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                          20,
                                                        ),

                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                        0xFFF4F7FB,
                                                      ),

                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            24,
                                                          ),
                                                    ),

                                                    child: Column(
                                                      children: [
                                                        detailRow(
                                                          "Invoice",
                                                          order.invoice,
                                                        ),

                                                        detailRow(
                                                          "Layanan",
                                                          order.layanan,
                                                        ),

                                                        detailRow(
                                                          "Nama",
                                                          order.nama,
                                                        ),

                                                        detailRow(
                                                          "Motor",
                                                          order.tipeMotor,
                                                        ),

                                                        detailRow(
                                                          "No Polisi",
                                                          order.noPolisi,
                                                        ),

                                                        detailRow(
                                                          "Tanggal",
                                                          order.tanggal,
                                                        ),

                                                        detailRow(
                                                          "Jam",
                                                          order.waktu,
                                                        ),

                                                        detailRow(
                                                          "Pembayaran",
                                                          order.payment,
                                                        ),

                                                        detailRow(
                                                          "Status Pemesanan",
                                                          getDisplayStatus(order.status, order.payment),
                                                        ),

                                                        detailRow(
                                                          "Harga",
                                                          order.harga,
                                                        ),
                                                      ],
                                                    ),
                                                  ),

                                                  const SizedBox(height: 24),

                                                  /// ================= TRANSFER =================
                                                  if (order.payment ==
                                                      "Transfer Bank") ...[
                                                    const Text(
                                                      "Transfer Pembayaran",
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),

                                                    const SizedBox(height: 16),

                                                    Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            20,
                                                          ),

                                                      decoration: BoxDecoration(
                                                        gradient:
                                                            const LinearGradient(
                                                              colors: [
                                                                Color(
                                                                  0xFF0D1B2A,
                                                                ),
                                                                Color(
                                                                  0xFF1B4F9C,
                                                                ),
                                                              ],
                                                            ),

                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              24,
                                                            ),
                                                      ),

                                                      child: Row(
                                                        children: [
                                                          Container(
                                                            padding:
                                                                const EdgeInsets.all(
                                                                  14,
                                                                ),

                                                            decoration: BoxDecoration(
                                                              color: Colors
                                                                  .white
                                                                  .withOpacity(
                                                                    0.15,
                                                                  ),

                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    18,
                                                                  ),
                                                            ),

                                                            child: const Icon(
                                                              Icons
                                                                  .account_balance,
                                                              color:
                                                                  Colors.white,
                                                              size: 32,
                                                            ),
                                                          ),

                                                          const SizedBox(
                                                            width: 16,
                                                          ),

                                                          const Expanded(
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,

                                                              children: [
                                                                Text(
                                                                  "BANK BCA",
                                                                  style: TextStyle(
                                                                    color: Colors
                                                                        .white70,
                                                                  ),
                                                                ),

                                                                SizedBox(
                                                                  height: 6,
                                                                ),

                                                                Text(
                                                                  "1234567890",
                                                                  style: TextStyle(
                                                                    color: Colors
                                                                        .white,

                                                                    fontSize:
                                                                        24,

                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),

                                                                SizedBox(
                                                                  height: 6,
                                                                ),

                                                                Text(
                                                                  "a/n MotoWash77",
                                                                  style: TextStyle(
                                                                    color: Colors
                                                                        .white70,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),

                                                    const SizedBox(height: 24),

                                                    const Text(
                                                      "Upload Bukti Transfer",
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),

                                                    const SizedBox(height: 16),

                                                    GestureDetector(
                                                      onTap: () async {
                                                        final picker =
                                                            ImagePicker();

                                                        final pickedFile =
                                                            await picker.pickImage(
                                                              source:
                                                                  ImageSource
                                                                      .gallery,

                                                              imageQuality: 70,
                                                            );

                                                        if (pickedFile !=
                                                            null) {
                                                          debugPrint(
                                                            'Invoice yang akan diupload: ${order.invoice}',
                                                          );
                                                          debugPrint(
                                                            'File path: ${pickedFile.path}',
                                                          );

                                                          setModalState(() {
                                                            order.buktiPembayaran =
                                                                pickedFile.path;
                                                            order.status =
                                                                "Menunggu Konfirmasi";
                                                          });

                                                          await OrderData.saveOrders();

                                                          try {
                                                            var request =
                                                                http.MultipartRequest(
                                                                  'POST',
                                                                  Uri.parse(
                                                                    "http://localhost/motowash_api/upload_bukti.php",
                                                                  ),
                                                                );

                                                            request.fields['invoice'] =
                                                                order.invoice;
                                                            request.fields['file_name'] =
                                                                pickedFile.name;

                                                            debugPrint(
                                                              'Upload request fields: ${request.fields}',
                                                            );
                                                            debugPrint(
                                                              'Upload file name: ${request.fields['file_name']}',
                                                            );

                                                            final fileBytes =
                                                                await pickedFile
                                                                    .readAsBytes();
                                                            request.files.add(
                                                              http.MultipartFile.fromBytes(
                                                                'bukti_pembayaran',
                                                                fileBytes,
                                                                filename:
                                                                    pickedFile
                                                                        .name,
                                                              ),
                                                            );

                                                            var response =
                                                                await request
                                                                    .send();
                                                            final responseBody =
                                                                await response
                                                                    .stream
                                                                    .bytesToString();

                                                            debugPrint(
                                                              'Upload status: ${response.statusCode}',
                                                            );
                                                            debugPrint(
                                                              'Upload response: $responseBody',
                                                            );

                                                            if (response
                                                                    .statusCode ==
                                                                200) {
                                                              try {
                                                                final jsonResp =
                                                                    jsonDecode(
                                                                      responseBody,
                                                                    );

                                                                if (jsonResp['success'] ==
                                                                    true) {
                                                                  showDialog(
                                                                    context:
                                                                        context,
                                                                    builder: (_) {
                                                                      return AlertDialog(
                                                                        title: const Text(
                                                                          "Berhasil",
                                                                        ),
                                                                        content: Text(
                                                                          jsonResp['message'] ??
                                                                              'Bukti pembayaran berhasil di upload',
                                                                        ),
                                                                        actions: [
                                                                          TextButton(
                                                                            onPressed: () {
                                                                              Navigator.pop(
                                                                                context,
                                                                              );
                                                                            },
                                                                            child: const Text(
                                                                              "OK",
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      );
                                                                    },
                                                                  );
                                                                } else {
                                                                  ScaffoldMessenger.of(
                                                                    context,
                                                                  ).showSnackBar(
                                                                    SnackBar(
                                                                      content: Text(
                                                                        jsonResp['message'] ??
                                                                            'Upload gagal',
                                                                      ),
                                                                    ),
                                                                  );
                                                                }
                                                              } catch (_) {
                                                                // Response bukan JSON, tetap anggap sukses
                                                                showDialog(
                                                                  context:
                                                                      context,
                                                                  builder: (_) {
                                                                    return AlertDialog(
                                                                      title: const Text(
                                                                        "Berhasil",
                                                                      ),
                                                                      content:
                                                                          const Text(
                                                                            "Bukti pembayaran berhasil di upload",
                                                                          ),
                                                                      actions: [
                                                                        TextButton(
                                                                          onPressed: () {
                                                                            Navigator.pop(
                                                                              context,
                                                                            );
                                                                          },
                                                                          child: const Text(
                                                                            "OK",
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    );
                                                                  },
                                                                );
                                                              }
                                                            } else {
                                                              ScaffoldMessenger.of(
                                                                context,
                                                              ).showSnackBar(
                                                                SnackBar(
                                                                  content: Text(
                                                                    'Gagal mengunggah. Server: ${response.statusCode} - $responseBody',
                                                                  ),
                                                                ),
                                                              );
                                                            }
                                                          } catch (e) {
                                                            debugPrint(
                                                              'Upload error: $e',
                                                            );
                                                            ScaffoldMessenger.of(
                                                              context,
                                                            ).showSnackBar(
                                                              SnackBar(
                                                                content: Text(
                                                                  'Terjadi kesalahan upload: $e',
                                                                ),
                                                              ),
                                                            );
                                                          }

                                                          setState(() {});
                                                        }
                                                      },

                                                      child: Container(
                                                        width: double.infinity,

                                                        padding:
                                                            const EdgeInsets.all(
                                                              24,
                                                            ),

                                                        decoration: BoxDecoration(
                                                          color: Colors.white,

                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                24,
                                                              ),

                                                          border: Border.all(
                                                            color: Colors
                                                                .grey
                                                                .shade300,

                                                            width: 2,
                                                          ),
                                                        ),

                                                        child: Column(
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .cloud_upload,

                                                              size: 52,

                                                              color: Colors
                                                                  .blue
                                                                  .shade700,
                                                            ),

                                                            const SizedBox(
                                                              height: 14,
                                                            ),

                                                            const Text(
                                                              "Upload JPG / PNG",
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,

                                                                fontSize: 16,
                                                              ),
                                                            ),

                                                            const SizedBox(
                                                              height: 6,
                                                            ),

                                                            const Text(
                                                              "Klik untuk upload bukti transfer",
                                                              style: TextStyle(
                                                                color:
                                                                    Colors.grey,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    if (order
                                                        .buktiPembayaran
                                                        .isNotEmpty) ...[
                                                      const SizedBox(
                                                        height: 20,
                                                      ),

                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              24,
                                                            ),

                                                        child: file_image_helper
                                                            .fileImage(
                                                              order
                                                                  .buktiPembayaran,
                                                              height: 240,
                                                              width: double
                                                                  .infinity,
                                                              fit: BoxFit.cover,
                                                            ),
                                                      ),
                                                    ],
                                                    const SizedBox(height: 16),
                                                    SizedBox(
                                                      width: double.infinity,
                                                      height: 52,
                                                      child: OutlinedButton.icon(
                                                        style: OutlinedButton.styleFrom(
                                                          side: const BorderSide(color: Colors.green, width: 2),
                                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                        ),
                                                        onPressed: () => _contactAdminWhatsApp(order.invoice, "pembayaran"),
                                                        icon: const Icon(Icons.send_rounded, color: Colors.green),
                                                        label: const Text("Konfirmasi Pembayaran via WhatsApp", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                                                      ),
                                                    ),
                                                  ],

                                                  const SizedBox(height: 28),

                                                  SizedBox(
                                                    width: double.infinity,
                                                    height: 56,
                                                    child: ElevatedButton.icon(
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: Colors.green,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(20),
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
                                                    height: 56,

                                                    child: ElevatedButton(
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            const Color(
                                                              0xFF0D1B2A,
                                                            ),

                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                20,
                                                              ),
                                                        ),
                                                      ),

                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },

                                                      child: const Text(
                                                        "Tutup",
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,

                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  );
                                },

                                icon: const Icon(
                                  Icons.receipt_long,
                                  color: Colors.white,
                                ),

                                label: const Text(
                                  "Lihat Detail Pemesanan",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),

                            if (order.status == 'Menunggu Konfirmasi' || order.status == 'Menunggu Pembayaran') ...[
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                height: 54,
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                        title: const Text("Batalkan Pesanan?", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D1B2A))),
                                        content: const Text("Apakah Anda yakin ingin membatalkan pesanan ini? Aksi ini tidak dapat dikembalikan."),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(ctx),
                                            child: const Text("Tutup", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red.shade600,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                            ),
                                            onPressed: () async {
                                              final messenger = ScaffoldMessenger.of(context);
                                              Navigator.pop(ctx);
                                              setState(() => _isLoading = true);
                                              final success = await OrderData.updateStatusInApi(order.invoice, "Dibatalkan");
                                              if (success) {
                                                await OrderData.fetchFromApi(nama: _namaUser, noPolisi: _platUser);
                                              }
                                              if (mounted) {
                                                setState(() => _isLoading = false);
                                                messenger.showSnackBar(
                                                  const SnackBar(content: Text("Pesanan berhasil dibatalkan")),
                                                );
                                              }
                                            },
                                            child: const Text("Ya, Batalkan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                                  label: const Text(
                                    "Batalkan Pesanan",
                                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: Colors.red.shade300, width: 1.5),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                    backgroundColor: Colors.red.shade50.withOpacity(0.3),
                                  ),
                                ),
                              ),
                            ],

                          ],
                        ),
                      ),
                    ],
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
          currentIndex: 2,

          backgroundColor: Colors.transparent,
          elevation: 0,

          type: BottomNavigationBarType.fixed,

          selectedItemColor: const Color(0xFF0D1B2A),
          unselectedItemColor: Colors.grey,

          onTap: (index) {
            if (index == 0) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomePage()),
              );
            }

            if (index == 1) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const BookingFormPage()),
              );
            }

            if (index == 3) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
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

  /// ================= INFO ROW =================
  Widget infoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),

      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade600),

          const SizedBox(width: 14),

          Text(
            "$title : ",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),

          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  /// ================= DETAIL ROW =================
  Widget detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),

      child: Row(
        children: [
          Expanded(
            flex: 4,

            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),

          Expanded(flex: 6, child: Text(value)),
        ],
      ),
    );
  }
}
