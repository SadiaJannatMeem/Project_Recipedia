import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../recipe_model.dart';
import 'upload_recipe_screen.dart';
import '../services/cloudinary_service.dart';

class RecipeDetailsScreen extends StatefulWidget {
  final RecipeModel recipe;
  final bool? isInitiallyFavorite;

  const RecipeDetailsScreen({
    super.key,
    required this.recipe,
    this.isInitiallyFavorite,
  });

  @override
  State<RecipeDetailsScreen> createState() => _RecipeDetailsScreenState();
}

class _RecipeDetailsScreenState extends State<RecipeDetailsScreen> {
  late RecipeModel recipe;
  bool _isFavorite = false;
  int servings = 1;
  late List<String> baseIngredients;
  late List<String> adjustedIngredients;
  bool isAdmin = false;
  bool isLoading = false;

  final CloudinaryService _cloudinaryService = CloudinaryService();

  @override
  void initState() {
    super.initState();
    recipe = widget.recipe;
    servings = 1;
    baseIngredients = List.from(recipe.ingredients);
    adjustedIngredients = _scaleIngredients(servings);

    if (widget.isInitiallyFavorite != null) {
      _isFavorite = widget.isInitiallyFavorite!;
    } else {
      _loadFavorite();
    }

    _checkAdmin();
  }

  Future<void> _checkAdmin() async {
    final admin = await isCurrentUserAdmin();
    if (mounted) {
      setState(() {
        isAdmin = admin;
      });
    }
  }

  Future<void> _loadFavorite() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(recipe.id)
        .get();
    if (mounted) {
      setState(() {
        _isFavorite = doc.exists;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    setState(() {
      _isFavorite = !_isFavorite;
    });

    final userId = FirebaseAuth.instance.currentUser!.uid;
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(recipe.id);

    try {
      if (_isFavorite) {
        await docRef.set(recipe.toMap());
      } else {
        await docRef.delete();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isFavorite = !_isFavorite;
        });
      }
    }
  }

  List<String> _scaleIngredients(int servings) {
    return baseIngredients.map((ingredient) {
      final quantityMatch = RegExp(r'(\d+\s\d+/\d+|\d+/\d+|\d+(\.\d+)?)').firstMatch(ingredient);
      if (quantityMatch != null) {
        String qtyStr = quantityMatch.group(0)!;
        double qty = _parseQuantity(qtyStr);
        double scaledQty = qty * servings;
        String scaledQtyStr = _toMixedFraction(scaledQty);
        return ingredient.replaceFirst(qtyStr, scaledQtyStr);
      }
      return ingredient;
    }).toList();
  }

  double _parseQuantity(String input) {
    input = input.trim();
    if (input.contains(' ')) {
      var parts = input.split(' ');
      if (parts.length == 2) {
        double whole = double.tryParse(parts[0]) ?? 0;
        double frac = _parseFraction(parts[1]);
        return whole + frac;
      }
    }
    return _parseFraction(input);
  }

  double _parseFraction(String input) {
    if (input.contains('/')) {
      var parts = input.split('/');
      if (parts.length == 2) {
        double numerator = double.tryParse(parts[0]) ?? 0;
        double denominator = double.tryParse(parts[1]) ?? 1;
        if (denominator != 0) {
          return numerator / denominator;
        }
      }
    }
    return double.tryParse(input) ?? 0;
  }

  String _toMixedFraction(double value) {
    const double tolerance = 0.01;
    int whole = value.floor();
    double frac = value - whole;

    Map<double, String> commonFractions = {
      0.25: "1/4",
      0.33: "1/3",
      0.5: "1/2",
      0.66: "2/3",
      0.75: "3/4"
    };

    if (frac < tolerance) return whole.toString();

    for (var entry in commonFractions.entries) {
      if ((frac - entry.key).abs() < tolerance) {
        if (whole == 0) return entry.value;
        return "$whole ${entry.value}";
      }
    }

    return value.toStringAsFixed(2);
  }

  void _updateServings(bool increase) {
    setState(() {
      if (increase) {
        servings++;
      } else if (servings > 1) {
        servings--;
      }
      adjustedIngredients = _scaleIngredients(servings);
    });
  }

  Future<void> _refreshRecipe() async {
    setState(() {
      isLoading = true;
    });
    try {
      final doc = await FirebaseFirestore.instance.collection('recipes').doc(recipe.id).get();
      if (doc.exists) {
        final data = doc.data()!;
        final updatedRecipe = RecipeModel.fromMap(data, doc.id);
        if (mounted) {
          setState(() {
            recipe = updatedRecipe;
            baseIngredients = List.from(recipe.ingredients);
            adjustedIngredients = _scaleIngredients(servings);
          });
        }
      }
    } catch (e) {
      // ignore error
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _editRecipe() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UploadRecipeScreen(
          isEditing: true,
          recipeToEdit: recipe,
        ),
      ),
    ).then((value) {
      if (value == true) {
        _refreshRecipe();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.name),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : Colors.white,
            ),
            onPressed: _toggleFavorite,
          ),
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: "Edit Recipe",
              onPressed: _editRecipe,
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(recipe.imageUrl),
            const SizedBox(height: 10),
            Text(
              recipe.category,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 6),

            //  Display Filters
            if (recipe.filters.isNotEmpty) ...[
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: recipe.filters
                    .map((filter) => Chip(
                  label: Text(filter),
                  backgroundColor: Colors.green.shade100,
                ))
                    .toList(),
              ),
              const SizedBox(height: 10),
            ],

            Text("Calories: ${recipe.calories}", style: const TextStyle(fontSize: 16)),
            Text("Time: ${recipe.time}", style: const TextStyle(fontSize: 16)),
            Text("Bulk Cooking: ${recipe.bulkCooking}", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Servings:", style: TextStyle(fontSize: 18)),
                Row(
                  children: [
                    IconButton(icon: const Icon(Icons.remove), onPressed: () => _updateServings(false)),
                    Text(servings.toString(), style: const TextStyle(fontSize: 18)),
                    IconButton(icon: const Icon(Icons.add), onPressed: () => _updateServings(true)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text("Ingredients:", style: TextStyle(fontSize: 18)),
            ...adjustedIngredients.map((e) => Text("• $e")),
            const SizedBox(height: 20),
            const Text("Instructions:", style: TextStyle(fontSize: 18)),
            Text(recipe.instructions),
          ],
        ),
      ),
    );
  }
}

Future<bool> isCurrentUserAdmin() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return false;

  final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
  if (userDoc.exists) {
    final data = userDoc.data();
    if (data != null && data['role'] == 'admin') {
      return true;
    }
  }
  return false;
}
