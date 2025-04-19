class ProductModel {
  final String id;
  final String name;
  final String description;
  final String price;
  final List<String> images;
  final String categoryId;
  final String categoryName;
  final Map<String, String>? specs;
  final String review;
  final String rating;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.images,
    required this.categoryId,
    required this.categoryName,
    this.specs,
    required this.review,
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

    return ProductModel(
      id: documentId,
      name: data['name']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      price: data['price'],
      images: List<String>.from(data['images'] ?? []),
      categoryId: categoryId,
      categoryName: categoryName,
      specs: specs,
      review: data['review']?.toString() ?? '',
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
      'review': review,
      'rating': rating,
    };
  }
}
