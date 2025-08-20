import 'package:dartz/dartz.dart';
import 'package:innerspace_booking_app/core/failures.dart';
import 'package:innerspace_booking_app/features/product/domain/entities/product.dart';

abstract class BranchRepository {
  Future<Either<Failure, List<Product>>> getBranches();
    Future<void> createOrder({required String userId, required String productId});

}