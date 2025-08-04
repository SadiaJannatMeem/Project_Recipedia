import 'package:flutter/material.dart';
import 'package:recipedia/model.dart';  // Assuming your model is compatible
import 'package:recipedia/services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>{
  List<RecipeModel> recipeList = <RecipeModel>[];
  TextEditingController searchController = TextEditingController();

  final SpoonacularApiService apiService = SpoonacularApiService();


  Future<void> getRecipes(String query) async {
    try {
      final results = await apiService.searchRecipes(query);

      recipeList.clear();
      for (var recipe in results) {
        recipeList.add(RecipeModel.fromMap(recipe));
      }

      setState(() {}); // Refresh UI
    } catch (e) {
      print('Error fetching recipes: $e');
      // Optionally show an error message to users here
    }
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
          SingleChildScrollView(
            child: Column(
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
                      Text("WHAT DO YOU WANT TO COOK TODAY?", style: TextStyle(fontSize: 33, color: Colors.white),),
                      SizedBox(height: 10,),
                      Text("Let's Cook Something New!", style: TextStyle(fontSize: 20, color: Colors.white),)
                    ],
                  ),
                ),
                Container(
                  child: ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: recipeList.length,
                      itemBuilder: (context,index){
                        return InkWell(
                          onTap: (){},
                          child: Card(
                            child: Stack(
                              children: [
                                ClipRRect(
                                  child: Image.network(recipeList[index].appimgUrl),
                                )
                              ],
                            ),
                          ),
                        );
                      }),

                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
