import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:innerspace_booking_app/core/failures.dart';
import 'package:innerspace_booking_app/features/product/domain/entities/product.dart';
import 'package:innerspace_booking_app/features/product/domain/usecases/create_order_usecase.dart';
import 'package:innerspace_booking_app/features/product/domain/usecases/product_Usecases.dart';

part 'product_event.dart';
part 'product_state.dart';

class ProductBloc
    extends
        Bloc<
          ProductEvent,
          ProductState
        > {
  final GetProducts getBranches;
  final CreateOrder order;

  ProductBloc({
    required this.getBranches,
    required this.order,
  }) : super(
         ProductInitial(),
       ) {
    on<
      GetAllBranches
    >(
      _onGetAllBranches,
    );
    on<
      SearchBranchesEvent
    >(
      _onSearchBranches,
    );
    on<
      OrdersCreate
    >(
      _onCrateOrder,
    );
  }

  Future<
    void
  >
  _onGetAllBranches(
    GetAllBranches event,
    Emitter<
      ProductState
    >
    emit,
  ) async {
    emit(
      ProductLoading(),
    );
    final result = await getBranches();
    result.fold(
      (
        failure,
      ) => emit(
        ProductError(
          message: _mapFailureToMessage(
            failure,
          ),
        ),
      ),
      (
        branches,
      ) => emit(
        ProductLoaded.ProductLoaded(
          products: branches,
        ),
      ),
    );
  }

  Future<
    void
  >
  _onSearchBranches(
    SearchBranchesEvent event,
    Emitter<
      ProductState
    >
    emit,
  ) async {}
  Future<
    void
  >
  _onCrateOrder(
    OrdersCreate e,
    Emitter<
      ProductState
    >
    emit,
  ) async {
    await order.call(
      userId: e.userId,
      productId: e.productId,
    );
  }

  String _mapFailureToMessage(
    Failure failure,
  ) {
    if (failure
        is ServerFailure) {
      return failure.message.isNotEmpty
          ? failure.message
          : 'A server error occurred. Please try again.';
    } else if (failure
        is UnexpectedFailure) {
      return failure.message.isNotEmpty
          ? failure.message
          : 'An unexpected error occurred.';
    }
    return 'An unknown error occurred.';
  }
}
