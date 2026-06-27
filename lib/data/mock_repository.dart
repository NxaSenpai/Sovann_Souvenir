import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';
import '../models/artisan.dart';
import '../models/collection.dart';
import '../models/category.dart';
import '../models/branch.dart';
import '../models/review.dart';
import '../models/promotion.dart';

class MockRepository {
  MockRepository._();
  static final MockRepository instance = MockRepository._();

  final _supabase = Supabase.instance.client;
  List<Product>? _products;
  List<Artisan>? _artisans;
  List<GiftCollection>? _collections;
  List<Category>? _categories;
  List<Branch>? _branches;
  List<Review>? _reviews;
  List<Promotion>? _promotions;

  /// Current locale for translating content. Defaults to English.
  String _locale = 'en';

  /// Update the locale used by translated getters.
  void setLocale(String code) {
    _locale = code;
  }

  Future<void> init() async {
    await Future.wait([
      _fetchProducts(),
      _fetchArtisans(),
      _fetchCollections(),
      _fetchCategories(),
      _fetchBranches(),
      _fetchPromotions(),
      _fetchReviews(),
    ]);
  }

  Future<void> _fetchProducts() async {
    try {
      final data = await _supabase.from('products').select();
      _products = (data as List).map((j) => Product.fromJson(j)).toList();
    } catch (e) {
      _products = [];
    }
  }

  Future<void> _fetchArtisans() async {
    try {
      final data = await _supabase.from('artisans').select();
      _artisans = (data as List).map((j) => Artisan.fromJson(j)).toList();
    } catch (_) {
      _artisans = [];
    }
  }

  Future<void> _fetchCollections() async {
    try {
      final colData = await _supabase.from('collections').select();
      _collections = (colData as List).map((j) {
        // collections don't have productIds from DB — build from product_collections later
        return GiftCollection.fromJson({...j, 'productIds': <String>[]});
      }).toList();
      // Fetch junction table for product IDs per collection
      final juncData = await _supabase.from('product_collections').select();
      final map = <String, List<String>>{};
      for (final row in (juncData as List)) {
        final cid = row['collection_id'] as String;
        final pid = row['product_id'] as String;
        map.putIfAbsent(cid, () => []).add(pid);
      }
      _collections = _collections!.map((c) {
        return GiftCollection(
          id: c.id,
          name: c.name,
          description: c.description,
          coverImage: c.coverImage,
          tag: c.tag,
          productIds: map[c.id] ?? [],
        );
      }).toList();
    } catch (_) {
      _collections = [];
    }
  }

  Future<void> _fetchCategories() async {
    try {
      final data = await _supabase.from('categories').select();
      _categories = (data as List).map((j) => Category.fromJson(j)).toList();
    } catch (_) {
      _categories = [];
    }
  }

  Future<void> _fetchBranches() async {
    try {
      final data = await _supabase.from('branches').select();
      _branches = (data as List).map((j) => Branch.fromJson(j)).toList();
    } catch (_) {
      _branches = [];
    }
  }

  Future<void> _fetchPromotions() async {
    try {
      final data = await _supabase.from('promotions').select();
      _promotions = (data as List).map((j) => Promotion.fromJson(j)).toList();
    } catch (_) {
      _promotions = [];
    }
  }

  Future<void> _fetchReviews() async {
    try {
      final data = await _supabase.from('reviews').select();
      _reviews = (data as List).map((j) => Review.fromJson(j)).toList();
    } catch (_) {
      _reviews = [];
    }
  }

  // ── Raw (English) getters ──
  List<Product>       get products    => _products    ?? [];
  List<Artisan>       get artisans    => _artisans    ?? [];
  List<GiftCollection>get collections => _collections ?? [];
  List<Branch>        get branches    => _branches    ?? [];
  List<Review>        get reviews     => _reviews     ?? [];
  List<Promotion>     get promotions  => _promotions  ?? [];

  // ── Translated getters ──
  List<Product> get productsTr =>
      products.map((p) => p.translated(_locale)).toList();
  List<Artisan> get artisansTr =>
      artisans.map((a) => a.translated(_locale)).toList();
  List<GiftCollection> get collectionsTr =>
      collections.map((c) => c.translated(_locale)).toList();
  List<Branch> get branchesTr =>
      branches.map((b) => b.translated(_locale)).toList();
  List<Category> get categories => _categories ?? [];
  List<Category> get categoriesTr => categories;
  List<Promotion> get promotionsTr =>
      promotions.map((p) => p.translated(_locale)).toList();

  // ── Derived queries (translated) ──
  List<Product> get featuredTr =>
      productsTr.where((p) => p.isFeatured).toList();
  List<Product> byCategoryTr(String cat) =>
      productsTr.where((p) => p.categoryId == cat).toList();
  List<Product> byCollectionTr(String cid) =>
      productsTr.where((p) => p.collectionIds.contains(cid)).toList();
  Artisan? artisanByIdTr(String id) =>
      artisansTr.where((a) => a.id == id).firstOrNull;
  List<Review> reviewsForProductTr(String pid) =>
      reviews.where((r) => r.productId == pid)
          .map((r) => r.translated(_locale)).toList();
  GiftCollection? collectionByIdTr(String id) =>
      collectionsTr.where((c) => c.id == id).firstOrNull;

  // ── Original English-only queries (for backward compat) ──
  List<Product> get featured    => products.where((p) => p.isFeatured).toList();
  List<Product> byCategory(String cat) => products.where((p) => p.categoryId == cat).toList();
  List<Product> byCollection(String cid) =>
      products.where((p) => p.collectionIds.contains(cid)).toList();
  Artisan?      artisanById(String id) =>
      artisans.where((a) => a.id == id).firstOrNull;
  List<Review>  reviewsForProduct(String pid) =>
      reviews.where((r) => r.productId == pid).toList();
  GiftCollection? collectionById(String id) =>
      collections.where((c) => c.id == id).firstOrNull;
}