import 'package:chatbot/chatbot.dart';
import 'package:chatbot/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'ChatBot',
      debugShowCheckedModeBanner: false,
      home: FirebaseAuth.instance.currentUser != null
          ? ChatScreen()
          : const LoginScreen(),
    );
  }
}
