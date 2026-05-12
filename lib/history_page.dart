import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'order_model.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  Timer? timer;

  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    /// AUTO REFRESH
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        /// AUTO CANCEL
        for (var order in OrderData.orders) {
          if (order.status == "Menunggu Pembayaran") {
            DateTime expired = DateTime.parse(order.expired);

            if (DateTime.now().isAfter(expired)) {
              order.status = "Dibatalkan";
            }
          }
        }
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  /// STATUS COLOR
  Color statusColor(String status) {
    switch (status) {
      case "Sudah Dibayar":
        return Colors.green;

      case "Dibatalkan":
        return Colors.red;

      default:
        return Colors.orange;
    }
  }

  /// STATUS BG
  Color statusBg(String status) {
    return statusColor(status).withOpacity(0.12);
  }

  /// COUNTDOWN
  String getCountdown(String expired) {
    DateTime exp = DateTime.parse(expired);

    Duration diff = exp.difference(DateTime.now());

    if (diff.isNegative) {
      return "00:00";
    }

    int hours = diff.inHours;

    int minutes = diff.inMinutes.remainder(60);

    int seconds = diff.inSeconds.remainder(60);

    return "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
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
          "Riwayat Pesanan",
          style: TextStyle(
            color: Color(0xFF0D1B2A),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: OrderData.orders.isEmpty
          ? const Center(
              child: Text("Belum ada pesanan", style: TextStyle(fontSize: 16)),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(18),

              itemCount: OrderData.orders.length,

              itemBuilder: (context, index) {
                final order = OrderData.orders[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 20),

                  decoration: BoxDecoration(
                    color: Colors.white,

                    borderRadius: BorderRadius.circular(28),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),

                  child: Padding(
                    padding: const EdgeInsets.all(20),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        /// TOP
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),

                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF0D1B2A,
                                ).withOpacity(0.08),

                                borderRadius: BorderRadius.circular(18),
                              ),

                              child: const Icon(
                                Icons.local_car_wash,
                                color: Color(0xFF0D1B2A),
                              ),
                            ),

                            const SizedBox(width: 14),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  Text(
                                    order.invoice,

                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  Text(
                                    order.layanan,

                                    style: TextStyle(
                                      color: Colors.grey.shade600,
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
                                color: statusBg(order.status),

                                borderRadius: BorderRadius.circular(20),
                              ),

                              child: Text(
                                order.status,

                                style: TextStyle(
                                  color: statusColor(order.status),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 22),

                        /// DATE
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_month,
                              size: 18,
                              color: Colors.grey,
                            ),

                            const SizedBox(width: 8),

                            Text("${order.tanggal} • ${order.waktu}"),
                          ],
                        ),

                        const SizedBox(height: 12),

                        /// PRICE
                        Row(
                          children: [
                            const Icon(
                              Icons.payments,
                              size: 18,
                              color: Colors.grey,
                            ),

                            const SizedBox(width: 8),

                            Text(
                              order.harga,

                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),

                        /// COUNTDOWN
                        if (order.status == "Menunggu Pembayaran")
                          Padding(
                            padding: const EdgeInsets.only(top: 18),

                            child: Container(
                              padding: const EdgeInsets.all(16),

                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.12),

                                borderRadius: BorderRadius.circular(18),
                              ),

                              child: Row(
                                children: [
                                  const Icon(Icons.timer, color: Colors.orange),

                                  const SizedBox(width: 12),

                                  Expanded(
                                    child: Text(
                                      "Bayar sebelum ${getCountdown(order.expired)}",
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        const SizedBox(height: 24),

                        /// BUTTON DETAIL
                        SizedBox(
                          width: double.infinity,

                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0D1B2A),

                              elevation: 0,

                              padding: const EdgeInsets.symmetric(vertical: 15),

                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),

                            icon: const Icon(
                              Icons.visibility,
                              color: Colors.white,
                            ),

                            label: const Text(
                              "Lihat Detail",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
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
                                        height:
                                            MediaQuery.of(context).size.height *
                                            0.82,

                                        decoration: const BoxDecoration(
                                          color: Colors.white,

                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(35),
                                          ),
                                        ),

                                        child: SingleChildScrollView(
                                          child: Padding(
                                            padding: const EdgeInsets.all(24),

                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,

                                              children: [
                                                /// HANDLE
                                                Center(
                                                  child: Container(
                                                    width: 70,
                                                    height: 5,

                                                    decoration: BoxDecoration(
                                                      color:
                                                          Colors.grey.shade300,

                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            20,
                                                          ),
                                                    ),
                                                  ),
                                                ),

                                                const SizedBox(height: 25),

                                                /// HEADER
                                                Row(
                                                  children: [
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            14,
                                                          ),

                                                      decoration: BoxDecoration(
                                                        color: const Color(
                                                          0xFF0D1B2A,
                                                        ).withOpacity(0.08),

                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              18,
                                                            ),
                                                      ),

                                                      child: const Icon(
                                                        Icons.receipt_long,
                                                        color: Color(
                                                          0xFF0D1B2A,
                                                        ),
                                                        size: 28,
                                                      ),
                                                    ),

                                                    const SizedBox(width: 16),

                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,

                                                        children: [
                                                          const Text(
                                                            "Detail Pemesanan",

                                                            style: TextStyle(
                                                              fontSize: 22,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),

                                                          const SizedBox(
                                                            height: 4,
                                                          ),

                                                          Text(
                                                            order.invoice,

                                                            style: TextStyle(
                                                              color: Colors
                                                                  .grey
                                                                  .shade600,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),

                                                const SizedBox(height: 28),

                                                /// DETAIL CARD
                                                Container(
                                                  padding: const EdgeInsets.all(
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
                                                      detailItem(
                                                        Icons.person,
                                                        "Nama Pemesan",
                                                        order.nama,
                                                      ),

                                                      detailItem(
                                                        Icons.local_car_wash,
                                                        "Layanan",
                                                        order.layanan,
                                                      ),

                                                      detailItem(
                                                        Icons.credit_card,
                                                        "No Polisi",
                                                        order.noPolisi,
                                                      ),

                                                      detailItem(
                                                        Icons.motorcycle,
                                                        "Tipe Motor",
                                                        order.tipeMotor,
                                                      ),

                                                      detailItem(
                                                        Icons.calendar_month,
                                                        "Tanggal Booking",
                                                        order.tanggal,
                                                      ),

                                                      detailItem(
                                                        Icons.access_time,
                                                        "Jam Booking",
                                                        order.waktu,
                                                      ),

                                                      detailItem(
                                                        Icons.payments,
                                                        "Metode Pembayaran",
                                                        order.payment,
                                                      ),

                                                      detailItem(
                                                        Icons.attach_money,
                                                        "Total Harga",
                                                        order.harga,
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                                const SizedBox(height: 24),

                                                /// REKENING
                                                if (order.payment ==
                                                        "Transfer Bank" &&
                                                    order.status ==
                                                        "Menunggu Pembayaran")
                                                  Container(
                                                    width: double.infinity,

                                                    padding:
                                                        const EdgeInsets.all(
                                                          22,
                                                        ),

                                                    decoration: BoxDecoration(
                                                      gradient:
                                                          const LinearGradient(
                                                            colors: [
                                                              Color(0xFF0D1B2A),
                                                              Color(0xFF1B263B),
                                                            ],
                                                          ),

                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            28,
                                                          ),
                                                    ),

                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,

                                                      children: [
                                                        Row(
                                                          children: const [
                                                            Icon(
                                                              Icons
                                                                  .account_balance,
                                                              color:
                                                                  Colors.white,
                                                            ),

                                                            SizedBox(width: 8),

                                                            Text(
                                                              "Transfer Pembayaran",

                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 18,
                                                              ),
                                                            ),
                                                          ],
                                                        ),

                                                        const SizedBox(
                                                          height: 22,
                                                        ),

                                                        const Text(
                                                          "BANK BCA",

                                                          style: TextStyle(
                                                            color:
                                                                Colors.white70,
                                                          ),
                                                        ),

                                                        const SizedBox(
                                                          height: 8,
                                                        ),

                                                        const Text(
                                                          "1234567890",

                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 30,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),

                                                        const SizedBox(
                                                          height: 6,
                                                        ),

                                                        const Text(
                                                          "a/n MotoWash77",

                                                          style: TextStyle(
                                                            color:
                                                                Colors.white70,
                                                          ),
                                                        ),

                                                        const SizedBox(
                                                          height: 22,
                                                        ),

                                                        Container(
                                                          padding:
                                                              const EdgeInsets.all(
                                                                14,
                                                              ),

                                                          decoration: BoxDecoration(
                                                            color: Colors.white
                                                                .withOpacity(
                                                                  0.12,
                                                                ),

                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  18,
                                                                ),
                                                          ),

                                                          child: Row(
                                                            children: [
                                                              const Icon(
                                                                Icons.timer,
                                                                color: Colors
                                                                    .orange,
                                                              ),

                                                              const SizedBox(
                                                                width: 10,
                                                              ),

                                                              Expanded(
                                                                child: Text(
                                                                  "Bayar sebelum ${getCountdown(order.expired)}",

                                                                  style: const TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),

                                                const SizedBox(height: 30),

                                                /// UPLOAD
                                                if (order.status ==
                                                    "Menunggu Pembayaran")
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,

                                                    children: [
                                                      const Text(
                                                        "Upload Bukti Pembayaran",

                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 17,
                                                        ),
                                                      ),

                                                      const SizedBox(
                                                        height: 14,
                                                      ),

                                                      GestureDetector(
                                                        onTap: () async {
                                                          /// PICK IMAGE
                                                          final XFile?
                                                          image = await picker
                                                              .pickImage(
                                                                source:
                                                                    ImageSource
                                                                        .gallery,
                                                              );

                                                          /// BATAL
                                                          if (image == null) {
                                                            return;
                                                          }

                                                          /// VALIDASI
                                                          String lower = image
                                                              .path
                                                              .toLowerCase();

                                                          if (!lower.endsWith(
                                                                ".jpg",
                                                              ) &&
                                                              !lower.endsWith(
                                                                ".jpeg",
                                                              ) &&
                                                              !lower.endsWith(
                                                                ".png",
                                                              )) {
                                                            ScaffoldMessenger.of(
                                                              context,
                                                            ).showSnackBar(
                                                              const SnackBar(
                                                                content: Text(
                                                                  "File harus JPG atau PNG",
                                                                ),

                                                                backgroundColor:
                                                                    Colors.red,
                                                              ),
                                                            );

                                                            return;
                                                          }

                                                          /// UPDATE STATUS
                                                          setState(() {
                                                            order.buktiPembayaran =
                                                                image.path;

                                                            order.status =
                                                                "Sudah Dibayar";
                                                          });

                                                          Navigator.pop(
                                                            context,
                                                          );

                                                          ScaffoldMessenger.of(
                                                            context,
                                                          ).showSnackBar(
                                                            const SnackBar(
                                                              content: Text(
                                                                "Bukti pembayaran berhasil dikirim!",
                                                              ),

                                                              backgroundColor:
                                                                  Colors.green,
                                                            ),
                                                          );
                                                        },

                                                        child: Container(
                                                          width:
                                                              double.infinity,

                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                vertical: 24,
                                                              ),

                                                          decoration: BoxDecoration(
                                                            border: Border.all(
                                                              color:
                                                                  Colors.blue,
                                                              width: 1.5,
                                                            ),

                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  22,
                                                                ),

                                                            color: Colors.blue
                                                                .withOpacity(
                                                                  0.05,
                                                                ),
                                                          ),

                                                          child: Column(
                                                            children: const [
                                                              Icon(
                                                                Icons
                                                                    .cloud_upload,
                                                                size: 45,
                                                                color:
                                                                    Colors.blue,
                                                              ),

                                                              SizedBox(
                                                                height: 10,
                                                              ),

                                                              Text(
                                                                "Tap untuk upload JPG / PNG",
                                                                style: TextStyle(
                                                                  color: Colors
                                                                      .blue,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),

                                                /// PREVIEW
                                                if (order
                                                    .buktiPembayaran
                                                    .isNotEmpty)
                                                  Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                          top: 24,
                                                        ),

                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,

                                                      children: [
                                                        const Text(
                                                          "Bukti Pembayaran",

                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 17,
                                                          ),
                                                        ),

                                                        const SizedBox(
                                                          height: 14,
                                                        ),

                                                        ClipRRect(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                22,
                                                              ),

                                                          child: Image.file(
                                                            File(
                                                              order
                                                                  .buktiPembayaran,
                                                            ),

                                                            height: 220,

                                                            width:
                                                                double.infinity,

                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),

                                                const SizedBox(height: 30),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  /// DETAIL ITEM
  Widget detailItem(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),

      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),

            decoration: BoxDecoration(
              color: Colors.white,

              borderRadius: BorderRadius.circular(14),
            ),

            child: Icon(icon, size: 20, color: const Color(0xFF0D1B2A)),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  title,

                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),

                const SizedBox(height: 3),

                Text(
                  value,

                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
