// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Details extends StatefulWidget {
  final int recipeId;

  Details({required this.recipeId});

  @override
  _DetailsState createState() => _DetailsState();
}

// ...

class _DetailsState extends State<Details> {
  late Map<String, dynamic> recipeDetails;
  List<Map<String, dynamic>> ingredientDetails = [];
  List<String> stepDetails = []; // Added stepDetails

  @override
  void initState() {
    super.initState();
    fetchRecipeDetails();
  }

  void fetchRecipeDetails() async {
    final apiKey = 'e91e3bfed19e4f88af15ea90df0c43c4';
    final url = Uri.parse(
        'https://api.spoonacular.com/recipes/${widget.recipeId}/information?apiKey=$apiKey');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Check if 'extendedIngredients' exists in the response
        if (data.containsKey('extendedIngredients')) {
          final ingredients = data['extendedIngredients'];

          // Clear the ingredient details list before populating it
          ingredientDetails.clear();

          // Populate the ingredient details list
          for (final ingredient in ingredients) {
            final ingredientName = ingredient['name'];
            final original = ingredient['original'];

            ingredientDetails.add({
              'name': ingredientName,
              'original': original,
            });
          }
        }

        // Check if 'analyzedInstructions' exists in the response
        if (data.containsKey('analyzedInstructions')) {
          final instructions = data['analyzedInstructions'];

          // Clear the step details list before populating it
          stepDetails.clear();

          // Populate the step details list
          for (final instruction in instructions) {
            final steps = instruction['steps'];
            for (final step in steps) {
              final stepDescription = step['step'];
              stepDetails.add(stepDescription);
            }
          }
        }

        setState(() {
          recipeDetails = data;
        });
      } else {
        // Handle API request error
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          recipeDetails['title'].toString(),
          style: GoogleFonts.poppins(
              color: Color(0xFF755DC1),
              fontSize: 22,
              fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Color.fromARGB(255, 245, 240, 246),
        iconTheme: IconThemeData(color: Color(0xFF755DC1)),
      ),
      body: recipeDetails != null
          ? Column(
              children: [
                SizedBox(
                  height: 10,
                ),

                Image.network(
                  recipeDetails['image'] != null &&
                          recipeDetails['image'].isNotEmpty
                      ? recipeDetails['image']
                      : 'https://www.allrecipes.com/thmb/1ul-jdOz8H4b6BDrRcYOuNmJgt4=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/239867chef-johns-chicken-tikka-masala-ddmfs-3X4-0572-e02a25f8c7b745459a9106e9eb13de10.jpg', // Replace with the URL of your placeholder image or set it to null
                  fit: BoxFit.cover,
                  height: 200,
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Card(
                      color: Color.fromARGB(255, 245, 240, 246),
                      elevation: 4,
                      margin: EdgeInsets.all(8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(
                              "Ready in Minutes",
                              style: GoogleFonts.poppins(
                                  color: Color(0xFF9F7BFF),
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              recipeDetails["readyInMinutes"].toString(),
                              style: GoogleFonts.poppins(
                                  color: Color(0xFF755DC1),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Card(
                      color: Color.fromARGB(255, 245, 240, 246),
                      elevation: 4,
                      margin: EdgeInsets.all(8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(
                              "Cuisine",
                              style: GoogleFonts.poppins(
                                  color: Color(0xFF9F7BFF),
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              recipeDetails["cuisines"][0].toString(),
                              style: GoogleFonts.poppins(
                                  color: Color(0xFF755DC1),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Ingredients",
                        style: GoogleFonts.poppins(
                            color: Color(0xFF755DC1),
                            fontSize: 22,
                            fontWeight: FontWeight.bold))
                  ],
                ),
                // Add a ListView of ListTiles to display ingredient details
                Expanded(
                  child: ListView.builder(
                    itemCount: ingredientDetails.length,
                    itemBuilder: (context, index) {
                      final ingredient = ingredientDetails[index];
                      return ListTile(
                        title: Text(capitalizeFirstLetter(ingredient['name']),
                            style: GoogleFonts.poppins(
                                color: Color(0xFF755DC1),
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        subtitle: Text('Quantity: ${ingredient['original']}',
                            style: GoogleFonts.poppins(
                                color: Color(0xFF9F7BFF),
                                fontSize: 14,
                                fontWeight: FontWeight.w600)),
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Divider(
                  color: Color(0xFF755DC1),
                  thickness: 2,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Steps",
                        style: GoogleFonts.poppins(
                            color: Color(0xFF755DC1),
                            fontSize: 22,
                            fontWeight: FontWeight.bold))
                  ],
                ),
                // Add a ListView of ListTiles to display step details
                Expanded(
                  child: ListView.builder(
                    itemCount: stepDetails.length,
                    itemBuilder: (context, index) {
                      final step = stepDetails[index];
                      return ListTile(
                        title: Text("Step ${index + 1}",
                            style: GoogleFonts.poppins(
                                color: Color(0xFF755DC1),
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        subtitle: Text(step,
                            style: GoogleFonts.poppins(
                                color: Color(0xFF9F7BFF),
                                fontSize: 14,
                                fontWeight: FontWeight.w600)),
                      );
                    },
                  ),
                ),
              ],
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
