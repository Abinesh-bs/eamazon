import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_amazon/utils/shared_preference.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../model/wishlist_data.dart';
import '../routes/app_routes.dart';
import '../utils/reponsive_size.dart';

class Wishlists extends StatefulWidget {
  const Wishlists({super.key});

  @override
  _WishlistState createState() => _WishlistState();
}

class _WishlistState extends State<Wishlists> {
  final fireStoreInstance = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Wishlist")),
      body: FutureBuilder<QuerySnapshot>(
        future: fireStoreInstance
            .collection('wishlists')
            .doc(SharedPreferenceHelper.getUserId() ?? "")
            .collection('products')
            .get(),
        builder: (context, wishlistSnapshot) {
          if (wishlistSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (wishlistSnapshot.hasError) {
            return Center(child: Text('Error: ${wishlistSnapshot.error}'));
          }

          if (!wishlistSnapshot.hasData || wishlistSnapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No products in wishlist"));
          }

          return ListView.builder(
            itemCount: wishlistSnapshot.data!.docs.length,
            itemBuilder: (context, index) {
              String productId = wishlistSnapshot.data!.docs[index].id;

              return StreamBuilder<DocumentSnapshot>(
                stream: fireStoreInstance
                    .collection("products")
                    .doc(productId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const Center(child: Text("Product not found"));
                  }

                  final productData = snapshot.data!.data() as Map<String, dynamic>;
                  final wishlistItem = WishlistItemModel.fromFirestore(
                    productId: productId,
                    productData: productData,
                  );
                  final product = wishlistItem.product;
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
                      product.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    trailing: Text(
                      "₹${product.price}",
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontSize: 13.sp,
                      ),
                    ),
                  ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}