import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_amazon/utils/firebase_service.dart';
import 'package:e_amazon/utils/shared_preference.dart';
import 'package:e_amazon/widgets/default_button.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../model/cart_data.dart';
import '../routes/app_routes.dart';
import '../utils/reponsive_size.dart';

class AddToCard extends StatefulWidget {
  const AddToCard({super.key});

  @override
  _AddToCardState createState() => _AddToCardState();
}

class _AddToCardState extends State<AddToCard> {
  final fireStoreInstance = FirebaseFirestore.instance;
  final firebaseService = FirebaseService();
  late String userId;
  double totalPrice = 0;
  List<CartItemModel> cartItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    userId = SharedPreferenceHelper.getUserId() ?? "";
    _loadCartAndCalculate();
  }

  Future<void> _loadCartAndCalculate() async {
    try {
      final cartSnapshot = await fireStoreInstance
          .collection('saved_card')
          .doc(userId)
          .collection('products')
          .get();

      double newTotalPrice = 0;
      List<CartItemModel> tempCartItems = [];

      for (var doc in cartSnapshot.docs) {
        String productId = doc.id;
        Map<String, dynamic> cartData = doc.data();

        final productSnap =
        await fireStoreInstance.collection('products').doc(productId).get();

        if (productSnap.exists) {
          final productData = productSnap.data()!;
          final cartItem = CartItemModel.fromFirestore(
            productId: productId,
            cartData: cartData,
            productData: productData,
          );

          newTotalPrice += double.parse(cartItem.product.price) * cartItem.count;
          tempCartItems.add(cartItem);
        }
      }

      setState(() {
        totalPrice = newTotalPrice;
        cartItems = tempCartItems;
        isLoading = false;
      });
    } catch (e) {
      print("Error loading cart: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: (totalPrice > 0)
          ? Row(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Total: ₹${totalPrice.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: DefaultButton(
              text: "Buy Now",
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.confirmOrder,
                  arguments: {"isFromCart": true},
                );
              },
            ),
          ),
        ],
      )
          : null,
      appBar: AppBar(title: const Text("Cart")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : cartItems.isEmpty
          ? const Center(child: Text("No products in cart"))
          : ListView.builder(
        itemCount: cartItems.length,
        itemBuilder: (context, index) {
          final cartItem = cartItems[index];
          final product = cartItem.product;
          final count = cartItem.count;
          final productId = cartItem.productId;
          final imageUrl = product.images.isNotEmpty ? product.images.first : '';

          return GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.productDetail,
                arguments: {"id": product.id},
              );
            },
            child: ListTile(
              leading: CachedNetworkImage(
                imageUrl: imageUrl,
                width: ResponsiveSize.isMobile(context) ? 60.w : 100.w,
                height: ResponsiveSize.isMobile(context) ? 60.h : 150.h,
                fit: BoxFit.cover,
                placeholder: (context, url) => const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
              title: Text(
                product.name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              subtitle: Text(
                '₹${product.price}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontSize: 13.sp,
                ),
              ),
              trailing: Container(
                width: 70.w,
                padding: EdgeInsets.symmetric(
                  horizontal: 5.w,
                  vertical: 5.h,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.grey.shade500),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (count > 0) {
                          firebaseService.decrementCartItem(
                            userId: userId,
                            productId: productId,
                          );
                          _loadCartAndCalculate();
                        }
                      },
                      child: Icon(
                        Icons.remove,
                        color: Colors.grey.shade600,
                        size: 18,
                      ),
                    ),
                    Text(
                      count.toString(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    GestureDetector(
                      onTap: () {
                        firebaseService.incrementCartItem(
                          userId: userId,
                          productId: productId,
                        );
                        _loadCartAndCalculate();
                      },
                      child: Icon(
                        Icons.add,
                        color: Colors.grey.shade600,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}