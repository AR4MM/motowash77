import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

enum OrderStatus {
  menunggu,
  diproses,
  selesai,
  ditolak,
}

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
  String noPolisi;
  String tipeMotor;
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

  OrderStatus get orderStatus {
    if (status == 'Diproses') return OrderStatus.diproses;
    if (status == 'Selesai' || status == 'Sudah Dibayar') return OrderStatus.selesai;
    if (status == 'Ditolak' || status == 'Dibatalkan') return OrderStatus.ditolak;
    return OrderStatus.menunggu;
  }

  bool get isToday {
    if (invoice.startsWith('INV')) {
      try {
        final cleanInvoice = invoice.replaceAll(RegExp(r'[^0-9]'), '');
        if (cleanInvoice.length >= 13) {
          final ms = int.parse(cleanInvoice.substring(0, 13));
          final dt = DateTime.fromMillisecondsSinceEpoch(ms);
          final now = DateTime.now();
          if (dt.day == now.day && dt.month == now.month && dt.year == now.year) {
            return true;
          }
        }
      } catch (_) {}
    }

    if (tanggal.isEmpty) return false;
    final now = DateTime.now();

    // Format 1: d-M-yyyy (e.g. "23-6-2026" or "23-06-2026")
    final partsDash = tanggal.split('-');
    if (partsDash.length == 3) {
      final day = int.tryParse(partsDash[0]);
      final month = int.tryParse(partsDash[1]);
      final year = int.tryParse(partsDash[2]);
      return day == now.day && month == now.month && year == now.year;
    }

    // Format 2: d MMMM yyyy (e.g. "23 Juni 2026")
    final partsSpace = tanggal.split(' ');
    if (partsSpace.length == 3) {
      final day = int.tryParse(partsSpace[0]);
      final year = int.tryParse(partsSpace[2]);
      const monthNames = [
        'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
      ];
      final monthIdx = monthNames.indexOf(partsSpace[1]) + 1;
      return day == now.day && monthIdx == now.month && year == now.year;
    }

    return false;
  }

  bool get isPast {
    if (tanggal.isEmpty) return true;
    try {
      final now = DateTime.now();
      final todayDate = DateTime(now.year, now.month, now.day);

      // Format 1: d-M-yyyy (e.g. "23-6-2026")
      final partsDash = tanggal.split('-');
      if (partsDash.length == 3) {
        final day = int.tryParse(partsDash[0]);
        final month = int.tryParse(partsDash[1]);
        final year = int.tryParse(partsDash[2]);
        if (day != null && month != null && year != null) {
          final orderDate = DateTime(year, month, day);
          return orderDate.isBefore(todayDate);
        }
      }

      // Format 2: d MMMM yyyy (e.g. "23 Juni 2026")
      final partsSpace = tanggal.split(' ');
      if (partsSpace.length == 3) {
        final day = int.tryParse(partsSpace[0]);
        final year = int.tryParse(partsSpace[2]);
        const monthNames = [
          'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
          'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
        ];
        final monthIdx = monthNames.indexOf(partsSpace[1]) + 1;
        if (day != null && monthIdx > 0 && year != null) {
          final orderDate = DateTime(year, monthIdx, day);
          return orderDate.isBefore(todayDate);
        }
      }
    } catch (_) {}
    return true; // Fallback to true if parsing fails
  }

  set orderStatus(OrderStatus newStatus) {
    switch (newStatus) {
      case OrderStatus.menunggu:
        status = 'Menunggu Konfirmasi';
        break;
      case OrderStatus.diproses:
        status = 'Diproses';
        break;
      case OrderStatus.selesai:
        status = 'Sudah Dibayar';
        break;
      case OrderStatus.ditolak:
        status = 'Ditolak';
        break;
    }
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      invoice: json['invoice'] as String? ?? '',
      nama: json['nama'] as String? ?? '',
      layanan: json['layanan'] as String? ?? '',
      tanggal: json['tanggal'] as String? ?? '',
      waktu: json['waktu'] as String? ?? '',
      harga: json['harga'] as String? ?? '',
      status: json['status'] as String? ?? '',
      payment: json['payment'] as String? ?? '',
      expired: json['expired'] as String? ?? '',
      noPolisi: json['noPolisi'] as String? ?? '',
      tipeMotor: json['tipeMotor'] as String? ?? '',
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
  static const String _baseUrl = 'http://localhost/motowash_api';
  static List<OrderModel> orders = [];

  /// Fetch orders from API server (realtime). Falls back to local cache on error.
  static Future<void> fetchFromApi({String? nama, String? noPolisi}) async {
    try {
      String url = '$_baseUrl/get_orders.php';
      final params = <String, String>{};
      if (nama != null && nama.isNotEmpty) params['nama'] = nama;
      if (noPolisi != null && noPolisi.isNotEmpty) params['no_polisi'] = noPolisi;
      if (params.isNotEmpty) {
        url += '?' + params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&');
      }

      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        if (json['success'] == true) {
          final list = json['data'] as List<dynamic>;
          orders = list
              .map((item) => OrderModel.fromJson(item as Map<String, dynamic>))
              .toList();
          // Sync to local cache
          await saveOrders();
          return;
        }
      }
    } catch (e) {
      debugPrint('fetchFromApi error: $e');
    }
    // Fallback to local cache
    await loadOrders();
  }

  /// Load orders from local SharedPreferences cache.
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

  static Future<bool> updateStatusInApi(String invoice, String status) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/update_status.php'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: jsonEncode({
          'invoice': invoice,
          'status': status,
        }),
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return json['success'] == true;
      }
    } catch (e) {
      debugPrint('updateStatusInApi error: $e');
    }
    return false;
  }

  static Future<void> clearOrders() async {
    final prefs = await SharedPreferences.getInstance();
    orders = [];
    await prefs.remove(_ordersKey);
  }
}
