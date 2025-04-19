import 'package:e_amazon/provider.dart';
import 'package:e_amazon/routes/app_routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_amazon/utils/reponsive_size.dart';
import 'package:e_amazon/utils/shared_preference.dart';
import 'package:e_amazon/widgets/custom_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
    '4': 'Shoes',
    '5': 'Watches',
  };

  @override
  initState() {
    selectedCategory = SharedPreferenceHelper.getCategories() ?? [];
    super.initState();
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
                  automaticallyImplyLeading: false,
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
      body: GestureDetector(
        onTap: () {
          focusScope.unfocus();
        },
        child: StreamBuilder(
          stream: fireStoreInstance.collection('products').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final products =
                snapshot.data!.docs.where((doc) {
                  final name = doc['name'].toString().toLowerCase();
                  final categoryMap = doc['category'] as Map;
                  final categoryId = categoryMap.keys.first.toString();

                  final matchesSearch = name.contains(searchQuery);
                  final matchesCategory =
                      selectedCategory.isEmpty ||
                      selectedCategory.contains(categoryId);

                  return matchesSearch && matchesCategory;
                }).toList();
            if (products.isEmpty) {
              return Center(child: Text("No product found"));
            }
            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                final imageList = product['images'] as List<dynamic>? ?? [];
                final imageUrl =
                    imageList.isNotEmpty
                        ? imageList.first
                        : 'https://via.placeholder.com/60';

                return GestureDetector(
                  onTap: () {
                    focusScope.unfocus();
                    Navigator.pushNamed(
                      context,
                      AppRoutes.productDetail,
                      arguments: {"id": product['id']},
                    );
                  },
                  child: ListTile(
                    leading: Image.network(
                      imageUrl,
                      width: ResponsiveSize.isMobile(context) ? 60.w : 100.w,
                      height: ResponsiveSize.isMobile(context) ? 60.h : 150.h,
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
        ),
      ),
    );
  }
}
