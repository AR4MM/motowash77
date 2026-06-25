import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ServiceModel {
  String id;
  String name;
  int price;
  String image;
  String iconKey;
  String description;
  bool isActive;

  ServiceModel({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.iconKey,
    this.description = "",
    this.isActive = true,
  });

  IconData get icon {
    switch (iconKey) {
      case 'water_drop':
        return Icons.water_drop;
      case 'auto_fix_high':
        return Icons.auto_fix_high;
      case 'settings':
        return Icons.settings;
      case 'shield':
        return Icons.shield;
      default:
        return Icons.local_car_wash;
    }
  }

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] as String,
      name: json['name'] as String,
      price: json['price'] as int,
      image: json['image'] as String,
      iconKey: json['iconKey'] as String? ?? 'water_drop',
      description: json['description'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'image': image,
      'iconKey': iconKey,
      'description': description,
      'isActive': isActive,
    };
  }
}

class ServiceData {
  static const String _servicesKey = 'services_list_v2';
  static List<ServiceModel> services = [];

  static final List<ServiceModel> _defaultServices = [
    ServiceModel(
      id: '1',
      name: 'Wash & Wax',
      price: 15000,
      image: 'assets/images/cucimotor.jpg',
      iconKey: 'water_drop',
      description: 'Pencucian motor lengkap dengan wax premium agar mengkilap dan terlindungi dari debu.',
    ),
    ServiceModel(
      id: '2',
      name: 'Body Detailing',
      price: 50000,
      image: 'assets/images/detailing.jpg',
      iconKey: 'auto_fix_high',
      description: 'Pembersihan mendalam untuk seluruh body motor guna mengembalikan kecerahan warna cat.',
    ),
    ServiceModel(
      id: '3',
      name: 'Engine Detailing',
      price: 100000,
      image: 'assets/images/detailing engine.jpg',
      iconKey: 'settings',
      description: 'Pembersihan kerak, oli, dan kotoran membandel di sela-sela mesin secara aman.',
    ),
    ServiceModel(
      id: '4',
      name: 'Full Detailing',
      price: 150000,
      image: 'assets/images/detailing full.jpg',
      iconKey: 'shield',
      description: 'Paket lengkap pembersihan menyeluruh dari body, mesin, sasis, hingga proteksi coating.',
    ),
    ServiceModel(
      id: '5',
      name: 'Polish Body',
      price: 150000,
      image: 'assets/images/polish body.jpg',
      iconKey: 'auto_fix_high',
      description: 'Pemolesan body motor untuk menghilangkan baret halus dan menjaga ketahanan kilap cat.',
    ),
  ];

  static Future<void> loadServices() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_servicesKey);

    if (raw == null || raw.isEmpty) {
      services = List.from(_defaultServices);
      await saveServices();
      return;
    }

    try {
      final list = jsonDecode(raw) as List<dynamic>;
      services = list
          .map((item) => ServiceModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      services = List.from(_defaultServices);
    }
  }

  static Future<void> saveServices() async {
    final prefs = await SharedPreferences.getInstance();
    final data = services.map((s) => s.toJson()).toList();
    final jsonStr = jsonEncode(data);
    print("Saving services JSON: $jsonStr");
    await prefs.setString(_servicesKey, jsonStr);
  }

  static Future<void> resetServices() async {
    services = List.from(_defaultServices);
    await saveServices();
  }
}
