import 'package:flutter/material.dart';
import 'pages/license_screen.dart';
import 'pages/todo_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Safe List',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LicenseScreen(),
      routes: {
        '/todo-list': (context) {
          return TodoListScreen();
        },
      },
    );
  }
}
