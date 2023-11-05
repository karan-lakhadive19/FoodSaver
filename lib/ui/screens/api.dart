import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodsaver/ui/screens/details.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RecipePage extends StatefulWidget {
  final String uid;

  RecipePage({required this.uid});

  @override
  _RecipePageState createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  List<String> fridgeItems = [];
  List<Recipe> recipes = [];
  Map<String, List<Recipe>> recipesByItem = {};

  @override
  void initState() {
    super.initState();
    fetchFridgeItems();
  }

  void _navigateToRecipeDetail(int recipeId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Details(
            recipeId: recipeId), // Pass the recipeId to the Details screen
      ),
      
    );
  }

  Future<void> fetchFridgeItems() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('fridge')
        .doc(widget.uid)
        .collection('MyFridge')
        .get();

    final items =
        snapshot.docs.map((doc) => doc.get('item_name') as String).toList();

    setState(() {
      fridgeItems = items;
      print("FridgeItems: $fridgeItems");
      print("items: $fridgeItems");
    });

    // Now, you can search for recipes based on the fridge items
    searchRecipes();
  }

  void searchRecipes() async {
    final apiKey = 'e91e3bfed19e4f88af15ea90df0c43c4';
    final ingredients = fridgeItems.join(',');
    print("xx:$ingredients");

    for (var item in fridgeItems) {
      print("item: $item");
      final url = Uri.parse(
          'https://api.spoonacular.com/recipes/complexSearch?cuisine=Indian&includeIngredients=$item&apiKey=$apiKey&sort=popularity');
      print("url: $url");

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map<String, dynamic> && data.containsKey('results')) {
          final results = data['results'] as List<dynamic>;
          List<Recipe> fetchedRecipes = [];

          for (var item in results) {
            fetchedRecipes.add(Recipe.fromJson(item));
          }

          setState(() {
            recipes.addAll(fetchedRecipes);
            recipesByItem[item] = fetchedRecipes;
            print("recipes: $recipes");
          });
        } else {
          // Handle API response format error
        }
      } else {
        // Handle API request error
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: fridgeItems.length,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Color.fromARGB(255, 245, 240, 246),
          title: Text(
            'Recipes from Your Fridge Items',
            style: GoogleFonts.poppins(
                color: Color(0xFF755DC1),
                fontSize: 25,
                fontWeight: FontWeight.bold),
          ),
          bottom: TabBar(
            labelColor: Color(0xFF9F7BFF),
            isScrollable: true,
            indicatorColor: Colors.purple,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            tabs: fridgeItems.map((item) {
              return Tab(
                child: Text(
                  capitalize(item),
                  style: GoogleFonts.poppins(), // Use Google Fonts with Poppins
                ),
              );
            }).toList(),
          ),
        ),
        body: TabBarView(
          children: fridgeItems.map((item) {
            return ListView.builder(
              itemCount: recipesByItem[item]?.length ?? 0,
              itemBuilder: (context, index) {
                final recipes = recipesByItem[item] ?? [];
                return GestureDetector(
                  onTap: () {
                    // Handle navigation to a new screen here
                    _navigateToRecipeDetail(recipes[index].id);
                    print(recipes[index].id);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      color: Color.fromARGB(255, 245, 240, 246),
                      elevation: 7, // Add elevation for a card-like effect
                      margin:
                          EdgeInsets.all(10), // Add some margin around the card
                      child: Column(
                        children: <Widget>[
                          Container(
                            height: 200,
                            width: double.infinity,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                  10), // Add rounded corners
                              child: Image.network(
                                recipes[index].image,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          ListTile(
                            title: Text(
                              recipes[index].title,
                              style: TextStyle(
                                fontFamily: GoogleFonts.poppins().fontFamily,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF755DC1),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  String capitalize(String s) {
    return s[0].toUpperCase() + s.substring(1);
  }
}

class Recipe {
  final int id;
  final String title;
  final String image;
  final String imageType;

  Recipe({
    required this.id,
    required this.title,
    required this.image,
    required this.imageType,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      title: json['title'],
      image: json['image'],
      imageType: json['imageType'],
    );
  }
}

class Ingredient {
  final String name;

  Ingredient({required this.name});

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(name: json['name']);
  }
}
