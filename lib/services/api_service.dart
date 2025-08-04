import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SpoonacularApiService {
  final String baseUrl = 'https://api.spoonacular.com';
  final String apiKey = dotenv.env['1d261bb924e2493da975a7e85d13b082']!;

  // Search recipes by keyword
  Future<List<dynamic>> searchRecipes(String query) async {
    final url = Uri.parse(
      '$baseUrl/recipes/complexSearch?query=$query&number=10&addRecipeInformation=true&apiKey=$apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['results'];
    } else {
      throw Exception('Failed to load recipes');
    }
  }

  // Fetch full recipe details by ID
  Future<Map<String, dynamic>> getRecipeDetails(int id) async {
    final url = Uri.parse('$baseUrl/recipes/$id/information?apiKey=$apiKey');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load recipe details');
    }
  }
}
