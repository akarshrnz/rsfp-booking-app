import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:innerspace_booking_app/core/constants.dart';
import 'package:innerspace_booking_app/features/product/data/models/order.dart';


class FirestoreService {
  final _db = FirebaseFirestore.instance;

 

  Future<void> createDummyProduct() async {
    final ref = _db.collection('products').doc();
    await ref.set({
      'name': 'Samsung S24 Ultra',
      'price': (100 + (DateTime.now().millisecondsSinceEpoch % 500)) * 1.0,
      'image': null,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> createOrder({required String productId}) async {
    final ref = _db.collection('orders').doc();
    await ref.set({
      'userId': dummyUserId,
      'productId': productId,
      'status': 'pending',
      'barcode': ref.id,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<OrderModel>> userOrdersStream(String userId) {
    return _db
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => OrderModel.fromMap(d.data(), d.id)).toList());
  }

  Stream<OrderModel> orderStream(String orderId) {
    return _db.collection('orders').doc(orderId).snapshots().map((d) => OrderModel.fromMap(d.data() as Map<String, dynamic>, d.id));
  }

  Future<bool> updateOrderStatusByBarcode(String barcode, String status) async {
    final ref = _db.collection('orders').doc(barcode);
    final snap = await ref.get();
    if (!snap.exists) return false;
    await ref.update({'status': status});
    return true;
  }
}
