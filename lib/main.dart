import 'package:flutter/material.dart';
//Una sola importacion desde la raiz para que se reconosca todas las pantallas.
import 'package:petixfy/routes/screens_routes/Screens.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Petixfy',
      home: HomeScreen(),
    );
  }
}
