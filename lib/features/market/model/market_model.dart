class MerchantModel {
  final String id, name, category, location, priceRange;
  final double rating;
  final int reviewCount, deliveryMinutes, deliveryFee;
  final String emoji;
  const MerchantModel({required this.id, required this.name, required this.category,
    required this.location, required this.priceRange, required this.rating,
    required this.reviewCount, required this.deliveryMinutes,
    required this.deliveryFee, required this.emoji});

  factory MerchantModel.fromJson(Map<String, dynamic> json) => MerchantModel(
    id: '${json['id']}',
    name: json['name'] ?? '',
    category: json['category'] ?? '',
    location: json['location'] ?? '',
    priceRange: json['price_range'] ?? json['priceRange'] ?? 'F',
    rating: double.tryParse('${json['rating'] ?? 0}') ?? 0,
    reviewCount: int.tryParse('${json['review_count'] ?? json['reviewCount'] ?? 0}') ?? 0,
    deliveryMinutes: int.tryParse('${json['delivery_minutes'] ?? json['deliveryMinutes'] ?? 0}') ?? 0,
    deliveryFee: int.tryParse('${json['delivery_fee'] ?? json['deliveryFee'] ?? 0}') ?? 0,
    emoji: json['emoji'] ?? '🏬',
  );
}

class ProductModel {
  final String id, merchantId, name, description;
  final int price;
  final String emoji;
  const ProductModel({required this.id, required this.merchantId, required this.name,
    required this.description, required this.price, required this.emoji});

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
    id: '${json['id']}',
    merchantId: '${json['merchant_id'] ?? json['merchantId']}',
    name: json['name'] ?? '',
    description: json['description'] ?? '',
    price: int.tryParse('${json['price'] ?? 0}') ?? 0,
    emoji: json['emoji'] ?? '🛍️',
  );
}

class CartItem {
  final ProductModel product;
  int quantity;
  CartItem({required this.product, this.quantity = 1});
}
