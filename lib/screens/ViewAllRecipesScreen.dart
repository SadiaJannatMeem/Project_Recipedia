import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recipedia/recipe_model.dart';
import 'package:recipedia/screens/recipe_details_screen.dart';

class ViewAllRecipesScreen extends StatefulWidget {
  const ViewAllRecipesScreen({super.key});

  @override
  State<ViewAllRecipesScreen> createState() => _ViewAllRecipesScreenState();
}

class _ViewAllRecipesScreenState extends State<ViewAllRecipesScreen> {
  final List<String> categories = ['All', 'Breakfast', 'Lunch', 'Dinner'];
  String selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    Query query = FirebaseFirestore.instance.collection('recipes');
    if (selectedCategory != 'All') {
      query = query.where('category', isEqualTo: selectedCategory);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('All Recipes')),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(8),
            child: Row(
              children: categories.map((cat) {
                final isSelected = selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() => selectedCategory = cat);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: query.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snapshot.data!.docs;

                if (docs.isEmpty) return const Center(child: Text("No recipes found."));

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final recipe = RecipeModel.fromMap(data, docs[index].id);
                    return ListTile(
                      title: Text(recipe.name),
                      subtitle: Text('${recipe.calories} cal • ${recipe.time} min'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => RecipeDetailsScreen(recipe: recipe)),
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
