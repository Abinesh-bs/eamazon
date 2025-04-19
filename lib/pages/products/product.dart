import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_amazon/routes/app_routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_amazon/utils/reponsive_size.dart';
import 'package:e_amazon/utils/shared_preference.dart';
import 'package:e_amazon/widgets/custom_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../model/product_data.dart';
import '../../provider/provider.dart';
import '../../widgets/default_button.dart';

class Product extends ConsumerStatefulWidget {
  const Product({super.key});

  @override
  ConsumerState<Product> createState() => _ProductState();
}

class _ProductState extends ConsumerState<Product> {
  final fireStoreInstance = FirebaseFirestore.instance;
  String searchQuery = '';
  final focusScope = FocusNode();
  List selectedCategory = [];
  final Map<String, String> productCategories = {
    '1': 'Shirts',
    '2': 'Mobile',
    '3': 'Laptop',
    '4': 'Camera',
    '5': 'Watches',
  };

  @override
  initState() {
    selectedCategory = SharedPreferenceHelper.getCategories() ?? [];
    super.initState();
  }

  Future<List<ProductModel>> _fetchForYouProducts() async {
    try {
      final snapshot =
          await fireStoreInstance.collection('products').limit(10).get();
      return snapshot.docs
          .map((doc) {
            try {
              return ProductModel.fromFirestore(doc.data(), doc.id);
            } catch (e) {
              print('Error parsing For You product ${doc.id}: $e');
              return null;
            }
          })
          .where(
            (product) =>
                product != null &&
                product.name.isNotEmpty &&
                product.images.isNotEmpty,
          )
          .cast<ProductModel>()
          .toList();
    } catch (e) {
      print('Error fetching For You products: $e');
      return [];
    }
  }

  Widget _buildForYouSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Text(
            'For You',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 150.h,
          child: FutureBuilder<List<ProductModel>>(
            future: _fetchForYouProducts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError ||
                  !snapshot.hasData ||
                  snapshot.data!.isEmpty) {
                return const Center(child: Text('No recommended products'));
              }

              final products = snapshot.data!;
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  final imageUrl =
                      product.images.isNotEmpty ? product.images.first : '';

                  return GestureDetector(
                    onTap: () {
                      focusScope.unfocus();
                      Navigator.pushNamed(
                        context,
                        AppRoutes.productDetail,
                        arguments: {"id": product.id},
                      );
                    },
                    child: Container(
                      width: 120.w,
                      margin: EdgeInsets.only(right: 10.w),
                      child: Card(
                        elevation: 0.9,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(10.r),
                              ),
                              child: CachedNetworkImage(
                                imageUrl: imageUrl,
                                height: 80.h,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                placeholder:
                                    (context, url) =>
                                        const CircularProgressIndicator(),
                                errorWidget:
                                    (context, url, error) =>
                                        const Icon(Icons.error),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    product.description,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: Colors.grey.shade600),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    '₹${product.price}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.headlineSmall?.copyWith(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 13.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        SizedBox(height: 16.h),
      ],
    );
  }

  buildCategory(setState) {
    final globalProvider = ref.watch(globalNotifierProvider);
    return showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SizedBox(
              height: 400.h,
              width: MediaQuery.sizeOf(context).width,
              child: Scaffold(
                bottomNavigationBar: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 15.w,
                    vertical: 8.h,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: Container(
                          height: 35.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25.r),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          child: DefaultButton(
                            color: Theme.of(context).colorScheme.primary,

                            text: "Cancel",
                            onPressed: () async {
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: DefaultButton(
                          text: "Apply",
                          onPressed: () async {
                            focusScope.unfocus();

                            SharedPreferenceHelper.setCategories(
                              globalProvider.selectedCategories,
                            );
                            setState(() {
                              selectedCategory =
                                  SharedPreferenceHelper.getCategories() ?? [];
                            });

                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                appBar: AppBar(
                  scrolledUnderElevation: 0,
                  elevation: 0,
                  title: Row(
                    children: [
                      Text(
                        'Filter',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Spacer(),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 2.5.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade400,
                                blurRadius: 0.5.r,
                              ),
                            ],
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            size: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.5.w),
                    ],
                  ),
                  bottom: PreferredSize(
                    preferredSize: Size.fromHeight(1.h),
                    child: Divider(color: Colors.grey.shade300, height: 1.h),
                  ),
                ),
                body: ListView(
                  padding: EdgeInsets.symmetric(horizontal: 5.w),
                  children:
                      productCategories.entries.map((entry) {
                        return CheckboxListTile(
                          side: BorderSide(color: Colors.grey.shade600),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                          ),
                          title: Text(entry.value),
                          value: globalProvider.selectedCategories.contains(
                            entry.key,
                          ),
                          onChanged: (bool? selected) {
                            setState(() {
                              if (selected == true) {
                                globalProvider.selectedCategories.add(
                                  entry.key,
                                );
                              } else {
                                globalProvider.selectedCategories.remove(
                                  entry.key,
                                );
                              }
                            });
                          },
                        );
                      }).toList(),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            SizedBox(
              width: MediaQuery.sizeOf(context).width * 0.92,
              height: ResponsiveSize.isMobile(context) ? 55.h : 70.h,
              child: CustomTextFormField(
                hintText: "Search",
                focusScope: focusScope,
                onChanged: (value) {
                  setState(() {
                    searchQuery = value.trim().toLowerCase();
                  });
                },
              ),
            ),
            GestureDetector(
              onTap: () async {
                await buildCategory(setState);
                selectedCategory = SharedPreferenceHelper.getCategories() ?? [];
                setState(() {});
              },
              child: Icon(Icons.filter_list),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: GestureDetector(
          onTap: () {
            focusScope.unfocus();
          },
          child: Column(
            children: [
              _buildForYouSection(),
              StreamBuilder(
                stream: fireStoreInstance.collection('products').snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final products =
                      snapshot.data!.docs
                          .map(
                            (doc) => ProductModel.fromFirestore(
                              doc.data() as Map<String, dynamic>,
                              doc.id,
                            ),
                          )
                          .where((product) {
                            final matchesSearch = product.name
                                .toLowerCase()
                                .contains(searchQuery);
                            final matchesCategory =
                                selectedCategory.isEmpty ||
                                selectedCategory.contains(product.categoryId);
                            return matchesSearch && matchesCategory;
                          })
                          .toList();
                  if (products.isEmpty) {
                    return Center(child: Text("No product found"));
                  }
                  return ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      final imageList = product.images;
                      final imageUrl =
                          imageList.isNotEmpty ? imageList.first : '';
                      print(imageUrl);
                      return GestureDetector(
                        onTap: () {
                          focusScope.unfocus();
                          Navigator.pushNamed(
                            context,
                            AppRoutes.productDetail,
                            arguments: {"id": product.id},
                          );
                        },
                        child: ListTile(
                          leading: CachedNetworkImage(
                            imageUrl: imageUrl,
                            width:
                                ResponsiveSize.isMobile(context) ? 60.w : 100.w,
                            height:
                                ResponsiveSize.isMobile(context) ? 60.h : 150.h,
                            fit: BoxFit.cover,
                            progressIndicatorBuilder:
                                (context, url, downloadProgress) =>
                                    CircularProgressIndicator(
                                      value: downloadProgress.progress,
                                    ),
                            errorWidget:
                                (context, url, error) => Icon(Icons.error),
                          ),
                          title: Text(
                            product.name,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          subtitle: Text(
                            product.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey.shade600),
                          ),
                          trailing: Text(
                            "₹${product.price.toString()}",
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
