import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:gearted/features/listing/screens/listing_detail_screen.dart';
import 'package:gearted/features/chat/screens/chat_screen.dart';

void main() {
  group('Chat Navigation Tests', () {
    testWidgets('Bouton Contacter navigue vers l\'écran de chat',
        (WidgetTester tester) async {
      // Configuration du router pour les tests
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/listing/:id',
            builder: (context, state) => ListingDetailScreen(
              listingId: state.pathParameters['id'] ?? '1',
            ),
          ),
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
        ],
      );

      // Construction du widget de test
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
        ),
      );

      // Navigation initiale vers la page de détail d'une annonce
      router.go('/listing/1');
      await tester.pumpAndSettle();

      // Vérification que nous sommes sur la page de détail
      expect(find.byType(ListingDetailScreen), findsOneWidget);

      // Recherche du bouton "Contacter" - chercher par le texte directement
      final contactButton = find.text('Contacter');
      expect(contactButton, findsOneWidget);

      // Clic sur le bouton "Contacter"
      await tester.tap(contactButton);

      // Use pump with specific duration instead of pumpAndSettle to avoid timer issues
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Vérification que nous sommes maintenant sur l'écran de chat
      expect(find.byType(ChatScreen), findsOneWidget);

      // Vérification que le nom du vendeur est affiché (accepter plusieurs occurrences)
      expect(find.text('Alexandre Martin'), findsAtLeastNWidgets(1));
    });

    testWidgets('Test avec différents vendeurs', (WidgetTester tester) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/listing/:id',
            builder: (context, state) => ListingDetailScreen(
              listingId: state.pathParameters['id'] ?? '1',
            ),
          ),
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
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
        ),
      );

      // Test avec l'annonce 2 (Sophie Dubois)
      router.go('/listing/2');
      await tester.pumpAndSettle();

      final contactButton = find.text('Contacter');
      expect(contactButton, findsOneWidget);

      await tester.tap(contactButton);

      // Use pump with specific duration instead of pumpAndSettle
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(ChatScreen), findsOneWidget);
      expect(find.text('Sophie Dubois'), findsAtLeastNWidgets(1));
    });

    testWidgets('Vérification de l\'encodage des noms avec espaces',
        (WidgetTester tester) async {
      // Test que les noms avec espaces sont correctement encodés
      const sellerName = 'Alexandre Martin';
      final encodedName = Uri.encodeComponent(sellerName);
      final sellerId = sellerName.replaceAll(' ', '').toLowerCase();

      expect(encodedName, 'Alexandre%20Martin');
      expect(sellerId, 'alexandremartin');
    });
  });

  group('Fonctionnalités Chat Screen Tests', () {
    testWidgets('Chat screen affiche les éléments essentiels',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const ChatScreen(
            chatId: 'test',
            chatName: 'Test User',
          ),
        ),
      );

      // Attendre que le widget soit construit
      await tester.pump();

      // Attendre les timers (500ms pour _checkPendingRatings)
      await tester.pump(const Duration(milliseconds: 600));

      // Vérifications des éléments essentiels
      expect(find.text('Test User'), findsOneWidget);
      expect(find.text('En ligne'), findsOneWidget);
      expect(find.byIcon(Icons.send), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('Test envoi de message', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const ChatScreen(
            chatId: 'test',
            chatName: 'Test User',
          ),
        ),
      );

      // Attendre que le widget soit construit et les timers résolus
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      // Trouve le champ de texte et tape un message
      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);

      await tester.enterText(textField, 'Test message');
      await tester.pump(); // Let the text input update

      // Trouve et clique sur le bouton d'envoi
      final sendButton = find.byIcon(Icons.send);
      expect(sendButton, findsOneWidget);

      await tester.tap(sendButton);

      // Pump to trigger the setState in _sendMessage
      await tester.pump();

      // Also pump any animations/scrolling that might happen
      await tester.pump(const Duration(milliseconds: 300));

      // Try scrolling to the bottom to make sure new message is visible
      final listView = find.byType(ListView);
      if (listView.evaluate().isNotEmpty) {
        await tester.drag(listView, const Offset(0, -500)); // Scroll down
        await tester.pump();
      }

      // Vérifie que le message apparaît dans la conversation
      expect(find.text('Test message'), findsOneWidget);
    });
  });
}
