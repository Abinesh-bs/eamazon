import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:e_amazon/routes/app_routes.dart';
import 'package:e_amazon/utils/firebase_service.dart';
import 'package:e_amazon/utils/reponsive_size.dart';
import 'package:e_amazon/utils/shared_preference.dart';
import 'package:e_amazon/utils/validator.dart';
import 'package:e_amazon/widgets/custom_form_field.dart';
import 'package:e_amazon/widgets/default_button.dart';
import 'package:firebase_cloud_firestore/firebase_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../model/product_data.dart';

class ProductDetails extends StatefulWidget {
  String productId;

  ProductDetails({super.key, required this.productId});

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  final firebaseService = FirebaseService();
  final fireStoreInstance = FirebaseFirestore.instance;
  int _currentIndex = 0;
  String price = "";
  String? userId;
  bool isInWishlist = false;
  bool savedCard = false;
  bool isLoad = true;
  final formKey = GlobalKey<FormState>();
  final userNameController = TextEditingController();
  final reviewController = TextEditingController();
  int rating = 5;

  @override
  void initState() {
    userId = SharedPreferenceHelper.getUserId() ?? "";
    super.initState();
    checkWishlist();
    checkSavedCard();
  }

  Future<void> _submitReview() async {
    if (formKey.currentState!.validate()) {
      await firebaseService.addOrUpdateReview(
        productId: widget.productId,
        userId: userId ?? "",
        userName: userNameController.text,
        review: reviewController.text,
        rating: rating.toString(),
      );
      userNameController.clear();
      reviewController.clear();
      setState(() {
        rating = 5;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Review submitted!')));
    }
  }

  Future<void> checkWishlist() async {
    if (userId != null && widget.productId.isNotEmpty) {
      final wishlistRef =
          FirebaseFirestore.instance
              .collection('wishlists')
              .doc(userId)
              .collection('products')
              .doc(widget.productId)
              .get();

      final doc = await wishlistRef;

      setState(() {
        isInWishlist = doc.exists;
      });
    }
  }

  checkSavedCard() async {
    final savedCardDoc =
        FirebaseFirestore.instance
            .collection('saved_card')
            .doc(userId)
            .collection('products')
            .doc(widget.productId)
            .get();
    final doc = await savedCardDoc;
    setState(() {
      savedCard = doc.exists;
      isLoad = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 8.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: Container(
                height: ResponsiveSize.isMobile(context) ? 35.h : 45.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25.r),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                child: DefaultButton(
                  color: Theme.of(context).colorScheme.primary,

                  text: savedCard ? "Remove from card" : "Add to card",
                  onPressed: () async {
                    if (userId != null) {
                      await firebaseService.addToCart(
                        userId: userId ?? "",
                        productId: widget.productId,
                        count: 1,
                      );
                    }
                    checkSavedCard();
                  },
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: DefaultButton(
                text: "Buy now",
                onPressed: () async {
                  if (userId != null) {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.confirmOrder,
                      arguments: {
                        "productId": widget.productId,
                        "isFromCart": false,
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream:
              FirebaseFirestore.instance
                  .collection('products')
                  .doc(widget.productId)
                  .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData && isLoad) {
              return Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data?.data() == null) {
              return Center(child: Text("No data found"));
            }
            final product = ProductModel.fromFirestore(
              snapshot.data!.data() as Map<String, dynamic>,
              snapshot.data!.id,
            );
            final imageUrls = product.images;
            final specs = product.specs;
            price = product.price;
            return Container(
              padding: EdgeInsets.only(top: 0.h),
              child: ListView(
                children: [
                  Stack(
                    children: [
                      CarouselSlider(
                        options: CarouselOptions(
                          height:
                              ResponsiveSize.isMobile(context) ? 250.h : 600.h,
                          autoPlay: true,
                          viewportFraction: 1,
                          onPageChanged: (index, reason) {
                            setState(() {
                              _currentIndex = index;
                            });
                          },
                        ),
                        items:
                            imageUrls.map((url) {
                              return Builder(
                                builder: (BuildContext context) {
                                  return CachedNetworkImage(
                                    imageUrl: url,
                                    fit: BoxFit.fitHeight,
                                    width: double.infinity,
                                  );
                                },
                              );
                            }).toList(),
                      ),
                      Positioned(
                        left: 15.w,
                        top: 15.h,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 5.w,
                              vertical: 5.h,
                            ),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 0.7.r,
                                  color: Colors.grey.shade500,
                                ),
                              ],
                              color: Colors.white,
                            ),
                            child: Icon(Icons.arrow_back),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 15.w,
                        top: 15.h,
                        child: GestureDetector(
                          onTap: () async {
                            if (userId != null) {
                              await firebaseService.toggleWishlist(
                                userId ?? "",
                                widget.productId,
                              );
                            }
                            checkWishlist();
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 5.w,
                              vertical: 5.h,
                            ),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 0.7.r,
                                  color: Colors.grey.shade500,
                                ),
                              ],
                              color: Colors.white,
                            ),
                            child: Icon(
                              Icons.favorite,
                              color: isInWishlist ? Colors.red : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children:
                              imageUrls.asMap().entries.map((entry) {
                                return Container(
                                  width: 5.w,
                                  height: 5.w,
                                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color:
                                        _currentIndex == entry.key
                                            ? Colors.black
                                            : Colors.grey.shade400,
                                  ),
                                );
                              }).toList(),
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          product.name,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        SizedBox(height: 10.h),
                        Text(product.description),
                        SizedBox(height: 10.h),
                        RichText(
                          text: TextSpan(
                            text: "₹${double.parse(product.price) - 500}",

                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                              color: Colors.red,
                              decoration: TextDecoration.lineThrough,
                              decorationStyle: TextDecorationStyle.solid,
                            ),
                            children: [
                              TextSpan(
                                text: " ₹${product.price}",
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),

                        if (specs != null) ...[
                          Divider(color: Colors.grey.shade400, height: 20.h),

                          Container(
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                            child: Text(
                              "Specification",
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children:
                                specs!.entries.map((entry) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                    ),
                                    child: RichText(
                                      text: TextSpan(
                                        text: '${entry.key}: ',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall?.copyWith(
                                          fontSize: 13.sp,
                                          color: Colors.grey.shade700,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: entry.value,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(fontSize: 13.sp),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                          ),
                        ],
                        if (product.reviews != null &&
                            product.reviews!.length > 0)
                          buildReviewSection(
                            product.rating,
                            product.reviews ?? [],
                          ),
                        SizedBox(height: 10.h),
                        Form(
                          key: formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Divider(
                                color: Colors.grey.shade400,
                                height: 20.h,
                              ),
                              SizedBox(height: 3.h),

                              Text(
                                'Write Review',
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              ),
                              SizedBox(height: 8.h),
                              CustomTextFormField(
                                hintText: 'Your Name',
                                controller: userNameController,

                                validator: (value) {
                                  return Validator.requiredField(value);
                                },
                              ),
                              CustomTextFormField(
                                controller: reviewController,
                                hintText: 'Your review',

                                maxLines: 3,
                                validator: (value) {
                                  return Validator.requiredField(value);
                                },
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 15.w,
                                  vertical: 8.h,
                                ),
                                child: DropdownButtonFormField<int>(
                                  value: rating,
                                  items:
                                      List.generate(5, (index) => index + 1)
                                          .map(
                                            (rating) => DropdownMenuItem(
                                              value: rating,
                                              child: Text(
                                                '$rating Star${rating > 1 ? 's' : ''}',
                                              ),
                                            ),
                                          )
                                          .toList(),
                                  onChanged:
                                      (value) =>
                                          setState(() => rating = value!),
                                  decoration: InputDecoration(
                                    labelText: 'Rating',
                                    border: OutlineInputBorder(),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade600,
                                      ),
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 15.h),
                              Align(
                                child: DefaultButton(
                                  onPressed: _submitReview,
                                  text: 'Submit Review',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildReviewSection(String ratings, List<Review> reviews) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: Colors.grey.shade400, height: 20.h),
        Text(
          "Reviews (${reviews.length})",
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
        SizedBox(height: 5.h),

        Row(
          children: [
            Row(
              children: List.generate(5, (index) {
                double rating = double.parse(ratings);
                IconData starIcon;
                if (index < rating.floor()) {
                  starIcon = Icons.star;
                } else if (index < rating) {
                  starIcon = Icons.star_half;
                } else {
                  starIcon = Icons.star_border;
                }
                return Icon(starIcon, color: Colors.amber, size: 20.sp);
              }),
            ),
            SizedBox(width: 8.w),
            Text(
              "${ratings} / 5",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        SizedBox(height: 5.h),
        Container(
          margin: EdgeInsets.symmetric(vertical: 8.h),
          padding: EdgeInsets.symmetric(horizontal: 8.h, vertical: 8.h),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5.r,
                offset: Offset(0, 0),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...List.generate(reviews!.length, (index) {
                final review = reviews[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          review.userName,
                          style: Theme.of(
                            context,
                          ).textTheme.headlineSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(width: 5.w),
                        Text(
                          "(${review.rating})",
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                        Icon(Icons.star, color: Colors.amber, size: 18),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      review.review,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),

                      maxLines: 2,

                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}

class ProductData {
  final String review;
  final double rating;
  final int reviewCount;

  ProductData({
    required this.review,
    required this.rating,
    required this.reviewCount,
  });
}
