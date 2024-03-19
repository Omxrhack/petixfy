import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

class SlashScreens extends StatelessWidget {
  const SlashScreens({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<PageViewModel> getPages() {
      return [
        PageViewModel(
          image: Image.network(""),
          title: "Network",
          body: "Esto es un texto de prueba",
        ),
        PageViewModel(
          image: Image.network(""),
          title: "Network",
          body: "Esto es un texto de prueba",
        ),
        PageViewModel(
          image: Image.network(""),
          title: "Network",
          body: "Esto es un texto de prueba",
        )
      ];
    }

    return Scaffold(
      body: IntroductionScreen(
        done: const Text(
          "Siguiente",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        onDone: () {},
        pages: getPages(),
        globalBackgroundColor: const Color.fromRGBO(0, 169, 157, 1),
      ),
    );
  }
}
