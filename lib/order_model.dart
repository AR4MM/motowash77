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

    /// TAMBAHAN
    this.buktiPembayaran = "",
  });
}

class OrderData {
  static List<OrderModel> orders = [];
}
