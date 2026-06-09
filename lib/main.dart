import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maydrama/utils/service.dart';

void main() {
  HttpOverrides.global = MayHttpBypass();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  static const darkColor = Color(0xFF121212);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "MayDrama",
      theme: ThemeData(
        useMaterial3: true,
        brightness: .light,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: .dark,
            systemNavigationBarColor: Colors.white,
            systemNavigationBarIconBrightness: .dark
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: .dark,
        scaffoldBackgroundColor: darkColor,
        appBarTheme: AppBarTheme(
          backgroundColor: darkColor,
          foregroundColor: Colors.white,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: .light,
            systemNavigationBarColor: darkColor,
            systemNavigationBarIconBrightness: .light
          ),
        ),
      ),
      themeMode: .system,
      debugShowCheckedModeBanner: false,
      home: const GridListDrama(),
    );
  }
}

class GridListDrama extends StatefulWidget {
  const GridListDrama({super.key});

  @override
  State<GridListDrama> createState() => GridListDramaState();
}

class GridListDramaState extends State<GridListDrama> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("MayDrama"),
      ),
    );
  }
}