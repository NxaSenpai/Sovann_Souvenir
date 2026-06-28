import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/home/home_screen.dart';
import '../features/detail/product_detail_screen.dart';
import '../features/artisan/artisan_profile_screen.dart';
import '../features/collection/collection_detail_screen.dart';
import '../features/favorites/favorites_screen.dart';
import '../features/map/map_screen.dart';
import '../features/nearby/nearby_screen.dart';
import '../features/booking/booking_screen.dart';
import '../features/chat/chat_list_screen.dart';
import '../features/chat/chat_thread_screen.dart';
import '../features/reviews/reviews_screen.dart';
import '../features/gallery/gallery_screen.dart';
import '../features/category/category_screen.dart';
import '../features/checkout/checkout_screen.dart';
import '../features/featured/featured_screen.dart';
import '../features/collections/collections_screen.dart';
import '../features/chatbot/chatbot_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/profile/profile_edit_screen.dart';
import '../features/cart/cart_screen.dart';
import '../features/orders/orders_screen.dart';
import '../widgets/main_shell.dart';

// Shell pages (tab indices)
// 0=Home, 1=Favorites, 2=Map, 3=Orders, 4=Profile

final _rootKey = GlobalKey<NavigatorState>();
final _shellKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootKey,
  initialLocation: '/',
  routes: [
    ShellRoute(
      navigatorKey: _shellKey,
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(path: '/',           builder: (c, s) => const HomeScreen()),
        GoRoute(path: '/favorites',  builder: (c, s) => const FavoritesScreen()),
        GoRoute(path: '/map',        builder: (c, s) => const MapScreen()),
        GoRoute(path: '/orders',     builder: (c, s) => const OrdersScreen()),
        GoRoute(path: '/profile',    builder: (c, s) => const ProfileScreen()),
      ],
    ),
    GoRoute(
      path: '/product/:id',
      parentNavigatorKey: _rootKey,
      builder: (c, s) => ProductDetailScreen(productId: s.pathParameters['id']!),
    ),
    GoRoute(
      path: '/artisan/:id',
      parentNavigatorKey: _rootKey,
      builder: (c, s) => ArtisanProfileScreen(artisanId: s.pathParameters['id']!),
    ),
    GoRoute(
      path: '/featured',
      parentNavigatorKey: _rootKey,
      builder: (c, s) => const FeaturedScreen(),
    ),
    GoRoute(
      path: '/collections',
      parentNavigatorKey: _rootKey,
      builder: (c, s) => const CollectionsScreen(),
    ),
    GoRoute(
      path: '/category/:id',
      parentNavigatorKey: _rootKey,
      builder: (c, s) => CategoryScreen(categoryId: s.pathParameters['id']!),
    ),
    GoRoute(
      path: '/collection/:id',
      parentNavigatorKey: _rootKey,
      builder: (c, s) => CollectionDetailScreen(collectionId: s.pathParameters['id']!),
    ),
    GoRoute(
      path: '/nearby',
      parentNavigatorKey: _rootKey,
      builder: (c, s) => const NearbyScreen(),
    ),
    GoRoute(
      path: '/booking/:productId',
      parentNavigatorKey: _rootKey,
      builder: (c, s) => BookingScreen(productId: s.pathParameters['productId']!),
    ),
    GoRoute(
      path: '/chat',
      parentNavigatorKey: _rootKey,
      builder: (c, s) => const ChatListScreen(),
    ),
    GoRoute(
      path: '/chat/:artisanId',
      parentNavigatorKey: _rootKey,
      builder: (c, s) => ChatThreadScreen(artisanId: s.pathParameters['artisanId']!),
    ),
    GoRoute(
      path: '/reviews/:productId',
      parentNavigatorKey: _rootKey,
      builder: (c, s) => ReviewsScreen(productId: s.pathParameters['productId']!),
    ),
    GoRoute(
      path: '/gallery/:productId',
      parentNavigatorKey: _rootKey,
      builder: (c, s) => GalleryScreen(productId: s.pathParameters['productId']!),
    ),
    GoRoute(
      path: '/cart',
      parentNavigatorKey: _rootKey,
      builder: (c, s) => const CartScreen(),
    ),
    GoRoute(
      path: '/checkout',
      parentNavigatorKey: _rootKey,
      builder: (c, s) => const CheckoutScreen(),
    ),
    GoRoute(
      path: '/profile/edit',
      parentNavigatorKey: _rootKey,
      builder: (c, s) => const ProfileEditScreen(),
    ),
    GoRoute(
      path: '/chatbot',
      parentNavigatorKey: _rootKey,
      builder: (c, s) => const ChatbotScreen(),
    ),
  ],
);