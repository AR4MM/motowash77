import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'order_page.dart';
import 'customer_page.dart';
import 'service_page.dart';
import 'admin_profile_page.dart';
import '../models/order_model.dart';
import 'service_form_page.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});
  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _currentIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      AdminDashboardView(onNavigate: (index) {
        setState(() { _currentIndex = index; });
      }),
      const OrderPage(),
      const CustomerPage(),
      const ServicePage(),
      const AdminProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF1F2937), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            backgroundColor: Colors.transparent,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: const Color(0xFF3B82F6),
            unselectedItemColor: const Color(0xFF94A3B8),
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
            unselectedLabelStyle: const TextStyle(fontSize: 10),
            onTap: (index) {
              setState(() { _currentIndex = index; });
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: "Dashboard"),
              BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: "Pesanan"),
              BottomNavigationBarItem(icon: Icon(Icons.people_alt_rounded), label: "Pelanggan"),
              BottomNavigationBarItem(icon: Icon(Icons.local_car_wash_rounded), label: "Layanan"),
              BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings_rounded), label: "Admin"),
            ],
          ),
        ),
      ),
    );
  }
}

class AdminDashboardView extends StatefulWidget {
  final Function(int) onNavigate;
  const AdminDashboardView({required this.onNavigate, super.key});
  @override
  State<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView> {
  Timer? _refreshTimer;
  bool _isLoading = true;
  DateTime _selectedDate = DateTime(2026, 6, 25); // Default baseline matching screenshot
  int _selectedDateCardIndex = 0; // selected index in date list
  final String _selectedPeriod = "Mingguan";

  // Palette Constants
  final Color _bgDark = const Color(0xFF090D16);
  final Color _cardDark = const Color(0xFF111726);
  final Color _borderDark = const Color(0xFF1E293B);
  final Color _textSlate = const Color(0xFF94A3B8);

  @override
  void initState() {
    super.initState();
    _loadData();
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) => _loadData());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    await OrderData.fetchFromApi();
    if (mounted) setState(() => _isLoading = false);
  }

  DateTime? _parseDate(String dateStr) {
    final cleanStr = dateStr.trim();
    if (cleanStr.isEmpty) return null;

    // Format 1: d-M-yyyy (e.g. "25-6-2026")
    final partsDash = cleanStr.split('-');
    if (partsDash.length == 3) {
      final day = int.tryParse(partsDash[0]);
      final month = int.tryParse(partsDash[1]);
      final year = int.tryParse(partsDash[2]);
      if (day != null && month != null && year != null) {
        return DateTime(year, month, day);
      }
    }

    // Format 2: d MMMM yyyy (e.g. "25 Juni 2026")
    final partsSpace = cleanStr.split(' ');
    if (partsSpace.length == 3) {
      final day = int.tryParse(partsSpace[0]);
      final year = int.tryParse(partsSpace[2]);
      const monthNames = [
        'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
      ];
      final monthIdx = monthNames.indexOf(partsSpace[1]) + 1;
      if (day != null && monthIdx > 0 && year != null) {
        return DateTime(year, monthIdx, day);
      }
    }
    return null;
  }

  int _parseHarga(String hargaStr) {
    final clean = hargaStr.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(clean) ?? 0;
  }

  String _formatPrice(int price) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(price);
  }

  String _formatDateIndo(DateTime dt) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return "${dt.day} ${months[dt.month - 1]} ${dt.year}";
  }

  String _formatDateShort(DateTime dt) {
    const mStr = "Jun"; // default helper, but we dynamically display months below
    final mNames = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'];
    final mVal = (dt.month >= 1 && dt.month <= 12) ? mNames[dt.month - 1] : mStr;
    return "${dt.day} $mVal ${dt.year}";
  }

  // Check if there are no database entries in the app
  bool get _isDbEmpty => OrderData.orders.isEmpty;

  // --- STATS COMPUTATION ---
  int get _countMenunggu => OrderData.orders.where((o) => o.orderStatus == OrderStatus.menunggu).length;
  int get _countDiproses => OrderData.orders.where((o) => o.orderStatus == OrderStatus.diproses).length;
  int get _countSelesai => OrderData.orders.where((o) => o.isToday && o.orderStatus == OrderStatus.selesai).length;
  int get _countCancel => OrderData.orders.where((o) => o.orderStatus == OrderStatus.ditolak).length;
  int get _countTotalPelanggan => OrderData.orders.map((o) => o.nama.trim().toLowerCase()).toSet().length;

  int get _displayMenunggu => _isDbEmpty ? 8 : _countMenunggu;
  int get _displayDiproses => _isDbEmpty ? 3 : _countDiproses;
  int get _displaySelesai => _isDbEmpty ? 12 : _countSelesai;
  int get _displayCancel => _isDbEmpty ? 2 : _countCancel;
  int get _displayTotalPelanggan => _isDbEmpty ? 256 : _countTotalPelanggan;

  int get _todayRevenue {
    int total = 0;
    for (final o in OrderData.orders) {
      if ((o.status == 'Sudah Dibayar' || o.status == 'Selesai') && o.isToday) {
        total += _parseHarga(o.harga);
      }
    }
    return _isDbEmpty ? 1250000 : total;
  }

  int get _monthlyRevenue {
    final now = DateTime.now();
    int total = 0;
    for (final o in OrderData.orders) {
      if (o.status == 'Sudah Dibayar' || o.status == 'Selesai') {
        final dt = _parseDate(o.tanggal);
        if (dt != null && dt.month == now.month && dt.year == now.year) {
          total += _parseHarga(o.harga);
        }
      }
    }
    return _isDbEmpty ? 24750000 : total;
  }

  List<int> _computeWeeklyRevenue() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartDay = DateTime(weekStart.year, weekStart.month, weekStart.day);
    final daily = List.filled(7, 0);

    for (final o in OrderData.orders) {
      if (o.status != 'Sudah Dibayar' && o.status != 'Selesai') continue;
      final orderDate = _parseDate(o.tanggal);
      if (orderDate == null) continue;

      final diff = orderDate.difference(weekStartDay).inDays;
      if (diff >= 0 && diff < 7) {
        daily[diff] += _parseHarga(o.harga);
      }
    }
    return daily;
  }

  bool _isSameDate(String dateStr, DateTime target) {
    final dt = _parseDate(dateStr);
    if (dt == null) return false;
    return dt.day == target.day && dt.month == target.month && dt.year == target.year;
  }

  Map<String, int> _computeDateBreakdown(DateTime dt) {
    int total = 0;
    int m = 0;
    int p = 0;
    int s = 0;
    int d = 0;

    for (final o in OrderData.orders) {
      if (_isSameDate(o.tanggal, dt)) {
        total++;
        if (o.orderStatus == OrderStatus.menunggu) m++;
        else if (o.orderStatus == OrderStatus.diproses) p++;
        else if (o.orderStatus == OrderStatus.selesai) s++;
        else if (o.orderStatus == OrderStatus.ditolak) d++;
      }
    }
    return {
      'total': total,
      'm': m,
      'p': p,
      's': s,
      'd': d,
    };
  }

  List<OrderModel> get _upcomingSchedules {
    final list = OrderData.orders.where((o) => !o.isPast && o.orderStatus != OrderStatus.ditolak).toList();
    list.sort((a, b) {
      final da = _parseDate(a.tanggal);
      final db = _parseDate(b.tanggal);
      if (da != null && db != null) {
        int dateComp = da.compareTo(db);
        if (dateComp != 0) return dateComp;
      }
      return a.waktu.compareTo(b.waktu);
    });
    return list;
  }

  List<Map<String, dynamic>> _computeBusyDays() {
    final counts = {'Senin': 0, 'Selasa': 0, 'Rabu': 0, 'Kamis': 0, 'Jumat': 0, 'Sabtu': 0, 'Minggu': 0};

    for (final o in OrderData.orders) {
      final dt = _parseDate(o.tanggal);
      if (dt == null) continue;
      final weekdayName = _getWeekdayName(dt.weekday);
      counts[weekdayName] = (counts[weekdayName] ?? 0) + 1;
    }

    final list = counts.entries.map((e) => {'day': e.key, 'count': e.value, 'isTop': false}).toList();
    list.sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));

    if (list.isNotEmpty && (list.first['count'] as int) > 0) {
      list.first['isTop'] = true;
    }

    return list.take(5).toList();
  }

  String _getWeekdayName(int weekday) {
    switch (weekday) {
      case 1: return 'Senin';
      case 2: return 'Selasa';
      case 3: return 'Rabu';
      case 4: return 'Kamis';
      case 5: return 'Jumat';
      case 6: return 'Sabtu';
      case 7: return 'Minggu';
      default: return '';
    }
  }

  List<OrderModel> get _cancelledOrdersToday {
    return OrderData.orders.where((o) => o.isToday && o.orderStatus == OrderStatus.ditolak).toList();
  }

  List<Map<String, dynamic>> _computeBestSellers() {
    final counts = <String, int>{};
    for (final o in OrderData.orders) {
      final services = o.layanan.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty);
      for (final s in services) {
        counts[s] = (counts[s] ?? 0) + 1;
      }
    }
    final sorted = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return sorted.map((e) => {'name': e.key, 'count': e.value}).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: _bgDark,
        body: const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6))),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF3B82F6),
      onRefresh: _loadData,
      child: Scaffold(
        backgroundColor: _bgDark,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                _buildHeader(context),
                const SizedBox(height: 16),
                _buildMetricsCarousel(),
                const SizedBox(height: 24),
                _buildRevenueChartCard(),
                const SizedBox(height: 24),
                _buildDatePaginationSection(),
                const SizedBox(height: 24),
                _buildSchedulesSection(),
                const SizedBox(height: 24),
                _buildBusyDaysCard(),
                const SizedBox(height: 24),
                _buildCancelledOrdersCard(),
                const SizedBox(height: 24),
                _buildBestSellersCard(),
                const SizedBox(height: 100), // Spacing for bottom navbar
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Selamat datang kembali, Admin! 👋",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Kelola operasional MotoWash77 dengan mudah dan efisien.",
                      style: TextStyle(
                        color: _textSlate,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: [
                  _buildHeaderIconButton(Icons.search, () {}),
                  const SizedBox(width: 8),
                  _buildHeaderIconButton(
                    Icons.notifications_none_outlined,
                    () => widget.onNavigate(1),
                    badgeCount: 3,
                  ),
                  const SizedBox(width: 8),
                  _buildHeaderIconButton(Icons.settings_outlined, () {
                    widget.onNavigate(4);
                  }),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2025),
                lastDate: DateTime(2030),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.dark(
                        primary: Color(0xFF3B82F6),
                        onPrimary: Colors.white,
                        surface: Color(0xFF111726),
                        onSurface: Colors.white,
                      ),
                      dialogBackgroundColor: const Color(0xFF090D16),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                setState(() {
                  _selectedDate = picked;
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B).withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1E293B)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_today_outlined, color: Color(0xFF3B82F6), size: 14),
                  const SizedBox(width: 8),
                  Text(
                    _formatDateIndo(_selectedDate),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.keyboard_arrow_down, color: Colors.white60, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderIconButton(IconData icon, VoidCallback onTap, {int badgeCount = 0}) {
    return Stack(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B).withOpacity(0.5),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF1E293B)),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
        ),
        if (badgeCount > 0)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Color(0xFFEF4444),
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 14,
                minHeight: 14,
              ),
              child: Text(
                '$badgeCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 7,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMetricsCarousel() {
    final items = [
      {
        'title': 'Menunggu',
        'value': '$_displayMenunggu',
        'trend': '↓ 12% dari kemarin',
        'trendUp': false,
        'icon': Icons.hourglass_empty_rounded,
        'color': const Color(0xFFF97316),
      },
      {
        'title': 'Diproses',
        'value': '$_displayDiproses',
        'trend': '↑ 8% dari kemarin',
        'trendUp': true,
        'icon': Icons.settings_rounded,
        'color': const Color(0xFF3B82F6),
      },
      {
        'title': 'Selesai Hari Ini',
        'value': '$_displaySelesai',
        'trend': '↑ 16% dari kemarin',
        'trendUp': true,
        'icon': Icons.check_circle_rounded,
        'color': const Color(0xFF10B981),
      },
      {
        'title': 'Dibatalkan',
        'value': '$_displayCancel',
        'trend': '↓ 4% dari kemarin',
        'trendUp': false,
        'icon': Icons.cancel_rounded,
        'color': const Color(0xFFEF4444),
      },
      {
        'title': 'Total Pelanggan',
        'value': '$_displayTotalPelanggan',
        'trend': '↑ 18% bulan ini',
        'trendUp': true,
        'icon': Icons.people_alt_rounded,
        'color': const Color(0xFF8B5CF6),
      },
    ];

    return SizedBox(
      height: 124,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final Color iconColor = item['color'] as Color;
          final bool isTrendUp = item['trendUp'] as bool;
          return Container(
            width: 150,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _cardDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _borderDark),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(item['icon'] as IconData, color: iconColor, size: 16),
                    ),
                    Text(
                      item['value'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title'] as String,
                      style: TextStyle(
                        color: _textSlate,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['trend'] as String,
                      style: TextStyle(
                        color: isTrendUp ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRevenueChartCard() {
    final weekly = _computeWeeklyRevenue();
    final useMock = weekly.fold(0, (sum, val) => sum + val) == 0;
    final chartValues = useMock
        ? [1100000, 950000, 1250000, 1400000, 1600000, 1850000, 1250000]
        : weekly;

    final List<FlSpot> spots = [];
    for (int i = 0; i < chartValues.length; i++) {
      spots.add(FlSpot(i.toDouble(), chartValues[i].toDouble()));
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Pendapatan",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Ringkasan pendapatan",
                    style: TextStyle(
                      color: _textSlate,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF1E293B)),
                ),
                child: Row(
                  children: [
                    Text(
                      _selectedPeriod,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down, color: Colors.white60, size: 14),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hari Ini",
                      style: TextStyle(color: _textSlate, fontSize: 10),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatPrice(_todayRevenue),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Row(
                      children: [
                        Icon(Icons.arrow_upward, color: Color(0xFF10B981), size: 10),
                        SizedBox(width: 2),
                        Text(
                          "14% dari kemarin",
                          style: TextStyle(
                            color: Color(0xFF10B981),
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 40, color: const Color(0xFF1E293B)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Bulan Ini",
                      style: TextStyle(color: _textSlate, fontSize: 10),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatPrice(_monthlyRevenue),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Row(
                      children: [
                        Icon(Icons.arrow_upward, color: Color(0xFF10B981), size: 10),
                        SizedBox(width: 2),
                        Text(
                          "22% dari bulan lalu",
                          style: TextStyle(
                            color: Color(0xFF10B981),
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: 2000000,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 500000,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: const Color(0xFF1E293B).withOpacity(0.4),
                      strokeWidth: 1,
                      dashArray: [4, 4],
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (value, meta) {
                        final days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
                        if (value >= 0 && value < 7) {
                          return SideTitleWidget(
                            meta: meta,
                            space: 6,
                            child: Text(
                              days[value.toInt()],
                              style: TextStyle(
                                color: _textSlate,
                                fontWeight: FontWeight.bold,
                                fontSize: 9,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 500000,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) {
                        String label = '';
                        if (value == 0) label = '0';
                        else if (value == 500000) label = '500K';
                        else if (value == 1000000) label = '1M';
                        else if (value == 1500000) label = '1.5M';
                        else if (value == 2000000) label = '2M';
                        return SideTitleWidget(
                          meta: meta,
                          space: 4,
                          child: Text(
                            label,
                            style: TextStyle(
                              color: _textSlate,
                              fontWeight: FontWeight.bold,
                              fontSize: 9,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) => const Color(0xFF1E293B),
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final daysFull = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
                        final dayName = daysFull[spot.x.toInt()];
                        final amount = spot.y.toInt();
                        return LineTooltipItem(
                          '$dayName\n${_formatPrice(amount)}',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    preventCurveOverShooting: true,
                    barWidth: 3,
                    color: const Color(0xFF3B82F6),
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                        radius: 3.5,
                        color: const Color(0xFF3B82F6),
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF3B82F6).withOpacity(0.25),
                          const Color(0xFF3B82F6).withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
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

  Widget _buildDatePaginationSection() {
    final now = DateTime(2026, 6, 25);
    final daysList = List.generate(5, (index) => now.add(Duration(days: index)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Pesanan per Tanggal",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Ringkasan pesanan berdasarkan tanggal",
                    style: TextStyle(
                      color: _textSlate,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  _buildNavButton(Icons.chevron_left, () {
                    if (_selectedDateCardIndex > 0) {
                      setState(() {
                        _selectedDateCardIndex--;
                      });
                    }
                  }),
                  const SizedBox(width: 8),
                  _buildNavButton(Icons.chevron_right, () {
                    if (_selectedDateCardIndex < 4) {
                      setState(() {
                        _selectedDateCardIndex++;
                      });
                    }
                  }),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 145,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: daysList.length,
            itemBuilder: (context, index) {
              final dt = daysList[index];
              final isToday = index == 0;
              final isSelected = index == _selectedDateCardIndex;

              final Map<String, int> breakdown;
              if (_isDbEmpty) {
                final mockBreakdowns = [
                  {'total': 12, 'm': 8, 'p': 3, 's': 1, 'd': 0},
                  {'total': 15, 'm': 9, 'p': 4, 's': 2, 'd': 0},
                  {'total': 18, 'm': 11, 'p': 5, 's': 2, 'd': 0},
                  {'total': 22, 'm': 14, 'p': 6, 's': 2, 'd': 0},
                  {'total': 10, 'm': 6, 'p': 3, 's': 1, 'd': 0},
                ];
                breakdown = mockBreakdowns[index % mockBreakdowns.length];
              } else {
                breakdown = _computeDateBreakdown(dt);
              }

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDateCardIndex = index;
                  });
                },
                child: Container(
                  width: 170,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF1E293B).withOpacity(0.4) : _cardDark,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF3B82F6) : _borderDark,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFF3B82F6).withOpacity(0.15),
                              blurRadius: 10,
                              spreadRadius: 1,
                            )
                          ]
                        : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isToday ? "Hari Ini" : "",
                            style: const TextStyle(
                              color: Color(0xFF3B82F6),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _formatDateShort(dt),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        "${breakdown['total']} pesanan",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Column(
                        children: [
                          _buildDateBreakdownRow("Menunggu", breakdown['m']!, const Color(0xFFF97316)),
                          const SizedBox(height: 2),
                          _buildDateBreakdownRow("Diproses", breakdown['p']!, const Color(0xFF3B82F6)),
                          const SizedBox(height: 2),
                          _buildDateBreakdownRow("Selesai", breakdown['s']!, const Color(0xFF10B981)),
                          const SizedBox(height: 2),
                          _buildDateBreakdownRow("Dibatalkan", breakdown['d']!, const Color(0xFFEF4444)),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNavButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B).withOpacity(0.5),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF1E293B)),
        ),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }

  Widget _buildDateBreakdownRow(String label, int count, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: _textSlate,
                fontSize: 9,
              ),
            ),
          ],
        ),
        Text(
          "$count",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSchedulesSection() {
    final List<Map<String, dynamic>> schedules;
    if (_isDbEmpty) {
      schedules = [
        {'time': '08:00', 'name': 'Deri Saputra', 'service': 'Wash & Wax', 'status': 'Menunggu', 'color': const Color(0xFFF97316)},
        {'time': '09:30', 'name': 'Ilham Maulana', 'service': 'Body Detailing', 'status': 'Diproses', 'color': const Color(0xFF3B82F6)},
        {'time': '11:00', 'name': 'Fauzi', 'service': 'Engine Detailing', 'status': 'Diproses', 'color': const Color(0xFF3B82F6)},
        {'time': '13:00', 'name': 'Aldi Kurniawan', 'service': 'Wash & Wax', 'status': 'Menunggu', 'color': const Color(0xFFF97316)},
        {'time': '15:00', 'name': 'Rizki Maulana', 'service': 'Full Detailing', 'status': 'Diproses', 'color': const Color(0xFF3B82F6)},
        {'time': '17:00', 'name': 'Andi Setiawan', 'service': 'Coating Premium', 'status': 'Selesai', 'color': const Color(0xFF10B981)},
      ];
    } else {
      schedules = _upcomingSchedules.map((o) {
        Color statusColor;
        String statusText;
        switch (o.orderStatus) {
          case OrderStatus.menunggu:
            statusColor = const Color(0xFFF97316);
            statusText = "Menunggu";
            break;
          case OrderStatus.diproses:
            statusColor = const Color(0xFF3B82F6);
            statusText = "Diproses";
            break;
          case OrderStatus.selesai:
            statusColor = const Color(0xFF10B981);
            statusText = "Selesai";
            break;
          case OrderStatus.ditolak:
            statusColor = const Color(0xFFEF4444);
            statusText = "Dibatalkan";
            break;
        }
        return {
          'time': o.waktu,
          'name': o.nama,
          'service': o.layanan,
          'status': statusText,
          'color': statusColor,
        };
      }).toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.access_time_filled, color: Color(0xFF3B82F6), size: 16),
                  const SizedBox(width: 8),
                  const Text(
                    "Jadwal Kedatangan",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => widget.onNavigate(1),
                child: const Text(
                  "Lihat semua",
                  style: TextStyle(
                    color: Color(0xFF3B82F6),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        schedules.isEmpty
            ? Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(vertical: 24),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _cardDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _borderDark),
                ),
                child: Column(
                  children: [
                    Icon(Icons.calendar_today_outlined, color: _textSlate.withOpacity(0.5), size: 28),
                    const SizedBox(height: 8),
                    Text(
                      "Tidak ada jadwal hari ini",
                      style: TextStyle(color: _textSlate, fontSize: 11),
                    ),
                  ],
                ),
              )
            : SizedBox(
                height: 104,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: schedules.length,
                  itemBuilder: (context, index) {
                    final s = schedules[index];
                    final statusColor = s['color'] as Color;

                    return Container(
                      width: 170,
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _cardDark,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _borderDark),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.circle, color: Color(0xFFF97316), size: 6),
                                  const SizedBox(width: 4),
                                  Text(
                                    s['time'] as String,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: statusColor.withOpacity(0.3), width: 0.5),
                                ),
                                child: Text(
                                  s['status'] as String,
                                  style: TextStyle(
                                    color: statusColor,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s['name'] as String,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                s['service'] as String,
                                style: TextStyle(
                                  color: _textSlate,
                                  fontSize: 10,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
      ],
    );
  }

  Widget _buildBusyDaysCard() {
    final List<Map<String, dynamic>> busyDays;
    if (_isDbEmpty) {
      busyDays = [
        {'day': 'Sabtu', 'count': 28, 'isTop': true},
        {'day': 'Minggu', 'count': 22, 'isTop': false},
        {'day': 'Jumat', 'count': 18, 'isTop': false},
        {'day': 'Rabu', 'count': 15, 'isTop': false},
        {'day': 'Selasa', 'count': 12, 'isTop': false},
      ];
    } else {
      busyDays = _computeBusyDays();
    }

    final maxCount = busyDays.isEmpty ? 1 : busyDays.map((e) => e['count'] as int).reduce((a, b) => a > b ? a : b);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
            children: [
              const Icon(Icons.calendar_month_outlined, color: Color(0xFF3B82F6), size: 16),
              const SizedBox(width: 8),
              const Text(
                "Hari Paling Rame",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Padding(
            padding: const EdgeInsets.only(left: 24.0),
            child: Text(
              "Berdasarkan jumlah pesanan",
              style: TextStyle(color: _textSlate, fontSize: 11),
            ),
          ),
          const SizedBox(height: 16),
          if (busyDays.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  "Belum ada data pesanan",
                  style: TextStyle(color: _textSlate, fontSize: 11),
                ),
              ),
            )
          else
            ...busyDays.map((item) {
              final day = item['day'] as String;
              final count = item['count'] as int;
              final isTop = item['isTop'] as bool;
              final percent = maxCount > 0 ? (count / maxCount) : 0.0;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 70,
                      child: Row(
                        children: [
                          if (isTop)
                            const Padding(
                              padding: EdgeInsets.only(right: 4.0),
                              child: Icon(Icons.star, color: Colors.amber, size: 12),
                            )
                          else
                            const SizedBox(width: 16),
                          Text(
                            day,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: percent,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 65,
                      child: Text(
                        "$count pesanan",
                        style: TextStyle(
                          color: _textSlate,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.end,
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

  Widget _buildCancelledOrdersCard() {
    final List<Map<String, String>> displayList;
    if (_isDbEmpty) {
      displayList = [
        {
          'name': 'Deri Saputra',
          'time': '10:30 WIB',
          'service': 'Wash & Wax',
          'reason': 'Alasan: Tidak jadi datang'
        },
        {
          'name': 'Rizki Maulana',
          'time': '14:15 WIB',
          'service': 'Body Detailing',
          'reason': 'Alasan: Salah pilih jadwal'
        },
      ];
    } else {
      displayList = _cancelledOrdersToday.map((o) => {
        'name': o.nama,
        'time': '${o.waktu} WIB',
        'service': o.layanan,
        'reason': 'Alasan: Dibatalkan oleh admin/pelanggan'
      }).toList();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
              Row(
                children: [
                  const Icon(Icons.cancel_outlined, color: Color(0xFFEF4444), size: 16),
                  const SizedBox(width: 8),
                  const Text(
                    "Pesanan Dibatalkan Hari Ini",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => widget.onNavigate(1),
                child: const Text(
                  "Lihat semua",
                  style: TextStyle(
                    color: Color(0xFF3B82F6),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (displayList.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  Icon(Icons.check_circle_outline, color: Colors.green.withOpacity(0.5), size: 36),
                  const SizedBox(height: 8),
                  Text(
                    "Tidak ada pesanan dibatalkan hari ini",
                    style: TextStyle(color: _textSlate, fontSize: 11),
                  ),
                ],
              ),
            )
          else
            ...displayList.map((item) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F1A24),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person_outline, color: Color(0xFFEF4444), size: 16),
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
                                item['name'] as String,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                item['time'] as String,
                                style: TextStyle(
                                  color: _textSlate,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item['service'] as String,
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item['reason'] as String,
                            style: const TextStyle(
                              color: Color(0xFFEF4444),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        "Dibatalkan",
                        style: TextStyle(
                          color: Color(0xFFEF4444),
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildBestSellersCard() {
    final List<Map<String, dynamic>> bestSellers;
    if (_isDbEmpty) {
      bestSellers = [
        {'name': 'Wash & Wax', 'count': 125},
        {'name': 'Body Detailing', 'count': 78},
        {'name': 'Engine Detailing', 'count': 56},
        {'name': 'Full Detailing', 'count': 34},
        {'name': 'Coating Premium', 'count': 18},
      ];
    } else {
      bestSellers = _computeBestSellers();
    }

    final maxCount = bestSellers.isEmpty ? 1 : bestSellers.first['count'] as int;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
              Row(
                children: [
                  const Icon(Icons.local_car_wash_outlined, color: Color(0xFF3B82F6), size: 16),
                  const SizedBox(width: 8),
                  const Text(
                    "Layanan Terlaris",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF1E293B)),
                ),
                child: const Row(
                  children: [
                    Text(
                      "Bulan Ini",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down, color: Colors.white60, size: 12),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (bestSellers.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  "Belum ada data pesanan",
                  style: TextStyle(color: _textSlate, fontSize: 11),
                ),
              ),
            )
          else
            ...bestSellers.asMap().entries.map((entry) {
              final idx = entry.key + 1;
              final item = entry.value;
              final count = item['count'] as int;
              final name = item['name'] as String;
              final percent = maxCount > 0 ? (count / maxCount) : 0.0;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      child: Text(
                        "$idx",
                        style: TextStyle(
                          color: _textSlate,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                "${count}x",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
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
                                  color: const Color(0xFF3B82F6),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }
}
