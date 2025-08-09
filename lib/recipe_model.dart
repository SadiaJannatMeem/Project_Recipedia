import 'package:cloud_firestore/cloud_firestore.dart';

class RecipeModel {
  final String id;
  final String name;
  final String category;
  final String imageUrl;
  final String imagePublicId; // for Cloudinary deletion
  final String calories;
  final String time;
  final List<String> ingredients;
  final String bulkCooking;
  final String instructions;
  final List<String> filters;
  final Timestamp createdAt;

  RecipeModel({
    required this.id,
    required this.name,
    required this.category,
    required this.imageUrl,
    required this.imagePublicId,
    required this.calories,
    required this.time,
    required this.ingredients,
    required this.bulkCooking,
    required this.instructions,
    required this.filters,
    required this.createdAt,
  });

  factory RecipeModel.fromMap(Map<String, dynamic> map, String id) {
    // Safe parsing helpers
    List<String> parseStringList(dynamic list) {
      if (list == null) return [];
      try {
        return List<String>.from(list.map((e) => e.toString()));
      } catch (_) {
        return [];
      }
    }

    String parseString(dynamic value) {
      if (value == null) return '';
      return value.toString();
    }

    Timestamp parseTimestamp(dynamic value) {
      if (value is Timestamp) return value;
      return Timestamp.now();
    }

    return RecipeModel(
      id: id,
      name: parseString(map['name']),
      category: parseString(map['category']),
      imageUrl: parseString(map['imageUrl']),
      imagePublicId: parseString(map['imagePublicId']),
      calories: parseString(map['calories']),
      time: parseString(map['time']),
      ingredients: parseStringList(map['ingredients']),
      bulkCooking: parseString(map['bulkCooking']),
      instructions: parseString(map['instructions']),
      filters: parseStringList(map['filters']),
      createdAt: parseTimestamp(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'imageUrl': imageUrl,
      'imagePublicId': imagePublicId,
      'calories': calories,
      'time': time,
      'ingredients': ingredients,
      'bulkCooking': bulkCooking,
      'instructions': instructions,
      'filters': filters,
      'createdAt': createdAt,
    };
  }
}
