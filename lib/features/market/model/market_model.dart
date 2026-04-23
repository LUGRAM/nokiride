class MerchantModel {
  final String id, name, category, location, priceRange;
  final double rating;
  final int reviewCount, deliveryMinutes, deliveryFee;
  final String emoji;
  const MerchantModel({required this.id, required this.name, required this.category,
    required this.location, required this.priceRange, required this.rating,
    required this.reviewCount, required this.deliveryMinutes,
    required this.deliveryFee, required this.emoji});
}

class ProductModel {
  final String id, merchantId, name, description;
  final int price;
  final String emoji;
  const ProductModel({required this.id, required this.merchantId, required this.name,
    required this.description, required this.price, required this.emoji});
}

class CartItem {
  final ProductModel product;
  int quantity;
  CartItem({required this.product, this.quantity = 1});
}
