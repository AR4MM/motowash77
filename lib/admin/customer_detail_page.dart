import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/order_model.dart';

class CustomerDetailPage extends StatelessWidget {
  final Map<String, dynamic> customer;
  final List<OrderModel> orders;

  const CustomerDetailPage({
    required this.customer,
    required this.orders,
    super.key,
  });

  // Theme Constants
  final Color _bgDark = const Color(0xFF090D16);
  final Color _cardDark = const Color(0xFF111726);
  final Color _borderDark = const Color(0xFF1E293B);
  final Color _textSlate = const Color(0xFF94A3B8);

  Map<String, dynamic> _getMemberLevel(int bookingCount) {
    if (bookingCount >= 15) {
      return {
        'label': 'Platinum Member',
        'color': const Color(0xFFA855F7), // purple accent
        'bg': const Color(0xFFA855F7).withOpacity(0.12),
        'icon': Icons.star_rounded,
      };
    } else if (bookingCount >= 10) {
      return {
        'label': 'Gold Member',
        'color': const Color(0xFFF59E0B), // gold
        'bg': const Color(0xFFF59E0B).withOpacity(0.12),
        'icon': Icons.star_rounded,
      };
    } else if (bookingCount >= 5) {
      return {
        'label': 'Silver Member',
        'color': const Color(0xFF94A3B8), // silver
        'bg': const Color(0xFF94A3B8).withOpacity(0.12),
        'icon': Icons.star_rounded,
      };
    } else {
      return {
        'label': 'Bronze Member',
        'color': const Color(0xFFB45309), // bronze
        'bg': const Color(0xFFB45309).withOpacity(0.12),
        'icon': Icons.star_rounded,
      };
    }
  }

