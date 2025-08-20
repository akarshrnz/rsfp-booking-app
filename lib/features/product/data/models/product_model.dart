

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:innerspace_booking_app/features/product/domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required String id,
    required String name,
    required num price,
   
    required String description,
    required String image,
  }) : super(
          id: id,
          name: name,
          price: price,
          description: description,
          image: image,
        );

          factory ProductModel.fromMap(DocumentSnapshot snap) {
            final map = snap.data() as Map<String, dynamic>;
    return ProductModel(
      id:snap.id,
      name: map['name'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      image: map['image']??"",
      description: map['description']??"",
    );}

  

  

  Map<String, dynamic> toDocument() {
    return {
      'name': name,
     
      'price': price,
     
      'description': description,
     
      'image': image,
    };
  }
}


// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:innerspace_booking_app/features/branch/domain/entities/branch.dart';

// class ProductModel extends Product {
//   const ProductModel({
//     required String id,
//     required String name,
//     required num price,
   
//     required String description,
//     required String image,
//   }) : super(
//           id: id,
//           name: name,
//           price: price,
//           description: description,
//           image: image,
//         );

//           factory ProductModel.fromMap(Map<String, dynamic> map, String id) {
//     return ProductModel(
//       id: id,
//       name: map['name'] ?? '',
//       price: (map['price'] ?? 0).toDouble(),
//       image: map['image'],
//       description: map['description'],
//     );}

//   factory ProductModel.fromSnapshot(DocumentSnapshot snap) {
//     final data = snap.data() as Map<String, dynamic>;
//     return ProductModel(
//       id: snap.id,
//       name: data['name'] ?? '',
//       image: data['image'] ?? '',
//       location: data['location'] ?? '',
//       city: data['city'] ?? '',
//       price: data['price'] ?? 0,
//       latitude: data['latitude'] ?? 0,
//       longitude: data['longitude'] ?? 0,
//       address: data['address'] ?? '',
//       description: data['description'] ?? '',
//       amenities: List<String>.from(data['amenities'] ?? []),
//       operatingHours: Map<String, String>.from(data['operatingHours'] ?? {}),
//       imageUrls: List<String>.from(data['imageUrls'] ?? []),
//     );
//   }

  

//   Map<String, dynamic> toDocument() {
//     return {
//       'name': name,
//       'location': location,
//       'city': city,
//       'price': price,
//       'latitude': latitude,
//       'longitude': longitude,
//       'address': address,
//       'description': description,
//       'amenities': amenities,
//       'operatingHours': operatingHours,
//       'imageUrls': imageUrls,
//       'image': image,
//     };
//   }
// }
