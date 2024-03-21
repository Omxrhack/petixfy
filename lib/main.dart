import 'package:flutter/material.dart';

import 'package:petixfy/routes/screens_routes/app_routes_screens.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Petixfy',
      // Iniciamos la applicacion en una ruta especifica , al estar en la raiz del proyecto , se abarca a todo lo demas.
      initialRoute: AppRoute.inicialRoute,
      routes: AppRoute.getMenuRoutes(),
      onGenerateRoute: AppRoute.onGenerateRoute,
    );
  }
}
