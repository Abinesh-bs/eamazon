import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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

  String price = '';
  String userName = '';
  String phoneNumber = '';
  String address = '';
  String postalCode = '';
  int count = 1;
  String? userId;
  bool isLoad = true;
  double totalPrice = 0;
  List<Map<String, dynamic>> cartProducts = [];

  @override
  void initState() {
    super.initState();
    userId = SharedPreferenceHelper.getUserId() ?? "";
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadUserData();

    if (widget.productId != null) {
      await _loadSingleProduct();
    } else {
      await _loadCartProducts();
    }

    setState(() {
      isLoad = false;
    });
  }

  Future<void> _loadUserData() async {
    if (user != null) {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user!.uid)
              .get();
      final data = doc.data();
      if (data != null) {
        userName = data['name'] ?? user!.displayName ?? '';
        phoneNumber = data['phone'] ?? user!.phoneNumber ?? '';
        address = data['address'] ?? '';
        postalCode = data['postal_code'] ?? '';
      }
    }
  }

  Future<void> _loadSingleProduct() async {
    final doc =
        await fireStoreInstance
            .collection('products')
            .doc(widget.productId)
            .get();
    final productData = doc.data();

    if (productData != null) {
      String cleaned = productData['price'].replaceAll(RegExp(r'[₹,]'), '');
      double cleanPrice = double.tryParse(cleaned) ?? 0;

      final savedCardDoc =
          await fireStoreInstance
              .collection('saved_card')
              .doc(userId)
              .collection('products')
              .doc(widget.productId)
              .get();

      count = savedCardDoc.data()?['count'] ?? 1;
      totalPrice = cleanPrice * count;

      cartProducts = [
        {"product": productData, "count": count, "id": widget.productId},
      ];
    }
  }

  Future<void> _loadCartProducts() async {
    final snapshot =
        await fireStoreInstance
            .collection('saved_card')
            .doc(userId)
            .collection('products')
            .get();

    totalPrice = 0;
    for (var item in snapshot.docs) {
      var productId = item.id;
      var productCount = item['count'] ?? 1;

      var productDoc =
          await fireStoreInstance.collection('products').doc(productId).get();
      var productData = productDoc.data();

      if (productData != null) {
        String cleaned = productData['price'].replaceAll(RegExp(r'[₹,]'), '');
        double cleanPrice = double.tryParse(cleaned) ?? 0;
        totalPrice += cleanPrice * productCount;

        cartProducts.add({
          "product": productData,
          "count": productCount,
          "id": productId,
        });
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
          Text(userName, style: Theme.of(context).textTheme.titleMedium),
          Text(address, style: Theme.of(context).textTheme.bodyMedium),
          Text(postalCode, style: Theme.of(context).textTheme.bodyMedium),
          Text(phoneNumber, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget buildCartItems() {
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: cartProducts.length,
      itemBuilder: (context, index) {
        var item = cartProducts[index];
        var product = item['product'];
        var count = item['count'];
        var productId = item['id'];
        var imageUrl = product['images'].first;

        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.productDetail,
              arguments: {"id": productId},
            );
          },
          child: ListTile(
            leading: Image.network(
              imageUrl,
              width: 60.h,
              height: 60.h,
              fit: BoxFit.cover,
            ),
            title: Text(
              product['name'],
              style: Theme.of(context).textTheme.titleMedium,
            ),
            subtitle: Text(
              "Qty $count",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).primaryColor,
              ),
            ),
            trailing: Text(
              product['price'],
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
          Text("Price detail"),
          Divider(color: Colors.grey.shade300),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Total amount"),
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
              "₹${totalPrice.toStringAsFixed(2)}",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).primaryColor,
              ),
            ),
            ElevatedButton(
              onPressed: () {},
              child: Text(
                "Confirm Order",
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(color: Colors.white),
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
