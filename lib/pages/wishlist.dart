import 'package:e_amazon/utils/shared_preference.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../routes/app_routes.dart';

class Wishlists extends StatefulWidget {
  @override
  _WishlistState createState() => _WishlistState();
}

class _WishlistState extends State<Wishlists> {
  final fireStoreInstance = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Wishlist")),
      body: FutureBuilder<QuerySnapshot>(
        future:
            fireStoreInstance
                .collection('wishlists')
                .doc(SharedPreferenceHelper.getUserId() ?? "")
                .collection('products')
                .get(),
        builder: (context, wishlistSnapshot) {
          if (wishlistSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (wishlistSnapshot.hasError) {
            return Center(child: Text('Error: ${wishlistSnapshot.error}'));
          }

          if (!wishlistSnapshot.hasData ||
              wishlistSnapshot.data!.docs.isEmpty) {
            return Center(child: Text("No products in wishlist"));
          }

          return ListView.builder(
            itemCount: wishlistSnapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var productData =
                  wishlistSnapshot.data!.docs[index].data()
                      as Map<String, dynamic>;
              String productId = wishlistSnapshot.data!.docs[index].id;

              return StreamBuilder(
                stream:
                    fireStoreInstance
                        .collection("products")
                        .doc(productId)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: Text("No products in wishlist"));
                  }
                  final product = snapshot.data?.data() as Map<String, dynamic>;
                  final imageUrl = product['images'].first;
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
                        product['description'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      trailing: Text(
                        "\$${product['price'].toString()}",
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall?.copyWith(
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
