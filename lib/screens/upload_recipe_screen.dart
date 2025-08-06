import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Utils/constants.dart';

class UploadRecipeScreen extends StatefulWidget {
  const UploadRecipeScreen({super.key});

  @override
  State<UploadRecipeScreen> createState() => _UploadRecipeScreenState();
}

class _UploadRecipeScreenState extends State<UploadRecipeScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final categoryController = TextEditingController();
  final caloriesController = TextEditingController();
  final timeController = TextEditingController();
  final bulkCookingController = TextEditingController();
  final instructionsController = TextEditingController();
  final ingredientController = TextEditingController();
  final quantityController = TextEditingController();

  final List<String> filters = [];
  final List<String> ingredients = [];

  File? _imageFile;
  bool isUploading = false;

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  Future<String> uploadImageToCloudinary(File imageFile) async {
    const cloudName = 'dod6ldr2w';
    const uploadPreset = 'recipe';

    final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final response = await request.send();
    final res = await http.Response.fromStream(response);

    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      return data['secure_url'];
    } else {
      throw Exception("Image upload failed");
    }
  }

  void addIngredient() {
    if (ingredientController.text.isNotEmpty &&
        quantityController.text.isNotEmpty) {
      ingredients.add('${ingredientController.text} (${quantityController.text})');
      ingredientController.clear();
      quantityController.clear();
      setState(() {});
    }
  }

  Future<void> submitRecipe() async {
    if (_formKey.currentState!.validate() && _imageFile != null) {
      try {
        setState(() => isUploading = true);
        final imageUrl = await uploadImageToCloudinary(_imageFile!);

        await FirebaseFirestore.instance.collection('recipes').add({
          'name': nameController.text.trim(),
          'category': categoryController.text.trim(),
          'calories': caloriesController.text.trim(),
          'time': timeController.text.trim(),
          'bulkCooking': bulkCookingController.text.trim(),
          'instructions': instructionsController.text.trim(),
          'imageUrl': imageUrl,
          'filters': filters,
          'ingredients': ingredients,
          'createdAt': Timestamp.now(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Recipe uploaded successfully!")),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      } finally {
        setState(() => isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Upload Recipe")),
      body: isUploading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (_imageFile != null)
                Image.file(_imageFile!, height: 150),
              TextButton.icon(
                onPressed: pickImage,
                icon: Icon(Icons.image),
                label: Text("Pick Image"),
              ),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Recipe Name"),
                validator: (value) => value!.isEmpty ? "Required" : null,
              ),
              TextFormField(
                controller: categoryController,
                decoration: InputDecoration(labelText: "Category (e.g. breakfast)"),
                validator: (value) => value!.isEmpty ? "Required" : null,
              ),
              TextFormField(
                controller: caloriesController,
                decoration: InputDecoration(labelText: "Calories"),
              ),
              TextFormField(
                controller: timeController,
                decoration: InputDecoration(labelText: "Time (in mins)"),
              ),
              TextFormField(
                controller: bulkCookingController,
                decoration: InputDecoration(labelText: "Bulk Cooking Tips"),
              ),
              TextFormField(
                controller: instructionsController,
                maxLines: 4,
                decoration: InputDecoration(labelText: "Instructions"),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: ingredientController,
                      decoration: InputDecoration(labelText: "Ingredient"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: quantityController,
                      decoration: InputDecoration(labelText: "Quantity"),
                    ),
                  ),
                  IconButton(
                    onPressed: addIngredient,
                    icon: Icon(Icons.add),
                  )
                ],
              ),
              Wrap(
                children: ingredients
                    .map((e) => Chip(label: Text(e)))
                    .toList(),
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(labelText: "Filters (comma separated)"),
                onChanged: (value) {
                  filters.clear();
                  filters.addAll(value.split(',').map((e) => e.trim()));
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: submitRecipe,
                child: const Text("Submit Recipe"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
