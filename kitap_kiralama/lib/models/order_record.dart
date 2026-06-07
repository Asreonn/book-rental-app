import 'package:kitap_kiralama/models/book.dart';

class OrderRecord {
  const OrderRecord({
    required this.orderCode,
    required this.items,
    required this.totalPrice,
    required this.createdAt,
    this.status = 'Onay Bekliyor',
    this.userId = '',
    this.userEmail = '',
  });

  final String orderCode;
  final List<Book> items;
  final int totalPrice;
  final DateTime createdAt;

  /// Siparisin guncel durumu (orn. "Hazirlaniyor", "Kargoya Verildi").
  final String status;

  /// Siparisi veren kullanicinin Firebase UID'i (admin guncellemesi icin).
  final String userId;

  /// Siparisi veren kullanicinin e-posta adresi (admin panelinde gosterilir).
  final String userEmail;

  String get createdLabel {
    final String day = createdAt.day.toString().padLeft(2, '0');
    final String month = createdAt.month.toString().padLeft(2, '0');
    final String year = createdAt.year.toString();
    final String hour = createdAt.hour.toString().padLeft(2, '0');
    final String minute = createdAt.minute.toString().padLeft(2, '0');
    return '$day.$month.$year • $hour:$minute';
  }

  String get bookTitles {
    return items.map((Book book) => book.title).join(', ');
  }

  String get statusLabel => status;

  String get trackingCode => 'TRK-${orderCode.substring(2)}';

  String get estimatedDeliveryLabel {
    final DateTime estimatedDate = createdAt.add(const Duration(days: 2));
    final String day = estimatedDate.day.toString().padLeft(2, '0');
    final String month = estimatedDate.month.toString().padLeft(2, '0');
    return '$day.$month icinde teslim';
  }
}
