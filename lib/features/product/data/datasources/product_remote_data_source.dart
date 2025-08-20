import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:innerspace_booking_app/core/app_constants.dart';
import 'package:innerspace_booking_app/core/failures.dart';
import 'package:innerspace_booking_app/features/product/data/models/product_model.dart';
import 'package:fluttertoast/fluttertoast.dart';


abstract class BranchRemoteDataSource {
  Future<List<ProductModel>> getBranches();
  Future<void> createOrder({required String userId, required String productId});
}

class BranchRemoteDataSourceImpl implements BranchRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  BranchRemoteDataSourceImpl({
    required this.firestore,
    required this.storage,
  });

  @override
  Future<List<ProductModel>> getBranches() async {
    try {
      final snapshot = await firestore
          .collection(AppConstants.productCollection)
          .get();

      return snapshot.docs
          .map((doc) => ProductModel.fromMap(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerFailure(message: e.message ?? 'Firestore error');
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }
  @override
  Future<void> createOrder({required String userId, required String productId}) async {
    try {
    

      final ref = firestore.collection(AppConstants.orderCollection).doc();
    await ref.set({'userId': userId, 'productId': productId, 'status': 'pending', 'barcode': ref.id, 'createdAt': FieldValue.serverTimestamp()});
  

    } on FirebaseException catch (e) {
      throw ServerFailure(message: e.message ?? 'Firestore error');
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }



 
}
