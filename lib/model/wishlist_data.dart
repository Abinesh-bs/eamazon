import 'package:e_amazon/model/product_data.dart';

class WishlistItemModel {
  final String productId;
  final ProductModel product;

  WishlistItemModel({
    required this.productId,
    required this.product,
  });

  factory WishlistItemModel.fromFirestore({
    required String productId,
    required Map<String, dynamic> productData,
  }) {
    return WishlistItemModel(
      productId: productId,
      product: ProductModel.fromFirestore(productData, productId),
    );
  }
}