import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:recipedia/model.dart';  // Assuming your model is compatible
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>{
  List<RecipeModel> recipeList = <RecipeModel>[];
  TextEditingController searchController = TextEditingController();

  getRecipes(String query) async {
    // Spoonacular API URL (complexSearch endpoint)
    String url = "https://api.spoonacular.com/recipes/complexSearch?query=$query&number=10&addRecipeNutrition=true&apiKey=1d261bb924e2493da975a7e85d13b082";

    http.Response response = await http.get(
      Uri.parse(url),
      headers: {
        'Accept': 'application/json',
      },
    );

    Map data = jsonDecode(response.body);

    // Clear previous results before adding new ones
    recipeList.clear();

    // Spoonacular returns recipes under 'results' key
    data["results"].forEach((element) {
      RecipeModel recipeModel = RecipeModel.fromMap(element); // Assuming model's fromMap fits Spoonacular structure
      recipeList.add(recipeModel);
      log(recipeList.toString());
    });

    for (var recipe in recipeList) {
      print('Title: ${recipe.applabel}');
      print('Calories: ${recipe.appcalories}');
    }

    setState(() {}); // To refresh UI if needed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                Color(0xFFa8e063),
                Color(0xFF56ab2f),
              ]),
            ),
          ),
          Column(
            children: [
              // Search Bar
              SafeArea(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  margin: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24)),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if ((searchController.text).replaceAll(" ", "") == "") {
                            print("Blank search");
                          } else {
                            getRecipes(searchController.text);
                          }
                        },
                        child: Container(
                          margin: EdgeInsets.fromLTRB(3, 0, 7, 0),
                          child: Icon(
                            Icons.search,
                            color: Colors.blueAccent,
                          ),

                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: searchController,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Let's Cook Something!"),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "WHAT DO YOU WANT TO COOK TODAY?",
                      style: TextStyle(fontSize: 33, color: Colors.white),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Let's Cook Something New!",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    )
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
