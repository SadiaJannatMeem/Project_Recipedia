import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:recipedia/screens/SplashScreen.dart';
import 'package:recipedia/screens/upload_recipe_screen.dart';
import 'firebase_options.dart';
import 'screens/search_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipedia',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      routes: {
        '/upload': (_) => const UploadRecipeScreen(),
        // Add more routes here later if needed
        '/search': (_) => const SearchScreen(),

      },
    );
  }
}
