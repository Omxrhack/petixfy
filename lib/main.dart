// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:petixfy/routes/screens_routes/app_routes_screens.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://ayuqhfsgrsqakuhtsgwn.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImF5dXFoZnNncnNxYWt1aHRzZ3duIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTA5NjUxODcsImV4cCI6MjAyNjU0MTE4N30.LJ2PfOT6DBT6Yf01T3KzS7cUIqAR8hNLYmOdahb7nbs',
  );

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({
    Key? key,
  }) : super(key: key);
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
