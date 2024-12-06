import 'dart:io';

import 'package:flutter/material.dart';
//firebase imports
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
//notifier imports
import 'package:provider/provider.dart';
import 'notifier.dart';

//widgets and pages
import 'ui/main_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Check if Firebase has already been initialized
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print("Firebase initialization error: $e");
  }

  runApp(ChangeNotifierProvider(
    create: (context) => Controller(),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Timeless Echo',
      home: MainPage(),
    );
  }
}
