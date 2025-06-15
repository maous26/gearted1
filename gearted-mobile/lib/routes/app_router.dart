import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/layout/main_layout.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/home/screens/home_screen_responsive.dart';
import '../features/search/screens/search_screen_new.dart';
import '../features/search/screens/advanced_search_screen.dart';
import '../features/listing/screens/create_listing_screen.dart';
import '../features/listing/screens/listing_detail_screen.dart';
import '../features/listing/screens/my_listings_screen.dart';
import '../features/chat/screens/chat_list_screen.dart';
import '../features/chat/screens/chat_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/profile/screens/edit_profile_screen.dart';
import '../features/favorites/screens/favorites_screen.dart';
import '../features/notifications/screens/notifications_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/showcase/screens/features_showcase_screen.dart';
import '../features/compatibility/screens/compatibility_check_screen.dart';
import '../features/compatibility/screens/equipment_detail_screen.dart';

GoRouter createRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      // Splash screen route
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),

      // Routes d'authentification
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Routes principales avec layout
      GoRoute(
        path: '/home',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const MainLayout(
            currentIndex: 0,
            child: HomeScreen(),
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: '/search',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: MainLayout(
            currentIndex: 1,
            child: SearchScreen(
              category: state.uri.queryParameters['category'] ??
                  state.uri.queryParameters['subcategory'] ??
                  (state.uri.queryParameters['deals'] == 'true'
                      ? 'deals'
                      : null),
            ),
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: '/sell',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const MainLayout(
            currentIndex: 2,
            child: CreateListingScreen(),
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: '/chats',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const MainLayout(
            currentIndex: 3,
            child: ChatListScreen(),
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: '/profile',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const MainLayout(
            currentIndex: 4,
            child: ProfileScreen(),
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),

      // Détail d'une annonce
      GoRoute(
        path: '/listing/:id',
        builder: (context, state) {
          final listingId = state.pathParameters['id'] ?? '';
          return ListingDetailScreen(listingId: listingId);
        },
      ),

      // Chat individuel
      GoRoute(
        path: '/chat/:chatId',
        builder: (context, state) {
          final chatId = state.pathParameters['chatId'] ?? '';
          final chatName = state.uri.queryParameters['name'] ?? 'Chat';
          return ChatScreen(
            chatId: chatId,
            chatName: chatName,
          );
        },
      ),

      // Profil et paramètres
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/my-listings',
        builder: (context, state) => const MyListingsScreen(),
      ),
      GoRoute(
        path: '/favorites',
        builder: (context, state) => const FavoritesScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),

      // Recherche avancée
      GoRoute(
        path: '/advanced-search',
        builder: (context, state) => const AdvancedSearchScreen(),
      ),

      // Fonctionnalités
      GoRoute(
        path: '/features-showcase',
        builder: (context, state) => const FeaturesShowcaseScreen(),
      ),

      // Compatibilité et équipement
      GoRoute(
        path: '/compatibility-check',
        builder: (context, state) {
          final initialEquipmentId = state.extra as String?;
          return CompatibilityCheckScreen(
              initialEquipmentId: initialEquipmentId);
        },
      ),
      GoRoute(
        path: '/equipment-detail/:id',
        builder: (context, state) {
          final equipmentId = state.pathParameters['id'] ?? '';
          return EquipmentDetailScreen(equipmentId: equipmentId);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Route non trouvée: ${state.uri}'),
      ),
    ),
  );
}
