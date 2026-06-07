import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kitap_kiralama/models/book.dart';
import 'package:kitap_kiralama/models/order_record.dart';

class UserRepository {
  UserRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String get _uid {
    final User? user = _auth.currentUser;
    if (user == null) {
      throw StateError('Kullanici oturumu yok');
    }
    return user.uid;
  }

  DocumentReference<Map<String, dynamic>> get _cartDoc =>
      _firestore.collection('users').doc(_uid).collection('state').doc('cart');

  CollectionReference<Map<String, dynamic>> get _ordersCol =>
      _firestore.collection('users').doc(_uid).collection('orders');

  Stream<List<String>> watchCartIds() {
    return _cartDoc.snapshots().map((DocumentSnapshot<Map<String, dynamic>> s) {
      final Map<String, dynamic>? data = s.data();
      if (data == null) return <String>[];
      final List<dynamic> ids =
          (data['bookIds'] as List<dynamic>?) ?? <dynamic>[];
      return ids.map((dynamic e) => e.toString()).toList();
    });
  }

  Future<void> setCart(List<String> bookIds) async {
    await _cartDoc.set(<String, dynamic>{'bookIds': bookIds});
  }

  Stream<List<OrderRecord>> watchOrders(Map<String, Book> booksById) {
    return _ordersCol.orderBy('createdAt', descending: true).snapshots().map((
      QuerySnapshot<Map<String, dynamic>> snap,
    ) {
      return snap.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> d) {
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
    });
  }

  Future<void> placeOrder(OrderRecord order) async {
    await _ordersCol.doc(order.orderCode).set(<String, dynamic>{
      'orderCode': order.orderCode,
      'bookIds': order.items.map((Book b) => b.id).toList(),
      'totalPrice': order.totalPrice,
      'createdAt': Timestamp.fromDate(order.createdAt),
      'status': 'Onay Bekliyor',
      'userId': _uid,
      'userEmail': _auth.currentUser?.email ?? '',
    });
    await setCart(<String>[]);
  }
}
