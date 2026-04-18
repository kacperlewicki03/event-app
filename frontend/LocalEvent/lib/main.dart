import 'package:flutter/material.dart';
import 'screens/main_navigation.dart';

void main() {
  runApp(const LocalEventApp());
}

class LocalEventApp extends StatelessWidget {
  const LocalEventApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LocalEvent',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainNavigation(),
    );
  }
}
