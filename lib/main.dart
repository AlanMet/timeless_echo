import 'package:flutter/material.dart';
// Firebase imports
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
// Notifier imports
import 'package:provider/provider.dart';
import 'notifier.dart';
// Widgets and pages
import 'ui/main_page.dart';
import 'dart:developer' as developer; // For logging purposes

/// The main entry point of the Timeless Echo application.
///
/// This file is responsible for:
/// - Initializing Firebase.
/// - Setting up a [ChangeNotifierProvider] for state management.
/// - Launching the root widget of the app.
void main() async {
  // Ensures Flutter bindings are initialized before running the app.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with platform-specific options.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    developer.log("Firebase initialized successfully", name: "main");
  } catch (e) {
    // Logs any errors that occur during Firebase initialization.
    developer.log(
      "Firebase initialization error",
      name: "main",
      error: e,
    );
  }

  // Runs the app, wrapping it with a state management provider.
  runApp(
    ChangeNotifierProvider(
      create: (context) => Controller(),
      child: const MyApp(),
    ),
  );
}

/// The root widget of the Timeless Echo application.
///
/// This widget initializes the app's main structure, including:
/// - Setting the app's title.
/// - Defining the initial home page as [MainPage].
class MyApp extends StatelessWidget {
  /// Creates an instance of [MyApp].
  const MyApp({super.key});

  /// Builds the widget tree for the application.
  ///
  /// This method sets up a [MaterialApp] with:
  /// - A title for the app: "Timeless Echo".
  /// - The default home page: [MainPage].
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Timeless Echo',
      home: MainPage(),
    );
  }
}
