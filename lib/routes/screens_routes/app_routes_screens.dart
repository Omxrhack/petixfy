import 'package:flutter/material.dart';
import 'package:petixfy/models/menu_optios.dart';
import 'package:petixfy/routes/screens_routes/Screens.dart';

class AppRoute {
  // Iniciamos la ruta en "slider"
  static const inicialRoute = 'validar';
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
      screen: const IntroOnboardingScreen(),
    ),
    MenuOptions(
      route: 'IntroOnboardingScreen',
      title: 'intro-onboarding',
      screen: const IntroOnboardingScreen(),
    ),
    MenuOptions(
      route: 'LoginScreen',
      title: 'login',
      screen: const LoginScreen(),
    ),
    MenuOptions(
      route: 'RegisterScreen',
      title: 'register',
      screen: const RegisterScreen(),
    ),
    MenuOptions(
      route: 'OtpScreen',
      title: 'otp',
      screen: const OtpScreen(),
    ),
    MenuOptions(
      route: 'OnboardingScreen',
      title: 'onboarding',
      screen: const OnboardingScreen(),
    ),
    MenuOptions(
      route: 'ClientOnboardingScreen',
      title: 'client-onboarding',
      screen: const ClientOnboardingScreen(),
    ),
    MenuOptions(
      route: 'VetDashboardScreen',
      title: 'vet-dashboard',
      screen: const VetDashboardScreen(),
    ),
    MenuOptions(
      route: 'VetScheduleScreen',
      title: 'vet-schedule',
      screen: const VetScheduleScreen(),
    ),
    MenuOptions(
      route: 'EmergencyAlertScreen',
      title: 'vet-emergency',
      screen: const EmergencyAlertScreen(),
    ),
    MenuOptions(
      route: 'PatientRecordScreen',
      title: 'vet-patient-record',
      screen: const PatientRecordScreen(),
    ),
    MenuOptions(
      route: 'VetProfileScreen',
      title: 'vet-profile',
      screen: const VetProfileScreen(),
    ),
    MenuOptions(
      route: 'VetActiveRouteScreen',
      title: 'vet-active-route',
      screen: const VetActiveRouteScreen(trackingId: 'demo-tracking-id'),
    ),
    MenuOptions(
      route: 'ClientTrackingScreen',
      title: 'client-tracking',
      screen: const ClientTrackingScreen(trackingId: 'demo-tracking-id'),
    ),
    MenuOptions(
      route: 'ValidarScreen',
      screen: const ValidarScreen(),
      title: 'validar',
    ),
  };

  //Hacemos un mapeo de las pantallas para que la aplicacion las cargue solamente una vez
  static Map<String, Widget Function(BuildContext)> getMenuRoutes() {
    Map<String, Widget Function(BuildContext)> appRoutes = {};
    appRoutes
        .addAll({'validar': (BuildContext context) => const ValidarScreen()});
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
