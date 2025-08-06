class RecipeModel {
  final String id;
  final String name;
  final String category;
  final String imageUrl;
  final String calories;
  final String time;
  final List<String> ingredients;
  final String bulkCooking;
  final String instructions;
  final List<String> filters;

  RecipeModel({
    required this.id,
    required this.name,
    required this.category,
    required this.imageUrl,
    required this.calories,
    required this.time,
    required this.ingredients,
    required this.bulkCooking,
    required this.instructions,
    required this.filters,
  });

  factory RecipeModel.fromMap(Map<String, dynamic> map, String id) {
    return RecipeModel(
      id: id,
      name: map['name'],
      category: map['category'],
      imageUrl: map['imageUrl'],
      calories: map['calories'],
      time: map['time'],
      ingredients: List<String>.from(map['ingredients']),
      bulkCooking: map['bulkCooking'],
      instructions: map['instructions'],
      filters: List<String>.from(map['filters']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'imageUrl': imageUrl,
      'calories': calories,
      'time': time,
      'ingredients': ingredients,
      'bulkCooking': bulkCooking,
      'instructions': instructions,
      'filters': filters,
    };
  }
}
