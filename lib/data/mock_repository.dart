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

  // Translation cache — clear when locale changes
  List<Product>? _productsTr;
  List<Artisan>? _artisansTr;
  List<GiftCollection>? _collectionsTr;
  List<Branch>? _branchesTr;
  List<Promotion>? _promotionsTr;

  /// Update the locale used by translated getters.
  void setLocale(String code) {
    if (_locale == code) return;
    _locale = code;
    _productsTr = null;
    _artisansTr = null;
    _collectionsTr = null;
    _branchesTr = null;
    _promotionsTr = null;
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
    // Enrich products with collection IDs from junction table
    _enrichProductCollections();
  }

  Future<void> _fetchProducts() async {
    try {
      final data = await _supabase.from('products').select();
      _products = (data as List).map((j) => Product.fromJson(j)).toList();
    } catch (e) {
      _products = [];
    }
  }

  Future<void> _enrichProductCollections() async {
    if (_products == null || _products!.isEmpty) return;
    try {
      final juncData = await _supabase.from('product_collections').select();
      final colMap = <String, List<String>>{};
      for (final row in (juncData as List)) {
        final pid = row['product_id'] as String;
        final cid = row['collection_id'] as String;
        colMap.putIfAbsent(pid, () => []).add(cid);
      }
      _products = _products!.map((p) {
        return Product(
          id: p.id, name: p.name, artisanId: p.artisanId, categoryId: p.categoryId,
          collectionIds: colMap[p.id] ?? [],
          price: p.price, rating: p.rating, reviewCount: p.reviewCount,
          images: p.images, description: p.description, materials: p.materials,
          dimensions: p.dimensions, story: p.story, isFeatured: p.isFeatured, tags: p.tags,
        );
      }).toList();
      _productsTr = null; // clear translation cache after enrichment
    } catch (_) {}
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
      final data = await _supabase.from('reviews').select('*, profiles(full_name, avatar_url)');
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

  // ── Translated getters (cached per locale) ──
  List<Product> get productsTr =>
      _productsTr ??= products.map((p) => p.translated(_locale)).toList();
  List<Artisan> get artisansTr =>
      _artisansTr ??= artisans.map((a) => a.translated(_locale)).toList();
  List<GiftCollection> get collectionsTr =>
      _collectionsTr ??= collections.map((c) => c.translated(_locale)).toList();
  List<Branch> get branchesTr =>
      _branchesTr ??= branches.map((b) => b.translated(_locale)).toList();
  List<Category> get categories => _categories ?? [];
  List<Category> get categoriesTr => categories;
  List<Promotion> get promotionsTr =>
      _promotionsTr ??= promotions.map((p) => p.translated(_locale)).toList();

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