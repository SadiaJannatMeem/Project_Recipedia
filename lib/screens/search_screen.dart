// search_screen.dart
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
                  query = val.toLowerCase();
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
                    divisions: 20,
                    label: '${maxCalories.round()} kcal',
                    onChanged: (val) {
                      setState(() => maxCalories = val);
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
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final docs = snapshot.data!.docs;
                final results = docs
                    .map((doc) => RecipeModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
                    .where((recipe) {
                  // calories stored as String, so convert to int safely
                  int cal = int.tryParse(recipe.calories) ?? 99999;
                  final matchesCalories = cal <= maxCalories.round();

                  final matchesQuery = recipe.name.toLowerCase().contains(query) ||
                      recipe.ingredients.any((ing) => ing.toLowerCase().contains(query));

                  return matchesCalories && matchesQuery;
                }).toList();

                if (results.isEmpty) {
                  return const Center(child: Text('No recipes found.'));
                }

                return ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final recipe = results[index];
                    return ListTile(
                      title: Text(recipe.name),
                      subtitle: Text('${recipe.calories} kcal • ${recipe.time}'),
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
