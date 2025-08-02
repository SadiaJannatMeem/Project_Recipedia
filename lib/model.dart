class RecipeModel {
  final String applabel;
  final String appimgUrl;
  final double appcalories;
  final String appurl;

  RecipeModel({
    this.applabel = "LABEL",
    this.appcalories = 0.0,
    this.appimgUrl = "IMAGE",
    this.appurl = "URL",
  });

  factory RecipeModel.fromMap(Map<String, dynamic> recipe) {
    return RecipeModel(
      applabel: recipe["title"] ?? "No Title",
      appcalories: recipe["nutrition"]?["nutrients"]?[0]?["amount"]?.toDouble() ?? 0.0,
      appimgUrl: recipe["image"] ?? "",
      appurl: recipe["sourceUrl"] ?? "",
    );
  }
}
