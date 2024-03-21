// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:petixfy/main.dart';

class SlashScreens extends StatefulWidget {
  const SlashScreens({Key? key}) : super(key: key);

  @override
  State<SlashScreens> createState() => _SlashScreensState();
}

class _SlashScreensState extends State<SlashScreens> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<PageViewModel> getPages() {
      return [
        PagesCustomSlider(
            "Tu tienes el control de tu mascota.",
            "Ellos son mas que un animal , son familia.",
            "assets/perro-sin-fondo.png"),
        PagesCustomSlider("No importa la raza , si no el amor.",
            "Todos ellos necesitan lo mejor.", "assets/perro-gato.png"),
        PagesCustomSlider("Con nosotros tienes seguridad y paz todo el tiempo.",
            "Nosotros somos tu mejor opcion.", "assets/mujer-perro.png"),
      ];
    }

    return Scaffold(
      body: IntroductionScreen(
        done: const Text(
          "Siguiente",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        onDone: () {
          Navigator.pushNamed(context, 'LoginScreen');
        },
        next: const Text(
          "",
          style: TextStyle(
            color: Colors.black,
            wordSpacing: 3,
          ),
        ),
        pages: getPages(),
        dotsDecorator: const DotsDecorator(
          activeColor: Color.fromRGBO(102, 45, 145, 1),
          color: Colors.white,
        ),
        globalBackgroundColor: const Color.fromRGBO(0, 169, 157, 1),
      ),
    );
  }

  //This is metod for pagesCustom
  PageViewModel PagesCustomSlider(
      String title, String description, String url) {
    return PageViewModel(
      image: Image.asset(
        url,
        height: 400,
        width: 400,
        fit: BoxFit.contain,
      ),
      title: title,
      body: description,
      decoration: const PageDecoration(
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
        bodyTextStyle: TextStyle(color: Colors.white),
      ),
    );
  }
}
