import 'package:e_amazon/utils/firebase_service.dart';
import 'package:e_amazon/utils/shared_preference.dart';
import 'package:e_amazon/widgets/default_button.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../routes/app_routes.dart';

class AddToCard extends StatefulWidget {
  @override
  _AddToCardState createState() => _AddToCardState();
}

class _AddToCardState extends State<AddToCard> {
  final fireStoreInstance = FirebaseFirestore.instance;
  final firebaseService = FirebaseService();
  late String userId;
  double totalPrice = 0;
  List<Map<String, dynamic>> cartItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    userId = SharedPreferenceHelper.getUserId() ?? "";
    _loadCartAndCalculate();
  }

  Future<void> _loadCartAndCalculate() async {
    try {
      final cartSnapshot =
          await fireStoreInstance
              .collection('saved_card')
              .doc(userId)
              .collection('products')
              .get();

      double newTotalPrice = 0;
      List<Map<String, dynamic>> tempCartItems = [];

      for (var doc in cartSnapshot.docs) {
        String productId = doc.id;
        Map<String, dynamic> cartData = doc.data();

        final productSnap =
            await fireStoreInstance.collection('products').doc(productId).get();

        if (productSnap.exists) {
          final product = productSnap.data()!;
          String priceString = product['price'].replaceAll(RegExp(r'[₹,]'), '');
          double price = double.tryParse(priceString) ?? 0;
          int count = cartData['count'] ?? 1;
          newTotalPrice += price * count;

          tempCartItems.add({
            "productId": productId,
            "product": product,
            "count": count,
          });
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
      bottomNavigationBar:
          (totalPrice > 0)
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
      appBar: AppBar(title: Text("Cart")),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : cartItems.isEmpty
              ? Center(child: Text("No products in cart"))
              : ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  final item = cartItems[index];
                  final product = item['product'];
                  final count = item['count'];
                  final productId = item['productId'];

                  final imageUrl = product['images'].first;
                  final price = product['price'];

                  return GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.productDetail,
                        arguments: {"id": product['id']},
                      );
                    },
                    child: ListTile(
                      leading: Image.network(
                        imageUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                      title: Text(
                        product['name'],
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      subtitle: Text(
                        price,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall?.copyWith(
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
                                  setState(() {
                                    isLoading = true;
                                  });
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
                                /*  setState(() {
                                  isLoading = true;
                                });*/
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
