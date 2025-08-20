import 'package:dartz/dartz.dart';
import 'package:innerspace_booking_app/core/failures.dart';
import 'package:innerspace_booking_app/features/product/data/datasources/product_remote_data_source.dart';
import 'package:innerspace_booking_app/features/product/data/models/product_model.dart';
import 'package:innerspace_booking_app/features/product/domain/entities/product.dart';
import 'package:innerspace_booking_app/features/product/domain/repositories/product_repository.dart';

class BranchRepositoryImpl implements BranchRepository {
  final BranchRemoteDataSource remoteDataSource;

  BranchRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<ProductModel>>> getBranches() async {
    try {
      final branches = await remoteDataSource.getBranches();
      return Right(branches);
    } on Failure catch (failure) {
      return Left(failure);
    }
  }

    @override
  Future<void> createOrder({required String userId, required String productId}) => remoteDataSource.createOrder(userId: userId, productId: productId);



 
}
