// ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:foodsaver/ui/main_view.dart';
import 'package:foodsaver/ui/screens/homepage.dart';
import 'package:foodsaver/ui/screens/sing_up_screen.dart';
import 'firebase_options.dart';


void main() async{
   WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        
        primaryColor: Color(0xFF755DC1),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Color(0xFF755DC1)
        )
      ),
      
      debugShowCheckedModeBanner: false,
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, usersnapshot) {
          if (usersnapshot.hasData) {
            print("ok");
            return HomePage();
          } else {
            print('nok');
            return MainView();
          }
        },
      ),
    );
  }
}