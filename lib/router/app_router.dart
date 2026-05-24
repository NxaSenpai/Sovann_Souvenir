import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/home/home_screen.dart';
import '../features/detail/product_detail_screen.dart';
import '../features/artisan/artisan_profile_screen.dart';
import '../features/collection/collection_detail_screen.dart';
import '../features/favorites/favorites_screen.dart';
import '../features/map/map_screen.dart';
import '../features/nearby/nearby_screen.dart';
import '../features/promotions/promotions_screen.dart';
import '../features/booking/booking_screen.dart';
import '../features/chat/chat_list_screen.dart';
import '../features/chat/chat_thread_screen.dart';
import '../features/reviews/reviews_screen.dart';
import '../features/gallery/gallery_screen.dart';
import '../features/quiz/quiz_screen.dart';
import '../features/settings/settings_screen.dart';
import '../widgets/main_shell.dart';

// Shell pages (tab indices)
// 0=Home, 1=Favorites, 2=Map, 3=Promotions, 4=Settings

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
        GoRoute(path: '/promotions', builder: (c, s) => const PromotionsScreen()),
        GoRoute(path: '/settings',   builder: (c, s) => const SettingsScreen()),
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
      path: '/quiz',
      parentNavigatorKey: _rootKey,
      builder: (c, s) => const QuizScreen(),
    ),
  ],
);