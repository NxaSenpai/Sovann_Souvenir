import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/product.dart';
import '../models/artisan.dart';
import '../models/collection.dart';
import '../models/branch.dart';
import '../models/review.dart';
import '../models/promotion.dart';

class MockRepository {
  MockRepository._();
  static final MockRepository instance = MockRepository._();

  List<Product>? _products;
  List<Artisan>? _artisans;
  List<GiftCollection>? _collections;
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
    _products   = await _load('assets/mock/products.json',   Product.fromJson);
    _artisans   = await _load('assets/mock/artisans.json',   Artisan.fromJson);
    _collections= await _load('assets/mock/collections.json',GiftCollection.fromJson);
    _branches   = await _load('assets/mock/branches.json',   Branch.fromJson);
    _reviews    = await _load('assets/mock/reviews.json',    Review.fromJson);
    _promotions = await _load('assets/mock/promotions.json', Promotion.fromJson);
  }

  Future<List<T>> _load<T>(String path, T Function(Map<String, dynamic>) fromJson) async {
    final raw = await rootBundle.loadString(path);
    final list = json.decode(raw) as List;
    return list.map((e) => fromJson(e as Map<String, dynamic>)).toList();
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