  int _parseHarga(String hargaStr) {
    String clean = hargaStr.replaceAll(RegExp(r'[^0-9]'), '');
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

  Color _statusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.menunggu:
        return const Color(0xFFF97316); // Orange
      case OrderStatus.diproses:
        return const Color(0xFF3B82F6); // Blue
      case OrderStatus.selesai:
        return const Color(0xFF10B981); // Green
      case OrderStatus.ditolak:
        return const Color(0xFFEF4444); // Red
    }
  }

  String _statusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.menunggu:
        return "Menunggu";
      case OrderStatus.diproses:
        return "Diproses";
      case OrderStatus.selesai:
        return "Selesai";
      case OrderStatus.ditolak:
        return "Dibatalkan";
    }
  }

  List<Map<String, dynamic>> _computeServiceStats() {
    final Map<String, int> counts = {};
    for (var o in orders) {
      final list = o.layanan.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty);
      for (var s in list) {
        counts[s] = (counts[s] ?? 0) + 1;
      }
    }

    int totalCount = counts.values.fold(0, (sum, val) => sum + val);
    if (totalCount == 0) totalCount = 1; // avoid divide by zero

    final list = counts.entries.map((e) {
      final double percent = e.value / totalCount;
      return {
        'name': e.key,
        'count': e.value,
        'percent': percent,
      };
    }).toList();

    list.sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final bool isMock = orders.isEmpty;

    // Resolve Stats dynamically
    final int bookingsCount = isMock ? (customer['bookingsCount'] as int? ?? 15) : orders.length;
    final int totalSpent = isMock ? (customer['totalSpent'] as int? ?? 1250000) : orders.fold(0, (sum, o) {
      if (o.status == 'Sudah Dibayar' || o.status == 'Selesai' || o.status == 'Diproses') {
        return sum + _parseHarga(o.harga);
      }
      return sum;
    });
    final int averageSpent = bookingsCount > 0 ? (totalSpent ~/ bookingsCount) : 0;
    final String lastActiveDate = isMock ? (customer['lastActive'] as String? ?? "25 Jun 2026") : (orders.isNotEmpty ? orders.last.tanggal : "-");

    final memberInfo = _getMemberLevel(bookingsCount);
    final tierColor = memberInfo['color'] as Color;

    final phone = customer['phone'] as String? ?? (customer['nama'].toString().toLowerCase().contains("deri") ? "0812-3456-7890" : "0813-9876-5432");
    final plate = customer['noPolisi'] as String? ?? "B 1234 KZX";
    final vehicle = customer['tipeMotor'] as String? ?? "Vario 150";

    // Service statistics calculations
    final List<Map<String, dynamic>> serviceStats;
    if (isMock) {
      serviceStats = [
        {'name': 'Wash & Wax', 'count': 8, 'percent': 0.53},
        {'name': 'Engine Detailing', 'count': 3, 'percent': 0.20},
        {'name': 'Body Detailing', 'count': 2, 'percent': 0.13},
        {'name': 'Coating Premium', 'count': 1, 'percent': 0.07},
        {'name': 'Full Detailing', 'count': 1, 'percent': 0.07},
      ];
    } else {
      serviceStats = _computeServiceStats();
    }

    // Riwayat bookings list
    final List<Map<String, dynamic>> recentHistory;
    if (isMock) {
      recentHistory = [
        {
          'date': '25 Jun 2026',
          'services': 'Wash & Wax + Engine Detailing',
          'price': 'Rp 125.000',
          'status': OrderStatus.selesai,
        },
        {
          'date': '18 Jun 2026',
          'services': 'Body Detailing',
          'price': 'Rp 100.000',
          'status': OrderStatus.selesai,
        },
        {
          'date': '10 Jun 2026',
          'services': 'Coating Premium',
          'price': 'Rp 150.000',
          'status': OrderStatus.ditolak,
        },
      ];
    } else {
      recentHistory = orders.reversed.map((o) {
        return {
          'date': o.tanggal,
          'services': o.layanan,
          'price': o.harga,
          'status': o.orderStatus,
        };
      }).toList();
    }

    return Scaffold(
      backgroundColor: _bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Detail Pelanggan",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Header card
                    _buildProfileHeader(tierColor, memberInfo, phone, plate, vehicle),
                    const SizedBox(height: 20),
                    // Summary Stats grid
                    _buildSummaryGrid(bookingsCount, totalSpent, averageSpent, lastActiveDate),
                    const SizedBox(height: 20),
                    // Service Statistics circular/linear listing
                    _buildServiceStatsCard(serviceStats),
                    const SizedBox(height: 20),
                    // Riwayat Terakhir
                    _buildRiwayatCard(recentHistory),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            // Bottom Quick Actions panel
            _buildBottomActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(Color tierColor, Map<String, dynamic> memberInfo, String phone, String plate, String vehicle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderDark),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: const Color(0xFF1E293B),
            child: Text(
              customer['nama'].toString().isNotEmpty ? customer['nama'][0].toUpperCase() : "P",
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 26),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            customer['nama'] as String,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: tierColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: tierColor.withOpacity(0.2), width: 0.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(memberInfo['icon'] as IconData, color: tierColor, size: 12),
                const SizedBox(width: 6),
                Text(
                  memberInfo['label'] as String,
                  style: TextStyle(
                    color: tierColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: const Color(0xFF1E293B)),
          const SizedBox(height: 16),
          // Contacts and Plate detail
          _buildInfoRow(Icons.phone_outlined, "Telepon", phone),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.two_wheeler_rounded, "Kendaraan", "$vehicle ($plate)"),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF94A3B8), size: 14),
        const SizedBox(width: 8),
        Text(
          "$label : ",
          style: TextStyle(color: _textSlate, fontSize: 11, fontWeight: FontWeight.w500),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryGrid(int bookingsCount, int totalSpent, int averageSpent, String lastActiveDate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Ringkasan",
          style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.8,
          children: [
            _buildGridStatItem("Total Pesanan", "$bookingsCount", const Color(0xFF3B82F6)),
            _buildGridStatItem("Total Belanja", _formatPrice(totalSpent), const Color(0xFF10B981)),
            _buildGridStatItem("Rata-rata Belanja", _formatPrice(averageSpent), const Color(0xFF8B5CF6)),
            _buildGridStatItem("Terakhir Order", lastActiveDate, const Color(0xFFF97316)),
          ],
        ),
      ],
    );
  }

  Widget _buildGridStatItem(String label, String value, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: TextStyle(color: _textSlate, fontSize: 10)),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceStatsCard(List<Map<String, dynamic>> serviceStats) {
    final colors = [
      const Color(0xFF3B82F6),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFFA855F7),
      const Color(0xFFEF4444),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Statistik Layanan",
            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (serviceStats.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  "Belum ada data statistik",
                  style: TextStyle(color: _textSlate, fontSize: 11),
                ),
              ),
            )
          else
            ...serviceStats.asMap().entries.map((entry) {
              final idx = entry.key;
              final item = entry.value;
              final color = colors[idx % colors.length];
              final count = item['count'] as int;
              final name = item['name'] as String;
              final percent = item['percent'] as double;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          "$count (${(percent * 100).toInt()}%)",
                          style: TextStyle(color: _textSlate, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: percent,
                        child: Container(
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildRiwayatCard(List<Map<String, dynamic>> recentHistory) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Riwayat Terakhir",
                style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
              ),
              Text(
                "Lihat semua",
                style: TextStyle(color: const Color(0xFF3B82F6), fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (recentHistory.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  "Belum ada riwayat booking",
                  style: TextStyle(color: _textSlate, fontSize: 11),
                ),
              ),
            )
          else
            ...recentHistory.map((item) {
              final status = item['status'] as OrderStatus;
              final color = _statusColor(status);
              final text = _statusText(status);

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF090D16),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _borderDark),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.local_car_wash, color: color, size: 16),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                item['date'] as String,
                                style: TextStyle(color: _textSlate, fontSize: 10),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  text,
                                  style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item['services'] as String,
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item['price'] as String,
                            style: const TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardDark,
        border: Border(top: BorderSide(color: _borderDark)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 44,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3B82F6),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
          child: const Text("Kembali", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ),
      ),
    );
  }
}
