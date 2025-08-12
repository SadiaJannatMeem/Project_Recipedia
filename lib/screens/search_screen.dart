import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recipedia/recipe_model.dart';
import 'package:recipedia/screens/recipe_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String query = '';
  double maxCalories = 1000;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Recipes')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search by name or ingredient',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (val) {
                setState(() {
                  query = val.trim().toLowerCase();
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text('Max Calories:'),
                Expanded(
                  child: Slider(
                    value: maxCalories,
                    min: 100,
                    max: 2000,
                    divisions: 19,
                    label: '${maxCalories.round()} cal',
                    onChanged: (val) {
                      setState(() => maxCalories = val);
                      debugPrint('Max calories updated: $val');
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('recipes').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                // Convert docs to RecipeModel list
                final recipes = docs
                    .map((doc) => RecipeModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
                    .toList();

                // Filter recipes with fixed calorie parsing
                final filteredRecipes = recipes.where((recipe) {
                  int calories = 99999;
                  try {
                    // Remove non-digit chars like "k" from calories string
                    final sanitized = recipe.calories.replaceAll(RegExp(r'[^0-9]'), '');
                    calories = int.parse(sanitized);
                  } catch (e) {
                    debugPrint('Invalid calories for recipe ${recipe.id}: ${recipe.calories}');
                  }

                  if (calories > maxCalories) return false;

                  if (query.isEmpty) return true;

                  final nameLower = recipe.name.toLowerCase();
                  final ingredientsLower = recipe.ingredients.map((i) => i.toLowerCase()).toList();

                  final nameMatches = nameLower.contains(query);
                  final ingredientMatches = ingredientsLower.any((ing) => ing.contains(query));

                  return nameMatches || ingredientMatches;
                }).toList();

                if (filteredRecipes.isEmpty) {
                  return const Center(child: Text('No recipes found.'));
                }

                return ListView.builder(
                  itemCount: filteredRecipes.length,
                  itemBuilder: (context, index) {
                    final recipe = filteredRecipes[index];
                    return ListTile(
                      title: Text(recipe.name),
                      subtitle: Text('${recipe.calories} cal • ${recipe.time}'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RecipeDetailsScreen(recipe: recipe),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}