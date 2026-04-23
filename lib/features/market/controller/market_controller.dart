import 'package:get/get.dart';
import '../model/market_model.dart';

const merchants = [
  MerchantModel(id:'m1', name:'Marché Mont-Bouët', category:'Alimentation', location:'Centre-Ville', priceRange:'F-FF', rating:4.5, reviewCount:128, deliveryMinutes:35, deliveryFee:500, emoji:'🥦'),
  MerchantModel(id:'m2', name:'Boulangerie Moderne', category:'Boulangerie', location:'Akanda', priceRange:'F', rating:4.8, reviewCount:89, deliveryMinutes:20, deliveryFee:300, emoji:'🥖'),
  MerchantModel(id:'m3', name:'Pharmacie Akanda', category:'Pharmacie', location:'Akanda', priceRange:'FF', rating:4.6, reviewCount:64, deliveryMinutes:25, deliveryFee:400, emoji:'💊'),
  MerchantModel(id:'m4', name:'Express Food', category:'Restaurant', location:'Glass', priceRange:'FF', rating:4.3, reviewCount:210, deliveryMinutes:30, deliveryFee:600, emoji:'🍽️'),
];

const products = [
  ProductModel(id:'p1', merchantId:'m1', name:'Tomates fraîches', description:'1kg de tomates locales', price:500, emoji:'🍅'),
  ProductModel(id:'p2', merchantId:'m1', name:'Oignons', description:'Filet de 2kg', price:800, emoji:'🧅'),
  ProductModel(id:'p3', merchantId:'m1', name:'Poivrons', description:'Lot de 6 poivrons', price:600, emoji:'🫑'),
  ProductModel(id:'p4', merchantId:'m2', name:'Pain baguette', description:'Baguette fraîche du jour', price:300, emoji:'🥖'),
  ProductModel(id:'p5', merchantId:'m2', name:'Croissant', description:'Lot de 4 croissants', price:800, emoji:'🥐'),
  ProductModel(id:'p6', merchantId:'m3', name:'Paracétamol 1000mg', description:'Boîte de 16 comprimés', price:1200, emoji:'💊'),
  ProductModel(id:'p7', merchantId:'m4', name:'Poulet braisé', description:'Demi-poulet + frites', price:3500, emoji:'🍗'),
  ProductModel(id:'p8', merchantId:'m4', name:'Jus de gingembre', description:'Bouteille 50cl artisanale', price:800, emoji:'🧃'),
];

class MarketController extends GetxController {
  final RxString selectedMerchantId = ''.obs;
  final RxList<CartItem> cart = <CartItem>[].obs;
  final RxString searchQuery = ''.obs;

  List<MerchantModel> get filteredMerchants {
    if (searchQuery.value.isEmpty) return merchants;
    return merchants.where((m) => m.name.toLowerCase().contains(searchQuery.value.toLowerCase()) || m.category.toLowerCase().contains(searchQuery.value.toLowerCase())).toList();
  }

  List<ProductModel> get selectedProducts =>
      products.where((p) => p.merchantId == selectedMerchantId.value).toList();

  int get cartTotal => cart.fold(0, (sum, item) => sum + item.product.price * item.quantity);
  int get cartCount => cart.fold(0, (sum, item) => sum + item.quantity);

  String get formattedTotal {
    final s = cartTotal.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ');
    return '$s F CFA';
  }

  void selectMerchant(String id) => selectedMerchantId.value = id;

  void addToCart(ProductModel p) {
    final idx = cart.indexWhere((c) => c.product.id == p.id);
    if (idx >= 0) { cart[idx].quantity++; cart.refresh(); }
    else cart.add(CartItem(product: p));
  }

  void removeFromCart(ProductModel p) {
    final idx = cart.indexWhere((c) => c.product.id == p.id);
    if (idx >= 0) {
      if (cart[idx].quantity > 1) { cart[idx].quantity--; cart.refresh(); }
      else cart.removeAt(idx);
    }
  }

  int quantityOf(ProductModel p) {
    final idx = cart.indexWhere((c) => c.product.id == p.id);
    return idx >= 0 ? cart[idx].quantity : 0;
  }

  void clearCart() => cart.clear();
}
