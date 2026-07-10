import 'package:get/get.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/services/market_api_service.dart';
import '../model/market_model.dart';

const merchants = [
  MerchantModel(
      id: 'm1',
      name: 'Marché Mont-Bouët',
      category: 'Alimentation',
      location: 'Centre-Ville',
      priceRange: 'F-FF',
      rating: 4.5,
      reviewCount: 128,
      deliveryMinutes: 35,
      deliveryFee: 500,
      emoji: '🥦'),
  MerchantModel(
      id: 'm2',
      name: 'Boulangerie Moderne',
      category: 'Boulangerie',
      location: 'Akanda',
      priceRange: 'F',
      rating: 4.8,
      reviewCount: 89,
      deliveryMinutes: 20,
      deliveryFee: 300,
      emoji: '🥖'),
  MerchantModel(
      id: 'm3',
      name: 'Pharmacie Akanda',
      category: 'Pharmacie',
      location: 'Akanda',
      priceRange: 'FF',
      rating: 4.6,
      reviewCount: 64,
      deliveryMinutes: 25,
      deliveryFee: 400,
      emoji: '💊'),
  MerchantModel(
      id: 'm4',
      name: 'Express Food',
      category: 'Restaurant',
      location: 'Glass',
      priceRange: 'FF',
      rating: 4.3,
      reviewCount: 210,
      deliveryMinutes: 30,
      deliveryFee: 600,
      emoji: '🍽️'),
];

const products = [
  ProductModel(
      id: 'p1',
      merchantId: 'm1',
      name: 'Tomates fraîches',
      description: '1kg de tomates locales',
      price: 500,
      emoji: '🍅'),
  ProductModel(
      id: 'p2',
      merchantId: 'm1',
      name: 'Oignons',
      description: 'Filet de 2kg',
      price: 800,
      emoji: '🧅'),
  ProductModel(
      id: 'p3',
      merchantId: 'm1',
      name: 'Poivrons',
      description: 'Lot de 6 poivrons',
      price: 600,
      emoji: '🫑'),
  ProductModel(
      id: 'p4',
      merchantId: 'm2',
      name: 'Pain baguette',
      description: 'Baguette fraîche du jour',
      price: 300,
      emoji: '🥖'),
  ProductModel(
      id: 'p5',
      merchantId: 'm2',
      name: 'Croissant',
      description: 'Lot de 4 croissants',
      price: 800,
      emoji: '🥐'),
  ProductModel(
      id: 'p6',
      merchantId: 'm3',
      name: 'Paracétamol 1000mg',
      description: 'Boîte de 16 comprimés',
      price: 1200,
      emoji: '💊'),
  ProductModel(
      id: 'p7',
      merchantId: 'm4',
      name: 'Poulet braisé',
      description: 'Demi-poulet + frites',
      price: 3500,
      emoji: '🍗'),
  ProductModel(
      id: 'p8',
      merchantId: 'm4',
      name: 'Jus de gingembre',
      description: 'Bouteille 50cl artisanale',
      price: 800,
      emoji: '🧃'),
];

class MarketController extends GetxController {
  MarketController(this._marketService);

