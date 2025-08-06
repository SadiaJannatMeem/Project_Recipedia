import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../Utils/constants.dart';
import '../recipe_model.dart';

class RecipeDetailsScreen extends StatefulWidget {
  final RecipeModel recipe;

  const RecipeDetailsScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailsScreen> createState() => _RecipeDetailsScreenState();
}

class _RecipeDetailsScreenState extends State<RecipeDetailsScreen> {
  bool _isFavorite = false;
  int servings = 1;

  late List<String> adjustedIngredients;

  @override
  void initState() {
    super.initState();
    _loadFavorite();
    servings = 1;
    adjustedIngredients = _scaleIngredients(servings);
  }

  Future<void> _loadFavorite() async {
    final fav = await isFavorite(widget.recipe.id);
    setState(() {
      _isFavorite = fav;
    });
  }

  Future<void> _toggleFavorite() async {
    await toggleFavorite(widget.recipe);
    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  Future<bool> isFavorite(String recipeId) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(recipeId)
        .get();
    return doc.exists;
  }

  Future<void> toggleFavorite(RecipeModel recipe) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(recipe.id);

    final doc = await docRef.get();
    if (doc.exists) {
      await docRef.delete();
    } else {
      await docRef.set(recipe.toMap());
    }
  }

  List<String> _scaleIngredients(int servings) {
    List<String> scaled = [];

    for (var ing in widget.recipe.ingredients) {
      final regex = RegExp(r'(.*)\s*\(([\d./]+)\)$');
      final match = regex.firstMatch(ing.trim());
      if (match != null) {
        String name = match.group(1)!.trim();
        String qtyStr = match.group(2)!;

        double qty = _parseQuantity(qtyStr);
        double scaledQty = qty * servings;

        String scaledQtyStr = scaledQty % 1 == 0
            ? scaledQty.toInt().toString()
            : scaledQty.toStringAsFixed(2);

        scaled.add('$name ($scaledQtyStr)');
      } else {
        scaled.add(ing);
      }
    }

    return scaled;
  }

  double _parseQuantity(String qtyStr) {
    if (qtyStr.contains('/')) {
      var parts = qtyStr.split('/');
      if (parts.length == 2) {
        double numerator = double.tryParse(parts[0]) ?? 0;
        double denominator = double.tryParse(parts[1]) ?? 1;
        if (denominator != 0) {
          return numerator / denominator;
        }
      }
    }
    return double.tryParse(qtyStr) ?? 0;
  }

  void _increaseServings() {
    setState(() {
      servings++;
      adjustedIngredients = _scaleIngredients(servings);
    });
  }

  void _decreaseServings() {
    if (servings > 1) {
      setState(() {
        servings--;
        adjustedIngredients = _scaleIngredients(servings);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;

    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.name),
        backgroundColor: kPrimaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipe Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                recipe.imageUrl,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 12),

            // Title + Favorite Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    recipe.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: Colors.red,
                    size: 28,
                  ),
                  onPressed: _toggleFavorite,
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Use Wrap here instead of Row to prevent overflow
            Wrap(
              spacing: 16,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.timer, size: 18),
                    SizedBox(width: 4),
                    // Text('${recipe.time} min'), // Can't use const here due to variable, so remove const on parent
                  ],
                ),
                Text('${recipe.time} min'),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.local_fire_department, size: 18),
                    SizedBox(width: 4),
                  ],
                ),
                Text('${recipe.calories} kcal'),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.kitchen, size: 18),
                    SizedBox(width: 4),
                  ],
                ),
                Text('Bulk Cooking: ${recipe.bulkCooking}'),
              ],
            ),

            const SizedBox(height: 16),

            // Filters as Chips
            if (recipe.filters.isNotEmpty) ...[
              const Text(
                'Filters:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: recipe.filters
                    .map((f) => Chip(label: Text(f)))
                    .toList(),
              ),
              const SizedBox(height: 16),
            ],

            // Servings Adjuster
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Servings:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: _decreaseServings,
                    ),
                    Text(
                      servings.toString(),
                      style: const TextStyle(fontSize: 18),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: _increaseServings,
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Ingredients List (scaled)
            const Text(
              'Ingredients:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            for (final ingredient in adjustedIngredients)
              Text('• $ingredient'),

            const SizedBox(height: 16),

            // Instructions
            const Text(
              'Instructions:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(recipe.instructions),
          ],
        ),
      ),
    );
  }
}
