import 'package:flutter/material.dart';
import 'package:petixfy/models/menu_optios.dart';
import 'package:petixfy/routes/screens_routes/Screens.dart';

class AppRoute {
  // Iniciamos la ruta en "slider"
  static const inicialRoute = 'slider';
  static final menuOptions = <MenuOptions>{
    //Todas las pantalla estan aqui como metodos , las cargamos una vez al iniciar la app
    MenuOptions(
      route: 'HomeScreen',
      title: 'home',
      screen: const HomeScreen(),
    ),
    MenuOptions(
      route: 'SlashScreens',
      title: 'slider',
      screen: const SlashScreens(),
    ),
    MenuOptions(
      route: 'LoginScreen',
      title: 'login',
      screen: const LoginScreen(),
    )
  };

  //Hacemos un mapeo de las pantallas para que la aplicacion las cargue solamente una vez
  static Map<String, Widget Function(BuildContext)> getMenuRoutes() {
    Map<String, Widget Function(BuildContext)> appRoutes = {};
    appRoutes
        .addAll({'slider': (BuildContext context) => const SlashScreens()});
    for (final options in menuOptions) {
      appRoutes
          .addAll({options.route: (BuildContext context) => options.screen});
    }
    return appRoutes;
  }

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => const ErrorScreen(),
    );
  }
}
