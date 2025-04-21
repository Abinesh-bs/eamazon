class ProductModel {
  final String id;
  final String name;
  final String description;
  final String price;
  final List<String> images;
  final String categoryId;
  final String categoryName;
  final Map<String, String>? specs;
  final String rating;
  final List<Review>? reviews;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.images,
    required this.categoryId,
    required this.categoryName,
    this.specs,
    this.reviews,
    required this.rating,
  });

  factory ProductModel.fromFirestore(
    Map<String, dynamic> data,
    String documentId,
  ) {
    final categoryMap = data['category'] as Map<String, dynamic>? ?? {};
    final categoryId =
        categoryMap.isNotEmpty ? categoryMap.keys.first?.toString() ?? '' : '';
    final categoryName =
        categoryMap.isNotEmpty
            ? categoryMap.values.first?.toString() ?? ''
            : '';
    /*final categoryId = categoryMap.keys.first.toString() ?? '';
    final categoryName = categoryMap.values.first?.toString() ?? '';*/

    final specsData = data['specs'] as Map<String, dynamic>?;
    final specs = specsData?.map(
      (key, value) => MapEntry(key, value.toString()),
    );
    final reviewsData = List<Map<String, dynamic>>.from(data['reviews'] ?? []);

    return ProductModel(
      id: documentId,
      name: data['name']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      price: data['price'],
      images: List<String>.from(data['images'] ?? []),
      categoryId: categoryId,
      categoryName: categoryName,
      specs: specs,
      reviews: reviewsData.map((r) => Review.fromMap(r)).toList(),
      //review: data['review']?.toString() ?? '',
      rating: data['rating'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'images': images,
      'category': {categoryId: categoryName},
      'specs': specs,
      'reviews': reviews,
      //'review': review,
      'rating': rating,
    };
  }
}

class Review {
  final String userId;
  final String userName;
  final String review;
  final String rating;

  Review({
    required this.userId,
    required this.userName,
    required this.review,
    required this.rating,
  });

  factory Review.fromMap(Map<String, dynamic> data) {
    return Review(
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      review: data['review'] ?? '',
      rating: data['rating'] ?? '',
    );
  }
}
