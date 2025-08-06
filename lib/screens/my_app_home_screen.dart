import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iconsax/iconsax.dart';
import 'package:recipedia/screens/ViewAllRecipesScreen.dart';

import '../Utils/constants.dart';
import '../recipe_model.dart';
import 'search_screen.dart';
import 'favorites_screen.dart';
import 'settings_screen.dart';
import 'upload_recipe_screen.dart';
import 'recipe_details_screen.dart';

class MyAppHomeScreen extends StatefulWidget {
  const MyAppHomeScreen({super.key});

  @override
  State<MyAppHomeScreen> createState() => _MyAppHomeScreenState();
}

class _MyAppHomeScreenState extends State<MyAppHomeScreen> {
  int _selectedIndex = 0;
  User? currentUser;
  String userRole = 'user';
  bool isLoadingRole = true;

  final List<String> categories = ['All', 'Breakfast', 'Lunch', 'Dinner'];
  String selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
    _fetchUserRole();
  }

  Future<void> _fetchUserRole() async {
    if (currentUser != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .get();
      setState(() {
        userRole = userDoc.data()?['role'] ?? 'user';
        isLoadingRole = false;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Home tab widget
  Widget _homeTab() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text(
              "What are you\ncooking today?",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, height: 1),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SearchScreen()));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: const [
                    Icon(Iconsax.search_normal, color: Colors.grey),
                    SizedBox(width: 8),
                    Text("Search any recipes",
                        style: TextStyle(color: Colors.grey, fontSize: 16)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Category Chips
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Categories", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ViewAllRecipesScreen()),
                    );
                  },
                  child: const Text("View All"),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, i) {
                  final cat = categories[i];
                  final isSelected = selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() {
                          selectedCategory = cat;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // Recipes List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('recipes').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data?.docs ?? [];
                  final recipes = docs
                      .map((doc) => RecipeModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
                      .where((r) => selectedCategory == 'All' ||
                      r.category.toLowerCase() == selectedCategory.toLowerCase())
                      .toList();

                  if (recipes.isEmpty) {
                    return const Center(child: Text("No recipes found."));
                  }

                  return ListView.separated(
                    itemCount: recipes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final recipe = recipes[index];
                      return Card(
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              recipe.imageUrl,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text(recipe.name),
                          subtitle: Text("${recipe.calories} kcal • ${recipe.time} min"),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RecipeDetailsScreen(recipe: recipe),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  // Tab navigation options
  static const List<Widget> _widgetOptions = <Widget>[
    Text('Home'), // Will be replaced dynamically
    FavoritesScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _selectedIndex == 0 ? _homeTab() : _widgetOptions[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: kPrimaryColor,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorites'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
      floatingActionButton: (isLoadingRole || userRole != 'admin')
          ? null
          : FloatingActionButton(
        backgroundColor: kPrimaryColor,
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const UploadRecipeScreen()));
        },
        child: const Icon(Iconsax.add),
      ),
    );
  }
}
