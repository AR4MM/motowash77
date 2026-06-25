import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/order_model.dart';

class NotificationItem {
  final String title;
  final String subtitle;
  final String date;
  final IconData icon;
  final Color iconColor;
  final String type; // 'transaksi' or 'promo'

  NotificationItem({
    required this.title,
    required this.subtitle,
    required this.date,
    required this.icon,
    required this.iconColor,
    required this.type,
  });
}

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<NotificationItem> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadNotifications();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final namaUser = prefs.getString('nama') ?? "";
    final platUser = prefs.getString('plat') ?? "";

    if (namaUser.trim().isNotEmpty && platUser.trim().isNotEmpty && platUser.trim() != '-') {
      await OrderData.fetchFromApi(nama: namaUser, noPolisi: platUser);
    }

    notifications.clear();

    final cleanPlat = platUser.replaceAll(' ', '').toLowerCase();
    final userOrders = (namaUser.trim().isEmpty || platUser.trim().isEmpty || platUser.trim() == '-')
        ? <OrderModel>[]
        : OrderData.orders.where((o) =>
            o.nama.trim().toLowerCase() == namaUser.trim().toLowerCase() &&
            o.noPolisi.replaceAll(' ', '').toLowerCase() == cleanPlat
        ).toList();

    // If there are no bookings, we keep notifications empty to show the empty state
    if (userOrders.isEmpty) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    // 1. Add Promo Notification (as requested)
    notifications.add(NotificationItem(
      title: "Promo Diskon 20%",
      subtitle: "Berlaku hingga 30 Juni 2026",
      date: "20 Juni 2026",
      icon: Icons.local_offer_rounded,
      iconColor: Colors.redAccent,
      type: "promo",
    ));

    // 2. Add Booking status notifications from newest to oldest
    for (int i = userOrders.length - 1; i >= 0; i--) {
      final order = userOrders[i];
      final dateStr = order.tanggal;
      final List<NotificationItem> orderSteps = [];

      // Step 1: Booking berhasil dibuat
      orderSteps.add(NotificationItem(
        title: "Booking berhasil dibuat",
        subtitle: "Booking layanan ${order.layanan} (${order.invoice}) berhasil dibuat.",
        date: dateStr,
        icon: Icons.receipt_long_rounded,
        iconColor: Colors.blue,
        type: "transaksi",
      ));

      // Step 2: Pembayaran berhasil diverifikasi
      if (order.orderStatus == OrderStatus.diproses || order.orderStatus == OrderStatus.selesai) {
        orderSteps.add(NotificationItem(
          title: "Pembayaran berhasil diverifikasi",
          subtitle: "Pembayaran untuk pesanan ${order.invoice} telah diverifikasi.",
          date: dateStr,
          icon: Icons.payment_rounded,
          iconColor: Colors.green,
          type: "transaksi",
        ));

        // Step 3: Motor Anda sedang dicuci
        orderSteps.add(NotificationItem(
          title: "Motor Anda sedang dicuci",
          subtitle: "Motor Anda sedang dicuci oleh tim MotoWash77.",
          date: dateStr,
          icon: Icons.local_car_wash_rounded,
          iconColor: Colors.teal,
          type: "transaksi",
        ));
      }

      // Step 4: Booking selesai
      if (order.orderStatus == OrderStatus.selesai) {
        orderSteps.add(NotificationItem(
          title: "Booking selesai",
          subtitle: "Layanan cuci untuk invoice ${order.invoice} telah selesai. Terima kasih!",
          date: dateStr,
          icon: Icons.check_circle_rounded,
          iconColor: Colors.green,
          type: "transaksi",
        ));
      }

      // Step 5: Booking ditolak
      if (order.orderStatus == OrderStatus.ditolak) {
        orderSteps.add(NotificationItem(
          title: "Booking ditolak",
          subtitle: "Mohon maaf, pesanan ${order.invoice} ditolak oleh admin.",
          date: dateStr,
          icon: Icons.cancel_rounded,
          iconColor: Colors.red,
          type: "transaksi",
        ));
      }

      // Add order events reversed so the latest event of this booking is shown on top
      notifications.addAll(orderSteps.reversed);
    }

    setState(() {
      isLoading = false;
    });
  }

  List<NotificationItem> _getFilteredNotifications(int tabIndex) {
    if (tabIndex == 0) return notifications;
    if (tabIndex == 1) return notifications.where((n) => n.type == 'transaksi').toList();
    return notifications.where((n) => n.type == 'promo').toList();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_off_outlined,
                size: 70,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "🔔 Belum ada notifikasi",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D1B2A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Anda akan menerima informasi booking dan promo di sini.",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
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
          "Notifikasi",
          style: TextStyle(
            color: Color(0xFF0D1B2A),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0D1B2A), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF0D1B2A),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF0D1B2A),
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: "Semua"),
            Tab(text: "Transaksi"),
            Tab(text: "Promo"),
          ],
          onTap: (_) => setState(() {}),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: List.generate(3, (tabIndex) {
                final filteredList = _getFilteredNotifications(tabIndex);
                if (filteredList.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  itemCount: filteredList.length,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemBuilder: (context, index) {
                    final item = filteredList[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: item.iconColor.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            item.icon,
                            color: item.iconColor,
                            size: 24,
                          ),
                        ),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                item.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Color(0xFF0D1B2A),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              item.date,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Text(
                            item.subtitle,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
    );
  }
}
