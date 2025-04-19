import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../model/cart_data.dart';
import '../../model/product_data.dart';
import '../../model/user_data.dart';
import '../../routes/app_routes.dart';
import '../../utils/shared_preference.dart';

class ConfirmOrder extends StatefulWidget {
  final String? productId;
  final bool isFromCart;

  const ConfirmOrder({super.key, this.productId, required this.isFromCart});

  @override
  State<ConfirmOrder> createState() => _ConfirmOrderState();
}

class _ConfirmOrderState extends State<ConfirmOrder> {
  final fireStoreInstance = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;
  UserProfileModel? userProfile;
  List<CartItemModel> cartItems = [];
  double totalPrice = 0;
  bool isLoad = true;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadUserData();

    if (widget.productId != null) {
      await _loadSingleProduct();
    } else {
      await _loadCartItems();
    }

    setState(() {
      isLoad = false;
    });
  }

  Future<void> _loadUserData() async {
    if (user != null) {
      final doc = await fireStoreInstance.collection('users').doc(user!.uid).get();
      if (doc.exists) {
        userProfile = UserProfileModel.fromFirestore(doc.data()!, user!.uid);
      } else {
        userProfile = UserProfileModel(
          uid: user!.uid,
          name: user!.displayName ?? '',
          phone: user!.phoneNumber ?? '',
          address: '',
          postalCode: '',
        );
      }
    }
  }

  Future<void> _loadSingleProduct() async {
    final doc = await fireStoreInstance.collection('products').doc(widget.productId).get();
    if (doc.exists) {
      final productData = doc.data()!;
      final product = ProductModel.fromFirestore(productData, widget.productId!);

      final savedCardDoc = await fireStoreInstance
          .collection('saved_card')
          .doc(user!.uid)
          .collection('products')
          .doc(widget.productId)
          .get();

      final count = savedCardDoc.data()?['count']?.toInt() ?? 1;

      final cartItem = CartItemModel(
        productId: widget.productId!,
        product: product,
        count: count,
      );

      totalPrice = double.parse(product.price) * count;
      cartItems = [cartItem];
    }
  }

  Future<void> _loadCartItems() async {
    final snapshot = await fireStoreInstance
        .collection('saved_card')
        .doc(user!.uid)
        .collection('products')
        .get();

    totalPrice = 0;
    cartItems = [];

    for (var item in snapshot.docs) {
      final productId = item.id;
      final cartData = item.data();
      final productDoc = await fireStoreInstance.collection('products').doc(productId).get();

      if (productDoc.exists) {
        final productData = productDoc.data()!;
        final cartItem = CartItemModel.fromFirestore(
          productId: productId,
          cartData: cartData,
          productData: productData,
        );

        totalPrice += double.parse(cartItem.product.price) * cartItem.count;
        cartItems.add(cartItem);
      }
    }
  }

  Widget buildAddress() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Deliver to:", style: Theme.of(context).textTheme.headlineSmall),
          Text(userProfile?.name ?? '', style: Theme.of(context).textTheme.titleMedium),
          Text(userProfile?.address ?? '', style: Theme.of(context).textTheme.bodyMedium),
          Text(userProfile?.postalCode ?? '', style: Theme.of(context).textTheme.bodyMedium),
          Text(userProfile?.phone ?? '', style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget buildCartItems() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
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
              arguments: {"id": productId},
            );
          },
          child: ListTile(
            leading: CachedNetworkImage(
              imageUrl: imageUrl,
              width: 60.h,
              height: 60.h,
              fit: BoxFit.cover,
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
            title: Text(
              product.name,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            subtitle: Text(
              "Qty $count",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).primaryColor,
              ),
            ),
            trailing: Text(
              "₹${product.price}",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildPrice() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Price detail"),
          Divider(color: Colors.grey.shade300),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total amount"),
              Text(
                "₹${totalPrice.toStringAsFixed(2)}",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 15.sp,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoad) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Confirm Order")),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.grey.shade300, blurRadius: 0.5.r),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "\$${totalPrice.toStringAsFixed(2)}",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).primaryColor,
              ),
            ),
            ElevatedButton(
              onPressed: () {
              },
              child: Text(
                "Confirm Order",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildAddress(),
            SizedBox(height: 16.h),
            buildCartItems(),
            SizedBox(height: 16.h),
            buildPrice(),
          ],
        ),
      ),
    );
  }
}