  final MarketApiService _marketService;
  final RxString selectedMerchantId = ''.obs;
  final RxList<CartItem> cart = <CartItem>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString deliveryAddress = ''.obs;
  final RxString selectedPaymentMethod = 'noki_pay'.obs;
  final RxString lastPaymentReference = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool isOrdering = false.obs;
  final RxList<MerchantModel> merchantList = <MerchantModel>[].obs;
  final RxMap<String, List<ProductModel>> productCache =
      <String, List<ProductModel>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    merchantList.assignAll(merchants);
    for (final product in products) {
      productCache
          .putIfAbsent(product.merchantId, () => <ProductModel>[])
          .add(product);
    }
    fetchMerchants();
  }

  List<MerchantModel> get filteredMerchants {
    if (searchQuery.value.isEmpty) return merchantList;
    return merchantList
        .where((m) =>
            m.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
            m.category.toLowerCase().contains(searchQuery.value.toLowerCase()))
        .toList();
  }

  MerchantModel? get selectedMerchant {
    if (merchantList.isEmpty) return null;
    return merchantList
            .firstWhereOrNull((m) => m.id == selectedMerchantId.value) ??
        merchantList.first;
  }

  List<ProductModel> get selectedProducts =>
      productCache[selectedMerchantId.value] ?? const [];

  MerchantModel? get cartMerchant {
    if (cart.isEmpty) return null;
    final merchantId = cart.first.product.merchantId;
    return merchantList
        .firstWhereOrNull((merchant) => merchant.id == merchantId);
  }

  int get cartSubtotal =>
      cart.fold(0, (sum, item) => sum + item.product.price * item.quantity);
  int get cartDeliveryFee => cart.isEmpty ? 0 : cartMerchant?.deliveryFee ?? 0;
  int get cartTotal => cartSubtotal + cartDeliveryFee;
  int get cartCount => cart.fold(0, (sum, item) => sum + item.quantity);

  String get formattedSubtotal {
    final s = cartSubtotal.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ');
    return '$s F CFA';
  }

  String get formattedDeliveryFee {
    final s = cartDeliveryFee.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ');
    return '$s F CFA';
  }

  String get formattedTotal {
    final s = cartTotal.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ');
    return '$s F CFA';
  }

  Future<void> fetchMerchants() async {
    isLoading.value = true;
    try {
      final data = await _marketService.merchants();
      merchantList.assignAll(
        data.map((item) =>
            MerchantModel.fromJson(Map<String, dynamic>.from(item as Map))),
      );
    } catch (_) {
      // Le catalogue local reste disponible hors ligne.
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> selectMerchant(String id) async {
    selectedMerchantId.value = id;
    await fetchProducts(id);
  }

  Future<void> fetchProducts(String merchantId) async {
    if (productCache.containsKey(merchantId) &&
        !merchants.any((m) => m.id == merchantId)) {
      return;
    }

    try {
      final data = await _marketService.products(merchantId);
      productCache[merchantId] = data
          .map((item) =>
              ProductModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
      productCache.refresh();
    } catch (_) {
      // Le fallback local reste disponible si le serveur est arrêté.
    }
  }

  void addToCart(ProductModel p) {
    if (cart.isNotEmpty && cart.first.product.merchantId != p.merchantId) {
      clearCart();
      selectedMerchantId.value = p.merchantId;
      Get.snackbar(
        'Nouveau panier',
        'Le panier précédent a été remplacé pour ce commerçant.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }

    final idx = cart.indexWhere((c) => c.product.id == p.id);
    if (idx >= 0) {
      cart[idx].quantity++;
      cart.refresh();
    } else {
      cart.add(CartItem(product: p));
    }
  }

  void removeFromCart(ProductModel p) {
    final idx = cart.indexWhere((c) => c.product.id == p.id);
    if (idx >= 0) {
      if (cart[idx].quantity > 1) {
        cart[idx].quantity--;
        cart.refresh();
      } else {
        cart.removeAt(idx);
      }
    }
  }

  int quantityOf(ProductModel p) {
    final idx = cart.indexWhere((c) => c.product.id == p.id);
    return idx >= 0 ? cart[idx].quantity : 0;
  }

  void clearCart() {
    cart.clear();
    deliveryAddress.value = '';
  }

  Future<bool> createOrder() async {
    final merchant = cartMerchant;
    final address = deliveryAddress.value.trim();

    if (cart.isEmpty) {
      Get.snackbar('Panier vide', 'Ajoutez au moins un produit.');
      return false;
    }

    if (merchant == null) {
      Get.snackbar('Commande impossible', 'Aucun commerçant sélectionné.');
      return false;
    }

    if (int.tryParse(merchant.id) == null ||
        cart.any((item) => int.tryParse(item.product.id) == null)) {
      Get.snackbar(
        'Catalogue non synchronisé',
        'Rechargez le catalogue avant de commander.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (address.length < 3) {
      Get.snackbar('Adresse requise', 'Indiquez une adresse de livraison.');
      return false;
    }

    isOrdering.value = true;
    try {
      final order = await _marketService.createOrder(
        merchantId: int.parse(merchant.id),
        deliveryAddress: address,
        paymentMethod: selectedPaymentMethod.value,
        items: cart
            .map((item) => {
                  'product_id': int.parse(item.product.id),
                  'quantity': item.quantity,
                })
            .toList(),
      );
      lastPaymentReference.value = '${order['payment_reference'] ?? ''}';

      clearCart();
      Get.back();
      Get.back();
      Get.snackbar(
        'Commande confirmée',
        'Référence ${order['reference'] ?? order['id'] ?? ''}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } on ApiException catch (error) {
      Get.snackbar('Commande impossible', error.message,
          snackPosition: SnackPosition.BOTTOM);
      return false;
    } catch (_) {
      Get.snackbar(
          'Commande impossible', 'Vérifiez votre connexion puis réessayez.',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isOrdering.value = false;
    }
  }

  void selectPaymentMethod(String method) {
    selectedPaymentMethod.value = method;
  }
}
