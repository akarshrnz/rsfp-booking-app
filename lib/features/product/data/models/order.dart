class OrderModel {
  final String id;
  final String userId;
  final String productId;
  final String status;
  final String barcode;

  OrderModel({required this.id, required this.userId, required this.productId, required this.status, required this.barcode});

  factory OrderModel.fromMap(Map<String, dynamic> map, String id) {
    return OrderModel(
      id: id,
      userId: map['userId'] ?? '',
      productId: map['productId'] ?? '',
      status: map['status'] ?? 'pending',
      barcode: map['barcode'] ?? id,
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'productId': productId,
        'status': status,
        'barcode': barcode,
      };
}
