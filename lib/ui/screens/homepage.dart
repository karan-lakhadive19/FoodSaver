import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
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
                            fontWeight: FontWeight.bold
                          ),
                    ),
                    SizedBox(width: 7,),
                      Text(
                          '${username}',
                          style: GoogleFonts.poppins(
                            color: Color(0xFF9F7BFF),
                            fontSize: 25,
                            fontWeight: FontWeight.bold
                          ),
                    ),
                       ],
                     );
                    } else {
                      return Text('Hi User');
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
            icon: Icon(Icons.login_outlined, color: Color(0xFF755DC1), size: 35),
          )
        ],
      ),
      body: Center(
        child: Text('Welcome to your home page'),
      ),
    );
  }
}
