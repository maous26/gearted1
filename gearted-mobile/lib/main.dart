import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/theme.dart';
import 'routes/app_router.dart';

Future<void> main() async {
  // Ensure Flutter is initialized properly
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
    print("✅ Environment variables loaded");
  } catch (e) {
    print("⚠️ .env file not found, using default values");
  }

  // Run the app with error handling
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
