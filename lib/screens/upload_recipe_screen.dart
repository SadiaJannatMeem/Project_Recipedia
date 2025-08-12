import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../recipe_model.dart';
import '../services/cloudinary_service.dart';

class UploadRecipeScreen extends StatefulWidget {
  final bool isEditing;
  final RecipeModel? recipeToEdit;

  const UploadRecipeScreen({
    super.key,
    this.isEditing = false,
    this.recipeToEdit,
  });

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

  String? oldImageUrl;
  String? oldImagePublicId;

  final CloudinaryService _cloudinaryService = CloudinaryService();

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.recipeToEdit != null) {
      final recipe = widget.recipeToEdit!;
      nameController.text = recipe.name;
      categoryController.text = recipe.category;
      caloriesController.text = recipe.calories;
      timeController.text = recipe.time;
      bulkCookingController.text = recipe.bulkCooking;
      instructionsController.text = recipe.instructions;
      filters.addAll(recipe.filters);
      ingredients.addAll(recipe.ingredients);
      oldImageUrl = recipe.imageUrl;
      oldImagePublicId = recipe.imagePublicId;
    }
  }

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  Future<void> submitRecipe() async {
    if (!_formKey.currentState!.validate()) return;

    if (!widget.isEditing && _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please pick an image")));
      return;
    }

    setState(() => isUploading = true);

    try {
      String imageUrl = oldImageUrl ?? "";
      String imagePublicId = oldImagePublicId ?? "";

      if (_imageFile != null) {
        final uploadResult = await _cloudinaryService.uploadImageToCloudinary(_imageFile!);
        imageUrl = uploadResult['secure_url']!;
        imagePublicId = uploadResult['public_id']!;
      }

      final createdAt = widget.isEditing && widget.recipeToEdit != null
          ? widget.recipeToEdit!.createdAt
          : FieldValue.serverTimestamp();

      final data = {
        'name': nameController.text.trim(),
        'category': categoryController.text.trim(),
        'calories': caloriesController.text.trim().isEmpty
            ? 'cal'
            : caloriesController.text.trim(),
        'time': timeController.text.trim(),
        'bulkCooking': bulkCookingController.text.trim(),
        'instructions': instructionsController.text.trim(),
        'imageUrl': imageUrl,
        'imagePublicId': imagePublicId,
        'filters': filters,
        'ingredients': ingredients,
        'createdAt': createdAt,
      };

      if (widget.isEditing && widget.recipeToEdit != null) {
        await FirebaseFirestore.instance
            .collection('recipes')
            .doc(widget.recipeToEdit!.id)
            .update(data);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Recipe updated successfully!")));
      } else {
        await FirebaseFirestore.instance.collection('recipes').add(data);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Recipe uploaded successfully!")));
      }

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => isUploading = false);
    }
  }

  void addIngredient() {
    if (ingredientController.text.isNotEmpty &&
        quantityController.text.isNotEmpty) {
      ingredients.add(
          '${ingredientController.text} (${quantityController.text})');
      ingredientController.clear();
      quantityController.clear();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(widget.isEditing ? "Update Recipe" : "Upload Recipe"),
      ),
      body: isUploading
          ? const Center(child: CircularProgressIndicator())
          : GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_imageFile != null)
                    Image.file(_imageFile!, height: 150)
                  else if (widget.isEditing && oldImageUrl != null)
                    Image.network(oldImageUrl!, height: 150),
                  TextButton.icon(
                    onPressed: pickImage,
                    icon: const Icon(Icons.image),
                    label: const Text("Pick Image"),
                  ),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: "Recipe Name"),
                    validator: (value) =>
                    value!.isEmpty ? "Required" : null,
                  ),
                  TextFormField(
                    controller: categoryController,
                    decoration: const InputDecoration(
                        labelText: "Category (e.g. breakfast)"),
                    validator: (value) =>
                    value!.isEmpty ? "Required" : null,
                  ),
                  TextFormField(
                    controller: caloriesController,
                    decoration: const InputDecoration(labelText: "Calories"),
                  ),
                  TextFormField(
                    controller: timeController,
                    decoration: const InputDecoration(labelText: "Time (in mins)"),
                  ),
                  TextFormField(
                    controller: bulkCookingController,
                    decoration: const InputDecoration(labelText: "Bulk Cooking Tips"),
                  ),
                  TextFormField(
                    controller: instructionsController,
                    maxLines: 4,
                    decoration: const InputDecoration(labelText: "Instructions"),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: ingredientController,
                          decoration: const InputDecoration(labelText: "Ingredient"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: quantityController,
                          decoration: const InputDecoration(labelText: "Quantity"),
                        ),
                      ),
                      IconButton(
                        onPressed: addIngredient,
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                  Wrap(
                    children: ingredients.map((e) => Chip(label: Text(e))).toList(),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    initialValue: filters.join(', '),
                    decoration: const InputDecoration(labelText: "Filters (comma separated)"),
                    onChanged: (value) {
                      filters.clear();
                      filters.addAll(value.split(',').map((e) => e.trim()));
                    },
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: submitRecipe,
                    child: Text(widget.isEditing ? "Update Recipe" : "Submit Recipe"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
