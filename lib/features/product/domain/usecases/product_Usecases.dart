import 'package:dartz/dartz.dart';
import 'package:innerspace_booking_app/core/failures.dart';
import 'package:innerspace_booking_app/features/product/domain/entities/product.dart';
import 'package:innerspace_booking_app/features/product/domain/repositories/product_repository.dart';

class GetProducts {
  final BranchRepository repository;

  GetProducts(this.repository);

  Future<Either<Failure, List<Product>>> call() async {
    return await repository.getBranches();
  }
}