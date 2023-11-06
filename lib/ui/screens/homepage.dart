// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodsaver/ui/screens/api.dart';
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
  TextEditingController itemController = TextEditingController();
  // ...
  DateTime? expiryDate;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String uid = "";

  @override
  void initState() {
    // TODO: implement initState
    getUid();
    super.initState();
  }

  getUid() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    setState(() {
      uid = user!.uid;
    });
    print(uid);
  }

 String _calculateRemainingDays(DateTime expiryDate) {
  final currentDate = DateTime.now();
  final expiryDateWithoutTime = DateTime(
    expiryDate.year,
    expiryDate.month,
    expiryDate.day,
  );
  final currentDateWithoutTime = DateTime(
    currentDate.year,
    currentDate.month,
    currentDate.day,
  );

  if (expiryDateWithoutTime.isBefore(currentDateWithoutTime)) {
    return 'Expired';
  }

  final difference = expiryDateWithoutTime.difference(currentDateWithoutTime);
  final differenceInDays = difference.inDays;

  if (differenceInDays <= 0) {
    return 'Expired';
  } else if (differenceInDays == 1) {
    return '1 day';
  } else {
    return '$differenceInDays days';
  }
}


  

  void _showAddItemDialog(BuildContext context) {
    String itemName = '';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Add Item',
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
                    controller: itemController,
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
                        builder: (BuildContext context, Widget? child) {
                          return Theme(
                            data: ThemeData.light().copyWith(
                              primaryColor: Color(
                                  0xFF9F7BFF), // Set your desired color // Set your desired color
                              colorScheme: ColorScheme.light(
                                  primary: Color(
                                      0xFF9F7BFF)), // Set your desired color
                              buttonTheme: ButtonThemeData(
                                  textTheme: ButtonTextTheme.primary),
                            ),
                            child: child!,
                          );
                        },
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
                  )

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
                      addItem();

                      Navigator.of(context).pop();
                      final snackBar = SnackBar(
                        backgroundColor: Colors.white,
                        behavior: SnackBarBehavior.floating,
                        key: _scaffoldKey,
                        content: Text(
                          'Item added successfully!',
                          style: TextStyle(
                            color: Color(0xFF755DC1),
                            fontSize: 15,
                            fontFamily: GoogleFonts.poppins().fontFamily,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        duration: Duration(
                            seconds:
                                2), // You can adjust the duration as needed
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    } else {
                      final snackBar = SnackBar(
                        backgroundColor: Colors.white,
                        behavior: SnackBarBehavior.floating,
                        key: _scaffoldKey,
                        content: Text(
                          'Please add an item!',
                          style: TextStyle(
                            color: Color(0xFF755DC1),
                            fontSize: 15,
                            fontFamily: GoogleFonts.poppins().fontFamily,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        duration: Duration(
                            seconds:
                                2), // You can adjust the duration as needed
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
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

  Future<void> addItem() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    String uid = user!.uid;
    var time = DateTime.now();

    if (itemController.text.isEmpty) {
      // Handle empty item name
      const snackBar = SnackBar(
        content: Text(
          "Please input Item!",
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.purple,
        behavior: SnackBarBehavior.floating,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else if (expiryDate == null) {
      // Handle case where expiry date is not selected
      const snackBar = SnackBar(
        content: Text(
          "Please select Expiry Date!",
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.purple,
        behavior: SnackBarBehavior.floating,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      await FirebaseFirestore.instance
          .collection('fridge')
          .doc(uid)
          .collection('MyFridge')
          .doc(time.toString())
          .set({
        'item_name': itemController.text,
        'expiry_date': expiryDate!.toUtc(), // Store the expiry date
        'time': time.toString(),
        'timestamp': time,
      });
      // Clear the item name and expiry date
      itemController.clear();
      setState(() {
        expiryDate = null;
      });
    }
  }

  void _deleteItemFromFirebase(String itemId) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    String uid = user!.uid;

    await FirebaseFirestore.instance
        .collection('fridge')
        .doc(uid)
        .collection('MyFridge')
        .doc(itemId) // Use the item ID to delete
        .delete();

    // You can also update the UI by removing the item from the local list
    // Example: fridgeItems.removeWhere((item) => item.reference.id == itemId);
  }

  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _currentIndex == 0
          ? AppBar(
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
                          if (userSnapshot.connectionState ==
                              ConnectionState.done) {
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
                                  width: 6,
                                ),
                                Text(
                                  capitalizeFirstLetter(username),
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
                  icon: Icon(Icons.login_outlined,
                      color: Color(0xFF755DC1), size: 35),
                )
              ],
            )
          : null,
      body: _currentIndex == 0 // Check the current tab index
          ? Padding(
              padding: EdgeInsets.all(12),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('fridge')
                    .doc(uid)
                    .collection('MyFridge')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        'Your Fridge is empty!',
                        style: GoogleFonts.poppins(
                            color: Color(0xFF9F7BFF),
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                    );
                  } else {
                    final items = snapshot.data!.docs;
                    items.sort((a, b) {
                      final aData = a.data() as Map<String, dynamic>;
                      final bData = b.data() as Map<String, dynamic>;
                      final aExpiryDate = aData['expiry_date'];
                      final bExpiryDate = bData['expiry_date'];
                      if (aExpiryDate == null && bExpiryDate == null) {
                        return 0;
                      } else if (aExpiryDate == null) {
                        return 1;
                      } else if (bExpiryDate == null) {
                        return -1;
                      }
                      return aExpiryDate.compareTo(bExpiryDate);
                    });
                    return ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final itemData = item.data() as Map<String, dynamic>;
                        final itemName = itemData['item_name'];
                        final expiryDate = itemData['expiry_date'];

                        String capitalize(String s) {
                          return s[0].toUpperCase() + s.substring(1);
                        }

                        return Card(
                          color: Color.fromARGB(255, 239, 237, 239),
                          elevation: 4,
                          margin: EdgeInsets.all(8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: ListTile(
                                  contentPadding: EdgeInsets.all(20),
                                  title: Text(
                                    capitalize(itemName),
                                    style: TextStyle(
                                      fontFamily:
                                          GoogleFonts.poppins().fontFamily,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF755DC1),
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Expiry Date: ${expiryDate != null ? DateFormat('dd/MM/yyyy').format(expiryDate.toDate()) : 'Not specified'}',
                                        style: TextStyle(
                                          fontFamily:
                                              GoogleFonts.poppins().fontFamily,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF9F7BFF),
                                        ),
                                      ),
                                      Text(
                                        'Remaining Days: ${expiryDate != null ? _calculateRemainingDays(expiryDate.toDate()) : 'N/A'}',
                                        style: TextStyle(
                                          fontFamily:
                                              GoogleFonts.poppins().fontFamily,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: _calculateRemainingDays(
                                                      expiryDate.toDate()) ==
                                                  'Expired'
                                              ? Colors.red
                                              : (_calculateRemainingDays(
                                                          expiryDate
                                                              .toDate()) ==
                                                      'More than 5 days'
                                                  ? Colors
                                                      .green // Change this to your desired color
                                                  : Colors.purple),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete,
                                    color: Color.fromARGB(255, 244, 74, 62),
                                    size: 35),
                                onPressed: () {
                                  _deleteItemFromFirebase(item.reference
                                      .id); // Pass the item ID to delete
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }
                },
              ))
          : Center(
              child: Center(
              child: RecipePage(uid: uid),
            ) // Replace with your recommendations content
              ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                _showAddItemDialog(context);
              },
              backgroundColor: Color(0xFF9F7BFF), // Set the background color
              child: Icon(Icons.add,
                  color: Colors.white), // You can change the icon and its color
            )
          : null,
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
