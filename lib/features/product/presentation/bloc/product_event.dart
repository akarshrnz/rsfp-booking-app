part of 'product_bloc.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object> get props => [];
}

class GetAllBranches extends ProductEvent {}

class SearchBranchesEvent extends ProductEvent {
  final String query;

  const SearchBranchesEvent(this.query);

  @override
  List<Object> get props => [query];
}

class OrdersCreate extends ProductEvent {
  final String userId;
  final String productId;
  OrdersCreate(this.userId, this.productId);
  @override
  List<Object> get props => [userId,productId];
}