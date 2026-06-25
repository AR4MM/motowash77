import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import '../models/order_model.dart';
import '../src/file_image_helper.dart' as file_image_helper;

// ─────────────────────────────────────────────────────────────────────────────
//  OrderPage — Redesigned Admin Orders Page (Dark Theme & Mobile Friendly)
// ─────────────────────────────────────────────────────────────────────────────

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  Timer? _refreshTimer;
  bool _isLoading = true;

  // Filter States
  String _searchQuery = "";
  int _selectedStatusIndex = 0; // 0: Semua, 1: Menunggu, 2: Diproses, 3: Selesai, 4: Dibatalkan
  int _selectedDateIndex = 0; // 0: 25 Jun, 1: 26 Jun, etc.
  DateTime _selectedDate = DateTime(2026, 6, 25); // custom date fallback

  // Local Order List (to support in-memory session updates for demo fallback)
  List<OrderModel> _localOrders = [];

  // Theme Constants
  final Color _bgDark = const Color(0xFF090D16);
  final Color _cardDark = const Color(0xFF111726);
  final Color _borderDark = const Color(0xFF1E293B);
  final Color _textSlate = const Color(0xFF94A3B8);

  @override
  void initState() {
    super.initState();
    _loadOrders();
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) => _loadOrders());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    await OrderData.fetchFromApi();
    if (mounted) {
      setState(() {
        if (OrderData.orders.isNotEmpty) {
          _localOrders = List.from(OrderData.orders);
        } else {
          // Fallback to mock only if database is completely empty (no sync history)
          if (_localOrders.isEmpty) {
            _localOrders = _generateMockOrders();
          }
        }
        _isLoading = false;
      });
    }
  }

  int _resolveServicePrice(String serviceName) {
    final clean = serviceName.trim().toLowerCase();
    if (clean.contains("wash") && clean.contains("wax")) return 25000;
    if (clean.contains("body") && clean.contains("detail")) return 50000;
    if (clean.contains("engine") && clean.contains("detail")) return 100000;
    if (clean.contains("full") && clean.contains("detail")) return 150000;
    if (clean.contains("coating") || clean.contains("premium")) return 150000;
    return 25000; // default/fallback
  }

  String _formatPrice(int price) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(price);
  }

  String _formatDateShort(DateTime dt) {
    final mStr = (dt.month == 6) ? "Jun" : (dt.month == 7 ? "Jul" : "Agt");
    return "${dt.day} $mStr ${dt.year}";
  }

  String _formatDateIndo(DateTime dt) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return "${dt.day} ${months[dt.month - 1]} ${dt.year}";
  }

  bool _isSameDate(String dateStr, DateTime target) {
    final cleanStr = dateStr.trim();
    if (cleanStr.isEmpty) return false;

    // Parse format: "25-6-2026"
    final partsDash = cleanStr.split('-');
    if (partsDash.length == 3) {
      final day = int.tryParse(partsDash[0]);
      final month = int.tryParse(partsDash[1]);
      final year = int.tryParse(partsDash[2]);
      return day == target.day && month == target.month && year == target.year;
    }

    // Parse format: "25 Juni 2026"
    final partsSpace = cleanStr.split(' ');
    if (partsSpace.length == 3) {
      final day = int.tryParse(partsSpace[0]);
      final year = int.tryParse(partsSpace[2]);
      const monthNames = [
        'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
      ];
      final monthIdx = monthNames.indexOf(partsSpace[1]) + 1;
      return day == target.day && monthIdx == target.month && year == target.year;
    }

    return false;
  }

  // --- STATS COMPUTATION ---
  int get _countAll => _localOrders.length;
  int get _countMenunggu => _localOrders.where((o) => o.orderStatus == OrderStatus.menunggu).length;
  int get _countDiproses => _localOrders.where((o) => o.orderStatus == OrderStatus.diproses).length;
  int get _countSelesai => _localOrders.where((o) => o.orderStatus == OrderStatus.selesai).length;
  int get _countDibatalkan => _localOrders.where((o) => o.orderStatus == OrderStatus.ditolak).length;

  int get _displayAll => _countAll;
  int get _displayMenunggu => _countMenunggu;
  int get _displayDiproses => _countDiproses;
  int get _displaySelesai => _countSelesai;
  int get _displayDibatalkan => _countDibatalkan;

  // --- GET FILTERED ORDERS ---
  List<OrderModel> _getFilteredOrders() {
    List<OrderModel> list = _localOrders;

    // 1. Filter by status
    if (_selectedStatusIndex == 1) {
      list = list.where((o) => o.orderStatus == OrderStatus.menunggu).toList();
    } else if (_selectedStatusIndex == 2) {
      list = list.where((o) => o.orderStatus == OrderStatus.diproses).toList();
    } else if (_selectedStatusIndex == 3) {
      list = list.where((o) => o.orderStatus == OrderStatus.selesai).toList();
    } else if (_selectedStatusIndex == 4) {
      list = list.where((o) => o.orderStatus == OrderStatus.ditolak).toList();
    }

    // 2. Filter by date slider
    final baselineDate = DateTime(2026, 6, 25);
    final daysList = List.generate(5, (index) => baselineDate.add(Duration(days: index)));

    if (_selectedDateIndex >= 0 && _selectedDateIndex < 5) {
      final targetDate = daysList[_selectedDateIndex];
      list = list.where((o) => _isSameDate(o.tanggal, targetDate)).toList();
    } else if (_selectedDateIndex == 5) {
      list = list.where((o) => _isSameDate(o.tanggal, _selectedDate)).toList();
    }

    // 3. Filter by search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      list = list.where((o) {
        return o.invoice.toLowerCase().contains(query) ||
            o.nama.toLowerCase().contains(query) ||
            o.noPolisi.toLowerCase().contains(query) ||
            o.layanan.toLowerCase().contains(query);
      }).toList();
    }

    // Sort: newest time first
    list.sort((a, b) => b.waktu.compareTo(a.waktu));
    return list;
  }

  void _changeOrderStatus(OrderModel order, OrderStatus newStatus) async {
    HapticFeedback.mediumImpact();
    setState(() {
      order.orderStatus = newStatus;
    });

    // If matches DB cache, sync it
    final dbIndex = OrderData.orders.indexWhere((o) => o.invoice == order.invoice);
    if (dbIndex != -1) {
      OrderData.orders[dbIndex].orderStatus = newStatus;
      await OrderData.saveOrders();
      await OrderData.updateStatusInApi(order.invoice, order.status);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredOrders = _getFilteredOrders();

    return Scaffold(
      backgroundColor: _bgDark,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            _buildHeader(context),
            const SizedBox(height: 16),
            _buildStatusMetricsRow(),
            const SizedBox(height: 16),
            _buildHorizontalDateSlider(context),
            const SizedBox(height: 12),
            // Orders List
            Expanded(
              child: filteredOrders.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      color: const Color(0xFF3B82F6),
                      backgroundColor: _cardDark,
                      onRefresh: _loadOrders,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                        itemCount: filteredOrders.length,
                        itemBuilder: (context, index) {
                          return _buildOrderCard(filteredOrders[index]);
                        },
                      ),
                    ),
            ),
          ],
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
                      "Pesanan",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Kelola semua pesanan dan pantau statusnya dengan mudah.",
                      style: TextStyle(
                        color: _textSlate,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              _buildHeaderIconButton(Icons.notifications_none_outlined, () {
                // simple action
              }, badgeCount: 3),
            ],
          ),
          const SizedBox(height: 16),
          // Search & Filter controls
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: _cardDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _borderDark),
                  ),
                  child: TextField(
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8), size: 18),
                      hintText: "Cari pesanan, nama, no polisi...",
                      hintStyle: TextStyle(color: _textSlate.withOpacity(0.6), fontSize: 13),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Filter Button
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: _cardDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _borderDark),
                ),
                child: IconButton(
                  icon: const Icon(Icons.tune_rounded, color: Colors.white, size: 18),
                  onPressed: () {
                    // Quick clear filters
                    setState(() {
                      _searchQuery = "";
                      _selectedStatusIndex = 0;
                      _selectedDateIndex = 0;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Filter dibersihkan"),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              ),
            ],
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

  Widget _buildStatusMetricsRow() {
    final filters = [
      {'label': 'Semua', 'count': _displayAll, 'color': const Color(0xFF3B82F6), 'icon': Icons.layers_outlined},
      {'label': 'Menunggu', 'count': _displayMenunggu, 'color': const Color(0xFFF97316), 'icon': Icons.hourglass_empty_rounded},
      {'label': 'Diproses', 'count': _displayDiproses, 'color': const Color(0xFF3B82F6), 'icon': Icons.settings_rounded},
      {'label': 'Selesai', 'count': _displaySelesai, 'color': const Color(0xFF10B981), 'icon': Icons.check_circle_rounded},
      {'label': 'Dibatalkan', 'count': _displayDibatalkan, 'color': const Color(0xFFEF4444), 'icon': Icons.cancel_rounded},
    ];

    return SizedBox(
      height: 75,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final f = filters[index];
          final isSelected = index == _selectedStatusIndex;
          final color = f['color'] as Color;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedStatusIndex = index;
              });
            },
            child: Container(
              width: 110,
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? color.withOpacity(0.12) : _cardDark,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? color : _borderDark,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(f['icon'] as IconData, color: isSelected ? color : _textSlate, size: 14),
                      Text(
                        "${f['count']}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    f['label'] as String,
                    style: TextStyle(
                      color: isSelected ? Colors.white : _textSlate,
                      fontSize: 10,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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

  Widget _buildHorizontalDateSlider(BuildContext context) {
    final now = DateTime(2026, 6, 25);
    final daysList = List.generate(5, (index) => now.add(Duration(days: index)));

    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: daysList.length + 1, // +1 for "Pilih Tanggal"
        itemBuilder: (context, index) {
          if (index == daysList.length) {
            // "Pilih Tanggal" button
            final isCustomSelected = _selectedDateIndex == 5;
            return GestureDetector(
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
                    _selectedDateIndex = 5;
                  });
                }
              },
              child: Container(
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: isCustomSelected ? const Color(0xFF3B82F6).withOpacity(0.12) : _cardDark,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isCustomSelected ? const Color(0xFF3B82F6) : _borderDark),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_month, color: isCustomSelected ? const Color(0xFF3B82F6) : Colors.white70, size: 13),
                    const SizedBox(width: 6),
                    Text(
                      isCustomSelected ? _formatDateShort(_selectedDate) : "Pilih Tanggal",
                      style: TextStyle(
                        color: isCustomSelected ? Colors.white : Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final dt = daysList[index];
          final isSelected = index == _selectedDateIndex;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDateIndex = index;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF3B82F6).withOpacity(0.15) : _cardDark,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? const Color(0xFF3B82F6) : _borderDark,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Center(
                child: Text(
                  _formatDateShort(dt),
                  style: TextStyle(
                    color: isSelected ? Colors.white : _textSlate,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (order.orderStatus) {
      case OrderStatus.menunggu:
        statusColor = const Color(0xFFF97316);
        statusText = "Menunggu";
        statusIcon = Icons.hourglass_empty_rounded;
        break;
      case OrderStatus.diproses:
        statusColor = const Color(0xFF3B82F6);
        statusText = "Diproses";
        statusIcon = Icons.settings_rounded;
        break;
      case OrderStatus.selesai:
        statusColor = const Color(0xFF10B981);
        statusText = "Selesai";
        statusIcon = Icons.check_circle_rounded;
        break;
      case OrderStatus.ditolak:
        statusColor = const Color(0xFFEF4444);
        statusText = "Dibatalkan";
        statusIcon = Icons.cancel_rounded;
        break;
    }

    final servicesList = order.layanan.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    final primaryService = servicesList.first;
    final otherCount = servicesList.length - 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderDark),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => _showOrderDetailSheet(context, order),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Time, invoice & status badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          order.waktu,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 1,
                          height: 12,
                          color: const Color(0xFF1E293B),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "#${order.invoice}",
                          style: TextStyle(
                            color: _textSlate,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: statusColor.withOpacity(0.3), width: 0.5),
                      ),
                      child: Row(
                        children: [
                          Icon(statusIcon, color: statusColor, size: 10),
                          const SizedBox(width: 4),
                          Text(
                            statusText,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Customer Name, Plate and Phone
                Text(
                  order.nama,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.phone_outlined, color: Color(0xFF94A3B8), size: 11),
                    const SizedBox(width: 4),
                    Text(
                      order.nama.toLowerCase().contains("deri") ? "0812-3456-7890" : "0813-9876-5432",
                      style: TextStyle(color: _textSlate, fontSize: 10),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.badge_outlined, color: Color(0xFF94A3B8), size: 11),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        order.noPolisi.isEmpty ? "B 1234 KZX" : order.noPolisi,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Divider
                Container(height: 1, color: const Color(0xFF1E293B)),
                const SizedBox(height: 12),
                // Services and Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            primaryService,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (otherCount > 0)
                            Padding(
                              padding: const EdgeInsets.only(top: 2.0),
                              child: Text(
                                "+ $otherCount layanan lainnya",
                                style: TextStyle(
                                  color: _textSlate,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          order.harga,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.keyboard_arrow_right, color: Colors.white30, size: 16),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 48, color: _textSlate.withOpacity(0.5)),
          const SizedBox(height: 12),
          Text(
            "Tidak ada pesanan di filter ini",
            style: TextStyle(color: _textSlate, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // --- INTERACTIVE MODAL DETAIL SHEET ---
  void _showOrderDetailSheet(BuildContext context, OrderModel order) {
    Color statusColor;
    String statusText;
    switch (order.orderStatus) {
      case OrderStatus.menunggu:
        statusColor = const Color(0xFFF97316);
        statusText = "Menunggu Konfirmasi";
        break;
      case OrderStatus.diproses:
        statusColor = const Color(0xFF3B82F6);
        statusText = "Sedang Dikerjakan";
        break;
      case OrderStatus.selesai:
        statusColor = const Color(0xFF10B981);
        statusText = "Selesai Dikerjakan";
        break;
      case OrderStatus.ditolak:
        statusColor = const Color(0xFFEF4444);
        statusText = "Dibatalkan";
        break;
    }

    final servicesList = order.layanan.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    int subtotal = 0;
    for (var s in servicesList) {
      subtotal += _resolveServicePrice(s);
    }
    int diskon = subtotal > 25000 ? 10000 : 0;
    int total = subtotal - diskon;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.85,
              maxChildSize: 0.95,
              minChildSize: 0.5,
              expand: false,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF090D16),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Column(
                    children: [
                      // Scrollable content
                      Expanded(
                        child: ListView(
                          controller: scrollController,
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          children: [
                            // Drag handle
                            Center(
                              child: Container(
                                margin: const EdgeInsets.only(top: 4, bottom: 12),
                                width: 40,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.white24,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                            // Header Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "#${order.invoice}",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        statusText,
                                        style: TextStyle(
                                          color: statusColor,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                // Cetak Button
                                GestureDetector(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Mencetak Struk Hub..."),
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF3B82F6).withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: const Color(0xFF3B82F6), width: 1),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.print, color: Color(0xFF3B82F6), size: 14),
                                        SizedBox(width: 6),
                                        Text(
                                          "Cetak",
                                          style: TextStyle(
                                            color: Color(0xFF3B82F6),
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // Customer Info Section
                            _buildSheetSectionHeader("👤 Informasi Pelanggan"),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: _cardDark,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: _borderDark),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: const Color(0xFF1E293B),
                                    child: Text(
                                      order.nama.isNotEmpty ? order.nama[0] : "A",
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          order.nama,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          order.nama.toLowerCase().contains("deri") ? "0812-3456-7890" : "0813-9876-5432",
                                          style: TextStyle(color: _textSlate, fontSize: 11),
                                        ),
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            const Icon(Icons.two_wheeler, color: Colors.white54, size: 12),
                                            const SizedBox(width: 4),
                                            Text(
                                              "${order.tipeMotor} ( ${order.noPolisi} )",
                                              style: TextStyle(color: _textSlate, fontSize: 10),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Chat / Call buttons
                                  Row(
                                    children: [
                                      _buildSheetIconButton(Icons.message_outlined, () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text("Membuka chat WhatsApp..."), duration: Duration(seconds: 1)),
                                        );
                                      }),
                                      const SizedBox(width: 8),
                                      _buildSheetIconButton(Icons.phone_outlined, () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text("Melakukan panggilan..."), duration: Duration(seconds: 1)),
                                        );
                                      }),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Layanan List Section
                            _buildSheetSectionHeader("🚿 Layanan"),
                            const SizedBox(height: 10),
                            ...servicesList.map((service) {
                              final price = _resolveServicePrice(service);
                              String desc = "Pencucian premium terintegrasi";
                              if (service.toLowerCase().contains("wash")) desc = "Cuci menyeluruh + wax premium";
                              else if (service.toLowerCase().contains("body")) desc = "Pembersihan mendalam body motor";
                              else if (service.toLowerCase().contains("engine")) desc = "Pembersihan mesin & komponen";
                              else if (service.toLowerCase().contains("coating")) desc = "Coating body premium";
                              else if (service.toLowerCase().contains("full")) desc = "Paket cuci & detailing lengkap";

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: _cardDark,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: _borderDark),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF3B82F6).withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Icon(Icons.local_car_wash, color: Color(0xFF3B82F6), size: 16),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              service,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              desc,
                                              style: TextStyle(
                                                color: _textSlate,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        _formatPrice(price),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                            const SizedBox(height: 20),
                            // Ringkasan Pembayaran Section
                            _buildSheetSectionHeader("🪙 Ringkasan Pembayaran"),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: _cardDark,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: _borderDark),
                              ),
                              child: Column(
                                children: [
                                  _buildBillingRow("Subtotal", _formatPrice(subtotal)),
                                  const SizedBox(height: 8),
                                  _buildBillingRow("Diskon", "- ${_formatPrice(diskon)}", isDiscount: true),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8.0),
                                    child: Divider(color: Color(0xFF1E293B)),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Total", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                      Text(
                                        _formatPrice(total),
                                        style: const TextStyle(
                                          color: Color(0xFF3B82F6),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Jadwal Kedatangan Section
                            _buildSheetSectionHeader("📅 Jadwal Kedatangan"),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: _cardDark,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: _borderDark),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Tanggal", style: TextStyle(color: _textSlate, fontSize: 10)),
                                      const SizedBox(height: 4),
                                      Text(order.tanggal, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text("Jam", style: TextStyle(color: _textSlate, fontSize: 10)),
                                      const SizedBox(height: 4),
                                      Text("${order.waktu} WIB", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Payment Method Section
                            _buildSheetSectionHeader("📷 Bukti Pembayaran"),
                            const SizedBox(height: 10),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: _cardDark,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: _borderDark),
                              ),
                              child: order.buktiPembayaran.isNotEmpty
                                  ? Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                "Metode: ${order.payment}",
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF10B981).withOpacity(0.12),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: const Text(
                                                "Sudah Diunggah",
                                                style: TextStyle(
                                                  color: Color(0xFF10B981),
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        GestureDetector(
                                          onTap: () {
                                            HapticFeedback.lightImpact();
                                            showDialog(
                                              context: context,
                                              builder: (context) => Dialog(
                                                backgroundColor: const Color(0xFF090D16),
                                                insetPadding: const EdgeInsets.all(10),
                                                child: Stack(
                                                  alignment: Alignment.topRight,
                                                  children: [
                                                    InteractiveViewer(
                                                      panEnabled: true,
                                                      boundaryMargin: const EdgeInsets.all(20),
                                                      minScale: 0.5,
                                                      maxScale: 4,
                                                      child: Center(
                                                        child: file_image_helper.fileImage(
                                                          order.buktiPembayaran,
                                                          fit: BoxFit.contain,
                                                        ),
                                                      ),
                                                    ),
                                                    Positioned(
                                                      top: 10,
                                                      right: 10,
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          color: Colors.black.withOpacity(0.5),
                                                          shape: BoxShape.circle,
                                                        ),
                                                        child: IconButton(
                                                          icon: const Icon(Icons.close, color: Colors.white, size: 20),
                                                          onPressed: () => Navigator.pop(context),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(12),
                                            child: SizedBox(
                                              height: 180,
                                              width: double.infinity,
                                              child: Stack(
                                                fit: StackFit.expand,
                                                children: [
                                                  file_image_helper.fileImage(
                                                    order.buktiPembayaran,
                                                    fit: BoxFit.cover,
                                                  ),
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                                                        begin: Alignment.bottomCenter,
                                                        end: Alignment.topCenter,
                                                      ),
                                                    ),
                                                  ),
                                                  const Positioned(
                                                    bottom: 12,
                                                    right: 12,
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.zoom_in, color: Colors.white70, size: 14),
                                                        SizedBox(width: 4),
                                                        Text(
                                                          "Ketuk untuk memperbesar",
                                                          style: TextStyle(color: Colors.white70, fontSize: 10),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                "Metode: ${order.payment}",
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFF97316).withOpacity(0.12),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: const Text(
                                                "Belum Diunggah",
                                                style: TextStyle(
                                                  color: Color(0xFFF97316),
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(vertical: 24),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF1E293B).withOpacity(0.3),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: const Color(0xFF1E293B)),
                                          ),
                                          child: Column(
                                            children: [
                                              Icon(Icons.image_not_supported_outlined, color: _textSlate.withOpacity(0.5), size: 28),
                                              const SizedBox(height: 8),
                                              Text(
                                                "Tidak ada bukti pembayaran yang diunggah",
                                                style: TextStyle(color: _textSlate, fontSize: 11),
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
                      // Bottom Actions inside modal
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: _cardDark,
                          border: Border(top: BorderSide(color: _borderDark)),
                        ),
                        child: _buildModalActionButtons(order, setModalState),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildSheetSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 13,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSheetIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          shape: BoxShape.circle,
          border: Border.all(color: _borderDark),
        ),
        child: Icon(icon, color: Colors.white, size: 14),
      ),
    );
  }

  Widget _buildBillingRow(String label, String value, {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: _textSlate, fontSize: 12)),
        Text(
          value,
          style: TextStyle(
            color: isDiscount ? const Color(0xFFEF4444) : Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildModalActionButtons(OrderModel order, StateSetter setModalState) {
    if (order.orderStatus == OrderStatus.selesai) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: const Center(
          child: Text(
            "Pesanan Selesai & Lunas",
            style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
      );
    }

    if (order.orderStatus == OrderStatus.ditolak) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: const Center(
          child: Text(
            "Pesanan Dibatalkan",
            style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
      );
    }

    return Row(
      children: [
        if (order.orderStatus == OrderStatus.menunggu) ...[
          Expanded(
            child: SizedBox(
              height: 40,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  setModalState(() {
                    _changeOrderStatus(order, OrderStatus.diproses);
                  });
                  Navigator.pop(context);
                  _showToast("Pesanan Dikonfirmasi");
                },
                child: const Text("Konfirmasi", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SizedBox(
              height: 40,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  setModalState(() {
                    _changeOrderStatus(order, OrderStatus.diproses);
                  });
                  Navigator.pop(context);
                  _showToast("Pesanan Diproses");
                },
                child: const Text("Proses", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SizedBox(
              height: 40,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFEF4444),
                  side: const BorderSide(color: Color(0xFFEF4444)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  setModalState(() {
                    _changeOrderStatus(order, OrderStatus.ditolak);
                  });
                  Navigator.pop(context);
                  _showToast("Pesanan Dibatalkan");
                },
                child: const Text("Batalkan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ),
          ),
        ],
        if (order.orderStatus == OrderStatus.diproses) ...[
          Expanded(
            child: SizedBox(
              height: 40,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  setModalState(() {
                    _changeOrderStatus(order, OrderStatus.selesai);
                  });
                  Navigator.pop(context);
                  _showToast("Pesanan Ditandai Selesai");
                },
                child: const Text("Tandai Selesai", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SizedBox(
              height: 40,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFEF4444),
                  side: const BorderSide(color: Color(0xFFEF4444)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  setModalState(() {
                    _changeOrderStatus(order, OrderStatus.ditolak);
                  });
                  Navigator.pop(context);
                  _showToast("Pesanan Dibatalkan");
                },
                child: const Text("Batalkan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _showToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF3B82F6),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // --- PREMIUM MOCK DATA GENERATOR ---
  List<OrderModel> _generateMockOrders() {
    return [
      OrderModel(
        invoice: "MW250625-001",
        nama: "Deri Saputra",
        layanan: "Wash & Wax, Engine Detailing",
        tanggal: "25 Juni 2026",
        waktu: "08:30",
        harga: "Rp 125.000",
        status: "Menunggu Konfirmasi",
        payment: "Transfer Bank BCA",
        expired: "2026-06-25 09:30",
        noPolisi: "B 1234 KZX",
        tipeMotor: "Vario 150",
      ),
      OrderModel(
        invoice: "MW250625-002",
        nama: "Ilham Maulana",
        layanan: "Body Detailing",
        tanggal: "25 Juni 2026",
        waktu: "09:15",
        harga: "Rp 100.000",
        status: "Diproses",
        payment: "Transfer Bank Mandiri",
        expired: "",
        noPolisi: "B 5678 ABC",
        tipeMotor: "Aerox 155",
      ),
      OrderModel(
        invoice: "MW250625-003",
        nama: "Fauzi Rahman",
        layanan: "Full Detailing, Coating Premium",
        tanggal: "25 Juni 2026",
        waktu: "10:30",
        harga: "Rp 250.000",
        status: "Diproses",
        payment: "Transfer Bank BCA",
        expired: "",
        noPolisi: "F 9012 DEF",
        tipeMotor: "NMax 155",
      ),
      OrderModel(
        invoice: "MW250625-004",
        nama: "Rizki Maulana",
        layanan: "Wash & Wax",
        tanggal: "25 Juni 2026",
        waktu: "11:45",
        harga: "Rp 25.000",
        status: "Sudah Dibayar",
        payment: "Cash",
        expired: "",
        noPolisi: "B 2222 ZZZ",
        tipeMotor: "PCX 160",
      ),
      OrderModel(
        invoice: "MW250625-005",
        nama: "Aldi Kurniawan",
        layanan: "Engine Detailing",
        tanggal: "25 Juni 2026",
        waktu: "13:00",
        harga: "Rp 100.000",
        status: "Menunggu Konfirmasi",
        payment: "Transfer Bank BCA",
        expired: "2026-06-25 14:00",
        noPolisi: "B 3333 YYY",
        tipeMotor: "Beat FI",
      ),
      OrderModel(
        invoice: "MW250625-006",
        nama: "Andi Setiawan",
        layanan: "Body Detailing, Wash & Wax",
        tanggal: "25 Juni 2026",
        waktu: "14:20",
        harga: "Rp 125.000",
        status: "Sudah Dibayar",
        payment: "Cash",
        expired: "",
        noPolisi: "B 4444 XXX",
        tipeMotor: "Scoopy",
      ),
      OrderModel(
        invoice: "MW250625-007",
        nama: "Budi Santoso",
        layanan: "Coating Premium",
        tanggal: "25 Juni 2026",
        waktu: "15:30",
        harga: "Rp 200.000",
        status: "Ditolak",
        payment: "Transfer Bank BCA",
        expired: "",
        noPolisi: "B 5555 WWW",
        tipeMotor: "Vespa LX 125",
      ),
      OrderModel(
        invoice: "MW250625-008",
        nama: "Yanto Pratama",
        layanan: "Full Detailing",
        tanggal: "25 Juni 2026",
        waktu: "16:10",
        harga: "Rp 150.000",
        status: "Diproses",
        payment: "Transfer Bank Mandiri",
        expired: "",
        noPolisi: "F 6666 QCQ",
        tipeMotor: "Vixion",
      ),
    ];
  }
}

// Keep a minimal fallback full-page class to avoid breaking any legacy code.
class OrderDetailPage extends StatefulWidget {
  final OrderModel order;
  final VoidCallback onStatusChanged;

  const OrderDetailPage({
    required this.order,
    required this.onStatusChanged,
    super.key,
  });

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  @override
  Widget build(BuildContext context) {
    // Simply return an empty scaffold since the app now uses the draggable bottom sheet
    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      appBar: AppBar(backgroundColor: const Color(0xFF111726), title: Text("#${widget.order.invoice}")),
      body: const Center(child: Text("Detail ditampilkan melalui bottom sheet di halaman utama.", style: TextStyle(color: Colors.white70))),
    );
  }
}
