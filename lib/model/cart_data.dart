import 'package:e_amazon/model/product_data.dart';

class CartItemModel {
  final String productId;
  final ProductModel product;
  final int count;

  CartItemModel({
    required this.productId,
    required this.product,
    required this.count,
  });

  factory CartItemModel.fromFirestore({
    required String productId,
    required Map<String, dynamic> cartData,
    required Map<String, dynamic> productData,
  }) {
    return CartItemModel(
      productId: productId,
      product: ProductModel.fromFirestore(productData, productId),
      count: (cartData['count'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'count': count,
    };
  }
}