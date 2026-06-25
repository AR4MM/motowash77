import 'dart:async';
import 'package:flutter/material.dart';

import 'booking_form_page.dart';
import 'history_page.dart';
import 'profile_page.dart';
import 'notification_page.dart';

import 'models/service_model.dart';
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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// ================= SLIDER =================
  final PageController _pageController = PageController();
  Timer? _sliderTimer;

  int currentPage = 0;

  final List<String> banners = [
    "assets/images/promo1.jpg",
    "assets/images/promo2.jpg",
    "assets/images/promo3.jpg",
  ];

  /// ================= SEARCH =================
  final TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>> services = [];

  List<Map<String, dynamic>> filteredServices = [];

  @override
  void initState() {
    super.initState();
    _refreshServices();

    /// AUTO SLIDER
    _sliderTimer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (_pageController.hasClients) {
        if (currentPage < banners.length - 1) {
          currentPage++;
        } else {
          currentPage = 0;
        }

        _pageController.animateToPage(
          currentPage,
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _sliderTimer?.cancel();
    _pageController.dispose();
    searchController.dispose();
    super.dispose();
  }

  void _loadDynamicServices() {
    // ServiceData.services is already loaded in main() and mutated
    // in-place by the admin CRUD. We just rebuild from the live list.
    setState(() {
      services = ServiceData.services.map((s) => {
        "title": s.name,
        "price": _formatPriceString(s.name, s.price),
        "image": s.image,
        "icon": s.icon,
      }).toList();
      filteredServices = services;
    });
  }

  // Called whenever this page becomes visible again (e.g. after returning
  // from BookingFormPage or after admin edits services).
  Future<void> _refreshServices() async {
    await ServiceData.loadServices();
    if (mounted) _loadDynamicServices();
  }

  String _formatPriceString(String name, int price) {
    if (name == 'Wash & Wax') {
      return "Rp 15.000 - Rp 30.000";
    }
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

  /// ================= SEARCH =================
  void filterServices(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredServices = services;
      } else {
        filteredServices = services.where((service) {
          return service["title"].toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  /// ================= CARD =================
  Widget serviceCard(Map<String, dynamic> service) {
    final title = service["title"] as String;
    final price = service["price"] as String;
    final image = service["image"] as String;
    final icon = service["icon"] as IconData;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),

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
              height: 220,
              width: double.infinity,

              child: _buildServiceImage(
                image,
                fit: BoxFit.cover,
              ),
            ),

            /// OVERLAY
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.75),
                      Colors.transparent,
                    ],

                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
            ),

            /// ICON
            Positioned(
              top: 18,
              right: 18,

              child: Container(
                padding: const EdgeInsets.all(10),

                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(16),
                ),

                child: Icon(icon, color: Colors.white, size: 22),
              ),
            ),

            /// CONTENT
            Positioned(
              left: 18,
              right: 18,
              bottom: 18,

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    price,
                    style: const TextStyle(color: Colors.white70, fontSize: 15),
                  ),

                  const SizedBox(height: 15),

                  Row(
                    children: [
                      Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(30),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(30),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookingDetailPage(
                                  service: {
                                    "name": title,
                                    "image": image,
                                    "price": title == 'Wash & Wax' ? "Mulai Rp 15.000" : price,
                                  },
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),

                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(30),
                            ),

                            child: const Text(
                              "Pesan Sekarang",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const Spacer(),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),

                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),

                          borderRadius: BorderRadius.circular(20),
                        ),

                        child: const Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 18),

                            SizedBox(width: 5),

                            Text(
                              "4.9",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
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
    );
  }

  /// ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      body: CustomScrollView(
        slivers: [
          /// ================= APPBAR =================
          SliverAppBar(
            backgroundColor: const Color(0xFF0D1B2A),

            expandedHeight: 430,

            pinned: true,
            floating: false,

            elevation: 0,

            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0D1B2A), Color(0xFF1B263B)],

                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),

                child: SafeArea(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          /// ================= HEADER =================
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,

                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: const [
                                  Text(
                                    "MotoWash77",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  SizedBox(height: 5),

                                  Text(
                                    "Premium Motorcycle Wash",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),

                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const NotificationPage()),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(12),

                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),

                                    borderRadius: BorderRadius.circular(16),
                                  ),

                                  child: const Icon(
                                    Icons.notifications_none,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 25),

                          /// ================= SEARCH =================
                          Container(
                            height: 58,

                            padding: const EdgeInsets.symmetric(horizontal: 18),

                            decoration: BoxDecoration(
                              color: Colors.white,

                              borderRadius: BorderRadius.circular(18),
                            ),

                            child: TextField(
                              controller: searchController,

                              onChanged: filterServices,

                              style: const TextStyle(fontSize: 15),

                              decoration: const InputDecoration(
                                border: InputBorder.none,

                                icon: Icon(Icons.search, color: Colors.grey),

                                hintText: "Cari layanan cuci motor...",

                                hintStyle: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ),

                          const SizedBox(height: 25),

                          /// ================= SLIDER =================
                          SizedBox(
                            height: 230,

                            child: Column(
                              children: [
                                Expanded(
                                  child: PageView.builder(
                                    controller: _pageController,

                                    itemCount: banners.length,

                                    itemBuilder: (context, index) {
                                      return Container(
                                        margin: const EdgeInsets.only(
                                          right: 10,
                                        ),

                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),

                                          child: Stack(
                                            fit: StackFit.expand,

                                            children: [
                                              /// IMAGE
                                              Positioned.fill(
                                                child: Image.asset(
                                                  banners[index],

                                                  fit: BoxFit.cover,

                                                  alignment: Alignment.center,
                                                ),
                                              ),

                                              /// OVERLAY
                                              Positioned.fill(
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        Colors.black
                                                            .withValues(alpha: 0.82),

                                                        Colors.transparent,
                                                      ],

                                                      begin:
                                                          Alignment.bottomLeft,

                                                      end: Alignment.topRight,
                                                    ),
                                                  ),
                                                ),
                                              ),

                                              /// CONTENT
                                              Padding(
                                                padding: const EdgeInsets.all(
                                                  22,
                                                ),

                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,

                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,

                                                  children: [
                                                    const Text(
                                                      "Motor Bersih,\nLebih Percaya Diri ✨",
                                                      style: TextStyle(
                                                        color: Colors.white,

                                                        fontSize: 26,

                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),

                                                    const SizedBox(height: 10),

                                                    Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 14,

                                                            vertical: 8,
                                                          ),

                                                      decoration: BoxDecoration(
                                                        color: Colors.blue,

                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              20,
                                                            ),
                                                      ),

                                                      child: const Text(
                                                        "Diskon Hingga 30%",
                                                        style: TextStyle(
                                                          color: Colors.white,

                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),

                                const SizedBox(height: 15),

                                /// ================= INDICATOR =================
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,

                                  children: List.generate(banners.length, (
                                    index,
                                  ) {
                                    return AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),

                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),

                                      width: currentPage == index ? 22 : 8,

                                      height: 8,

                                      decoration: BoxDecoration(
                                        color: currentPage == index
                                            ? Colors.white
                                            : Colors.white38,

                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          /// ================= CONTENT =================
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  /// TITLE
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [
                      const Text(
                        "Layanan Populer",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const BookingFormPage(),
                            ),
                          );
                        },
                        child: const Text(
                          "Lihat Semua",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// ================= CARD =================
                  Column(
                    children: filteredServices.map((service) {
                      return serviceCard(service);
                    }).toList(),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      /// ================= BOTTOM NAV =================
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
          currentIndex: 0,

          backgroundColor: Colors.transparent,

          elevation: 0,

          type: BottomNavigationBarType.fixed,

          selectedItemColor: const Color(0xFF0D1B2A),

          unselectedItemColor: Colors.grey,

          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),

          onTap: (index) {
            if (index == 1) {
              Navigator.push(
                context,

                MaterialPageRoute(
                  builder: (context) => const BookingFormPage(),
                ),
              );
            } else if (index == 2) {
              Navigator.push(
                context,

                MaterialPageRoute(builder: (context) => const HistoryPage()),
              );
            } else if (index == 3) {
              Navigator.push(
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
