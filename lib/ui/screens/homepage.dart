// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import './fridge_item.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  List<FridgeItem> fridgeItems = [];
  // ...

  void _showAddItemDialog(BuildContext context) {
    String itemName = '';
    DateTime? expiryDate;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Add Fridge Item',
                style: GoogleFonts.poppins(
                  color: Color(0xFF755DC1),
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: InputDecoration(
                        labelText: 'Item Name',
                        labelStyle: TextStyle(color: Color(0xFF755DC1)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.purple))),
                    onChanged: (value) {
                      setState(() {
                        itemName = value;
                      });
                    },
                  ),
                  SizedBox(height: 15),
                  Text(
                    expiryDate != null
                        ? 'Expiry Date: ${DateFormat('dd/MM/yyyy').format(expiryDate!)}'
                        : 'Expiry Date: Not selected',
                    style: TextStyle(
                      color: Color(0xFF755DC1),
                      fontWeight: FontWeight.bold,
                      fontFamily: GoogleFonts.poppins().fontFamily,
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(DateTime.now().year + 10),
                      ).then((pickedDate) {
                        if (pickedDate == null) return;
                        setState(() {
                          expiryDate = pickedDate;
                        });
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9F7BFF),
                    ),
                    child: Text(
                      'Pick Expiry Date',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: GoogleFonts.poppins().fontFamily,
                      ),
                    ),
                  ),
                  // ...
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: GoogleFonts.poppins().fontFamily,
                        color: const Color(0xFF9F7BFF)),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (itemName.isNotEmpty && expiryDate != null) {
                      setState(() {
                        fridgeItems.add(FridgeItem(itemName, expiryDate!));
                        print('Item Name: $itemName');
                        print('Expiry Date: $expiryDate');
                      });
                      Navigator.of(context).pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9F7BFF),
                  ),
                  child: Text(
                    'Add Item',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: GoogleFonts.poppins().fontFamily,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color.fromARGB(255, 245, 240, 246),
        title: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              final User? user = snapshot.data;

              if (user != null) {
                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .get(),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState == ConnectionState.done) {
                      final userData = userSnapshot.data;
                      final username = userData?.get('username');

                      return Row(
                        children: [
                          Text(
                            'Hello',
                            style: GoogleFonts.poppins(
                                color: Color(0xFF755DC1),
                                fontSize: 25,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            width: 7,
                          ),
                          Text(
                            '${username}',
                            style: GoogleFonts.poppins(
                                color: Color(0xFF9F7BFF),
                                fontSize: 25,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      );
                    } else {
                      return Text('');
                    }
                  },
                );
              }
            }
            return Text('Hi Guest');
          },
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
            icon:
                Icon(Icons.login_outlined, color: Color(0xFF755DC1), size: 35),
          )
        ],
      ),
      body: _currentIndex == 0 // Check the current tab index
          ? Center(
              child: Text('Fridge Content'), // Replace with your fridge content
            )
          : Center(
              child: Text(
                  'Recommendations Content'), // Replace with your recommendations content
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddItemDialog(context);
        },
        backgroundColor: Color(0xFF9F7BFF), // Set the background color
        child: Icon(Icons.add,
            color: Colors.white), // You can change the icon and its color
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, // Set the current tab index
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.kitchen,
                color: Color(0xFF755DC1)), // Icon for "Fridge" tab
            label: 'Fridge',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_offer,
                color: Color(0xFF755DC1)), // Icon for "Recommendations" tab
            label: 'Recommendations',
          ),
        ],
        backgroundColor: Color.fromARGB(255, 245, 240, 246),
        selectedItemColor: Color(0xFF9F7BFF),
        selectedLabelStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: GoogleFonts.poppins.toString()),
        unselectedLabelStyle:
            TextStyle(fontFamily: GoogleFonts.poppins.toString()),
        onTap: (index) {
          // Handle tab switching
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
