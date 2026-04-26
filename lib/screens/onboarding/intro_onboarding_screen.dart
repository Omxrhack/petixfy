import 'package:flutter/material.dart';
import 'package:petixfy/theme/app_colors.dart';
import 'package:petixfy/widgets/onboarding/onboarding_widgets.dart';

/// Pantalla de introducción animada para nuevos usuarios
class IntroOnboardingScreen extends StatefulWidget {
  const IntroOnboardingScreen({super.key});

  @override
  State<IntroOnboardingScreen> createState() => _IntroOnboardingScreenState();
}

class _IntroOnboardingScreenState extends State<IntroOnboardingScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  int _currentPage = 0;

  final List<_SlideData> _slides = [
    _SlideData(
      title: 'Bienvenido a Petixfy',
      description:
          'Tu compañero de confianza para el cuidado integral de tu mascota',
      imagePath: 'assets/perro-sin-fondo.png',
      icon: Icons.pets,
    ),
    _SlideData(
      title: 'Veterinarios a domicilio',
      description:
          'Atención profesional sin salir de casa. Agenda citas fácilmente',
      imagePath: 'assets/perro-gato.png',
      icon: Icons.medical_services,
    ),
    _SlideData(
      title: 'Seguimiento en tiempo real',
      description:
          'Siempre sabrás dónde está tu veterinario y cuándo llegará',
      imagePath: 'assets/mujer-perro.png',
      icon: Icons.location_on,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToRegister();
    }
  }

  void _navigateToRegister() {
    Navigator.pushReplacementNamed(context, 'RegisterScreen');
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    _animationController.reset();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.splashGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(child: _buildPageView()),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AnimatedOpacity(
            opacity: _currentPage > 0 ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: IconButton(
              onPressed: _currentPage > 0
                  ? () => _pageController.previousPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      )
                  : null,
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
              ),
            ),
          ),
          OnboardingSkipButton(
            text: 'Saltar',
            onPressed: _navigateToRegister,
          ),
        ],
      ),
    );
  }

  Widget _buildPageView() {
    return PageView.builder(
      controller: _pageController,
      onPageChanged: _onPageChanged,
      itemCount: _slides.length,
      itemBuilder: (context, index) {
        return _buildSlide(_slides[index]);
      },
    );
  }

  Widget _buildSlide(_SlideData slide) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              _buildIllustration(slide),
              const SizedBox(height: 48),
              _buildTitle(slide.title),
              const SizedBox(height: 16),
              _buildDescription(slide.description),
              const Spacer(flex: 2),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIllustration(_SlideData slide) {
    final animation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(animation),
        child: OnboardingIllustration(
          imagePath: slide.imagePath,
          size: 280,
          enableFloating: true,
        ),
      ),
    );
  }

  Widget _buildTitle(String title) {
    final animation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
    );

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(animation),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    );
  }

  Widget _buildDescription(String description) {
    final animation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    );

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(animation),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  height: 1.5,
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    final isLastPage = _currentPage == _slides.length - 1;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          AnimatedProgressIndicator(
            currentStep: _currentPage,
            totalSteps: _slides.length,
          ),
          const SizedBox(height: 32),
          OnboardingPrimaryButton(
            text: isLastPage ? 'Comenzar' : 'Siguiente',
            icon: isLastPage ? Icons.arrow_forward : null,
            onPressed: _nextPage,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _SlideData {
  final String title;
  final String description;
  final String imagePath;
  final IconData icon;

  const _SlideData({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.icon,
  });
}

