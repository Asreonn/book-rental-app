import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kitap_kiralama/models/book.dart';
import 'package:kitap_kiralama/models/order_record.dart';

/// Yonetici islemlerini yurutur: tum kullanicilarin siparislerini okur
/// ve siparis durumlarini gunceller. Sadece admin hesabi tarafindan
/// kullanilir (Firestore kurallari erisimi admin ile sinirlar).
class AdminRepository {
  AdminRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Tum kullanicilarin "orders" alt koleksiyonlarini tek seferde dinler
  /// (collectionGroup). Siralama, ek bir Firestore indeksi gerektirmemek
  /// icin uygulama tarafinda (yeniden eskiye) yapilir.
  Stream<List<OrderRecord>> watchAllOrders(Map<String, Book> booksById) {
    return _firestore.collectionGroup('orders').snapshots().map((
      QuerySnapshot<Map<String, dynamic>> snap,
    ) {
      final List<OrderRecord> orders = snap.docs.map((
        QueryDocumentSnapshot<Map<String, dynamic>> d,
      ) {
        final Map<String, dynamic> m = d.data();
        final List<String> ids =
            ((m['bookIds'] as List<dynamic>?) ?? <dynamic>[])
                .map((dynamic e) => e.toString())
                .toList();
        final List<Book> items = <Book>[
          for (final String id in ids)
            if (booksById[id] != null) booksById[id]!,
        ];
        final Timestamp? ts = m['createdAt'] as Timestamp?;
        return OrderRecord(
          orderCode: (m['orderCode'] as String?) ?? d.id,
          items: items,
          totalPrice: (m['totalPrice'] as num?)?.toInt() ?? 0,
          createdAt: ts?.toDate() ?? DateTime.now(),
          status: (m['status'] as String?) ?? 'Hazirlaniyor',
          userId: (m['userId'] as String?) ?? '',
          userEmail: (m['userEmail'] as String?) ?? '',
        );
      }).toList();
      orders.sort(
        (OrderRecord a, OrderRecord b) => b.createdAt.compareTo(a.createdAt),
      );
      return orders;
    });
  }

  /// Bir siparisin durumunu gunceller. Siparis dokumani ilgili
  /// kullanicinin alt koleksiyonunda durdugu icin userId gereklidir.
  Future<void> updateStatus(OrderRecord order, String status) async {
    await _firestore
        .collection('users')
        .doc(order.userId)
        .collection('orders')
        .doc(order.orderCode)
        .update(<String, dynamic>{'status': status});
  }

  /// "books" koleksiyonuna yeni bir kitap ekler. Dokuman id'si data['id']
  /// alanindan alinir.
  Future<void> addBook(Map<String, dynamic> data) async {
    final String id = data['id'] as String;
    await _firestore.collection('books').doc(id).set(data);
  }
}
