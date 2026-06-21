import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class OrderModel {
  String invoice;
  String nama;
  String layanan;
  String tanggal;
  String waktu;
  String harga;
  String status;
  String payment;
  String expired;

  /// TAMBAHAN
  String noPolisi;
  String tipeMotor;

  /// BUKTI PEMBAYARAN
  String buktiPembayaran;

  OrderModel({
    required this.invoice,
    required this.nama,
    required this.layanan,
    required this.tanggal,
    required this.waktu,
    required this.harga,
    required this.status,
    required this.payment,
    required this.expired,
    required this.noPolisi,
    required this.tipeMotor,
    this.buktiPembayaran = "",
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      invoice: json['invoice'] as String,
      nama: json['nama'] as String,
      layanan: json['layanan'] as String,
      tanggal: json['tanggal'] as String,
      waktu: json['waktu'] as String,
      harga: json['harga'] as String,
      status: json['status'] as String,
      payment: json['payment'] as String,
      expired: json['expired'] as String,
      noPolisi: json['noPolisi'] as String,
      tipeMotor: json['tipeMotor'] as String,
      buktiPembayaran: json['buktiPembayaran'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'invoice': invoice,
      'nama': nama,
      'layanan': layanan,
      'tanggal': tanggal,
      'waktu': waktu,
      'harga': harga,
      'status': status,
      'payment': payment,
      'expired': expired,
      'noPolisi': noPolisi,
      'tipeMotor': tipeMotor,
      'buktiPembayaran': buktiPembayaran,
    };
  }
}

class OrderData {
  static const String _ordersKey = 'orders';
  static List<OrderModel> orders = [];

  static Future<void> loadOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_ordersKey);

    if (raw == null || raw.isEmpty) {
      orders = [];
      return;
    }

    try {
      final list = jsonDecode(raw) as List<dynamic>;
      orders = list
          .map((item) => OrderModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      orders = [];
    }
  }

  static Future<void> saveOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final data = orders.map((order) => order.toJson()).toList();
    await prefs.setString(_ordersKey, jsonEncode(data));
  }

  static Future<void> clearOrders() async {
    final prefs = await SharedPreferences.getInstance();
    orders = [];
    await prefs.remove(_ordersKey);
  }
}
