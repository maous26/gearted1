import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/theme.dart';
import 'routes/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Charger les variables d'environnement (avec gestion d'erreur)
  try {
    await dotenv.load(fileName: ".env");
    print("✅ Variables d'environnement chargées");
  } catch (e) {
    print("⚠️ Fichier .env non trouvé, utilisation des valeurs par défaut");
  }

  // TODO: Initialiser Firebase ici

  runApp(
    const ProviderScope(
      child: GeartedApp(),
    ),
  );
}

class GeartedApp extends ConsumerWidget {
  const GeartedApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = createRouter();

    return MaterialApp.router(
      title: 'Gearted',
      theme: GeartedTheme.lightTheme,
      darkTheme: GeartedTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
