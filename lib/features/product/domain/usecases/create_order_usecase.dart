
import 'package:innerspace_booking_app/features/product/domain/repositories/product_repository.dart';

class CreateOrder {
  final BranchRepository repository;

  CreateOrder(this.repository);

   Future<void> call({required String userId, required String productId}) => repository.createOrder(userId: userId, productId: productId);

}