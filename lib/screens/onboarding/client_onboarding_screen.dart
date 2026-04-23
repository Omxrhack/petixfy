import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:petixfy/providers/auth_provider.dart';
import 'package:petixfy/widgets/vet_warm_theme.dart';

class ClientOnboardingScreen extends StatefulWidget {
  const ClientOnboardingScreen({super.key});

  @override
  State<ClientOnboardingScreen> createState() => _ClientOnboardingScreenState();
}

class _ClientOnboardingScreenState extends State<ClientOnboardingScreen> {
  static const int _totalSteps = 6;

  final PageController _pageController = PageController();
  final GlobalKey<FormState> _step1FormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _step3FormKey = GlobalKey<FormState>();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _homeNotesController = TextEditingController();
  final TextEditingController _petNameController = TextEditingController();

  int _currentStep = 0;
  String? _selectedSpecies;
  bool? _isNeutered;
  String? _vaccineStatus;
  String? _temperament;
  bool _locationCaptured = false;
  double _weightKg = 12;

  // Local map that accumulates each answer until final submit.
  final Map<String, dynamic> onboardingData = <String, dynamic>{
    'role': 'client',
    'client_details': <String, dynamic>{},
    'pet_profile': <String, dynamic>{},
  };

  @override
  void dispose() {
    _pageController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _homeNotesController.dispose();
    _petNameController.dispose();
    super.dispose();
  }

  double get _progressValue => (_currentStep + 1) / _totalSteps;

  void _useCurrentLocation() {
    setState(() {
      _locationCaptured = true;
      onboardingData['client_details'] = <String, dynamic>{
        ...(onboardingData['client_details'] as Map<String, dynamic>? ?? <String, dynamic>{}),
        'address_text': 'Ubicacion actual detectada',
        'latitude': 19.4326,
        'longitude': -99.1332,
      };
    });
  }

  bool _validateCurrentStep() {
    if (_currentStep == 0) {
      return _step1FormKey.currentState?.validate() ?? false;
    }

    if (_currentStep == 1) {
      if (!_locationCaptured) {
        _showError('Primero usa tu ubicacion actual para continuar.');
        return false;
      }
      return true;
    }

    if (_currentStep == 2) {
      final isFormValid = _step3FormKey.currentState?.validate() ?? false;
      if (!isFormValid) return false;
      if (_selectedSpecies == null) {
        _showError('Selecciona la especie de tu mascota.');
        return false;
      }
      return true;
    }

    if (_currentStep == 3) {
      if (_isNeutered == null) {
        _showError('Indica si tu mascota esta esterilizada.');
        return false;
      }
      return true;
    }

    if (_currentStep == 4) {
      if (_vaccineStatus == null) {
        _showError('Selecciona el estado de vacunas.');
        return false;
      }
      return true;
    }

    if (_currentStep == 5) {
      if (_temperament == null) {
        _showError('Selecciona el temperamento de la mascota.');
        return false;
      }
      return true;
    }

    return true;
  }

  void _collectCurrentStepData() {
    onboardingData['full_name'] = _fullNameController.text.trim();
    onboardingData['phone'] = _phoneController.text.trim();

    final clientDetails = <String, dynamic>{
      ...(onboardingData['client_details'] as Map<String, dynamic>? ?? <String, dynamic>{}),
      'address_notes': _homeNotesController.text.trim(),
    };

    final petProfile = <String, dynamic>{
      ...(onboardingData['pet_profile'] as Map<String, dynamic>? ?? <String, dynamic>{}),
      'name': _petNameController.text.trim(),
      'species': _selectedSpecies,
      'weight_kg': _weightKg,
      'is_neutered': _isNeutered,
      'vaccines_up_to_date': _vaccineStatus,
      'temperament': _temperament,
      'sex': 'female',
    };

    onboardingData['client_details'] = clientDetails;
    onboardingData['pet_profile'] = petProfile;
  }

  Future<void> _onNextPressed() async {
    if (!_validateCurrentStep()) return;
    _collectCurrentStepData();

    if (_currentStep == _totalSteps - 1) {
      await _submitOnboarding();
      return;
    }

    final nextStep = _currentStep + 1;
    setState(() => _currentStep = nextStep);
    _pageController.animateToPage(
      nextStep,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeInOut,
    );
  }

  void _onBackPressed() {
    if (_currentStep == 0) return;
    final previous = _currentStep - 1;
    setState(() => _currentStep = previous);
    _pageController.animateToPage(
      previous,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _submitOnboarding() async {
    final authProvider = context.read<AuthProvider>();
    final ok = await authProvider.submitClientOnboarding(onboardingData);
    if (!mounted) return;

    if (ok) {
      Navigator.pushReplacementNamed(context, 'HomeScreen');
      return;
    }

    _showError(authProvider.errorMessage ?? 'No se pudo finalizar onboarding.');
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Widget _buildStepContainer({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: VetWarmTheme.softCardDecoration(color: VetWarmTheme.card),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: VetWarmTheme.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(
                color: VetWarmTheme.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 18),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildStepIdentity() {
    return _buildStepContainer(
      title: 'Paso 1: Identidad',
      subtitle: 'Cuentanos como quieres que te llame el veterinario.',
      child: Form(
        key: _step1FormKey,
        child: Column(
          children: [
            TextFormField(
              controller: _fullNameController,
              decoration: InputDecoration(
                labelText: 'Nombre completo',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                filled: true,
                fillColor: VetWarmTheme.background,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El nombre es requerido';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Telefono movil',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                filled: true,
                fillColor: VetWarmTheme.background,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El telefono es requerido';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepLocation() {
    return _buildStepContainer(
      title: 'Paso 2: Ubicacion',
      subtitle: 'Ayudanos a llegar rapido a tu casa.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _useCurrentLocation,
              icon: Icon(
                _locationCaptured ? Icons.check_circle_outline : Icons.my_location,
              ),
              label: Text(
                _locationCaptured ? 'Ubicacion guardada' : 'Usar mi ubicacion actual',
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                backgroundColor: VetWarmTheme.amber,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _homeNotesController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Indicaciones de la casa',
              hintText: 'Casa azul, tocar timbre dos veces...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
              filled: true,
              fillColor: VetWarmTheme.background,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepPetIdentity() {
    return _buildStepContainer(
      title: 'Paso 3: Mascota',
      subtitle: 'Hablemos de tu mejor amigo.',
      child: Form(
        key: _step3FormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _petNameController,
              decoration: InputDecoration(
                labelText: 'Nombre de la mascota',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                filled: true,
                fillColor: VetWarmTheme.background,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El nombre de la mascota es requerido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Especie',
              style: TextStyle(
                color: VetWarmTheme.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['Perro', 'Gato', 'Otro'].map((species) {
                final selected = _selectedSpecies == species;
                return ChoiceChip(
                  label: Text(species),
                  selected: selected,
                  onSelected: (_) => setState(() => _selectedSpecies = species),
                  selectedColor: VetWarmTheme.amber.withValues(alpha: 0.24),
                  backgroundColor: VetWarmTheme.background,
                  labelStyle: TextStyle(
                    color: selected ? VetWarmTheme.textPrimary : VetWarmTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                    side: BorderSide.none,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepBiometry() {
    return _buildStepContainer(
      title: 'Paso 4: Biometria',
      subtitle: 'Datos rapidos para preparar dosis y equipo.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Peso aproximado: ${_weightKg.toStringAsFixed(1)} kg',
            style: const TextStyle(
              color: VetWarmTheme.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          Slider(
            value: _weightKg,
            min: 1,
            max: 50,
            divisions: 98,
            activeColor: VetWarmTheme.amber,
            onChanged: (value) => setState(() => _weightKg = value),
          ),
          const SizedBox(height: 8),
          const Text(
            'Esta esterilizado/a?',
            style: TextStyle(
              color: VetWarmTheme.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Si'),
                selected: _isNeutered == true,
                onSelected: (_) => setState(() => _isNeutered = true),
                selectedColor: VetWarmTheme.amber.withValues(alpha: 0.24),
                backgroundColor: VetWarmTheme.background,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide.none,
                ),
              ),
              ChoiceChip(
                label: const Text('No'),
                selected: _isNeutered == false,
                onSelected: (_) => setState(() => _isNeutered = false),
                selectedColor: VetWarmTheme.amber.withValues(alpha: 0.24),
                backgroundColor: VetWarmTheme.background,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide.none,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepHealth() {
    return _buildStepContainer(
      title: 'Paso 5: Salud',
      subtitle: 'Solo una confirmacion rapida sobre vacunas.',
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          _buildSelectableCard(
            title: 'Vacunas al dia',
            selected: _vaccineStatus == 'yes',
            onTap: () => setState(() => _vaccineStatus = 'yes'),
          ),
          _buildSelectableCard(
            title: 'Vacunas pendientes',
            selected: _vaccineStatus == 'no',
            onTap: () => setState(() => _vaccineStatus = 'no'),
          ),
          _buildSelectableCard(
            title: 'No estoy seguro',
            selected: _vaccineStatus == 'unsure',
            onTap: () => setState(() => _vaccineStatus = 'unsure'),
          ),
        ],
      ),
    );
  }

  Widget _buildStepTemperament() {
    return _buildStepContainer(
      title: 'Paso 6: Temperamento',
      subtitle: 'Esto ayuda a que el vet llegue preparado.',
      child: Column(
        children: [
          _buildTemperamentCard(
            icon: Icons.sentiment_very_satisfied_rounded,
            title: 'Amigable',
            subtitle: 'Se acerca tranquilo a personas nuevas.',
            selected: _temperament == 'friendly',
            onTap: () => setState(() => _temperament = 'friendly'),
          ),
          const SizedBox(height: 10),
          _buildTemperamentCard(
            icon: Icons.sentiment_neutral_rounded,
            title: 'Nervioso',
            subtitle: 'Puede asustarse con facilidad.',
            selected: _temperament == 'nervous',
            onTap: () => setState(() => _temperament = 'nervous'),
          ),
          const SizedBox(height: 10),
          _buildTemperamentCard(
            icon: Icons.warning_amber_rounded,
            title: 'Agresivo',
            subtitle: 'Conviene llevar equipo de contencion.',
            selected: _temperament == 'aggressive',
            onTap: () => setState(() => _temperament = 'aggressive'),
          ),
        ],
      ),
    );
  }

  Widget _buildTemperamentCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? VetWarmTheme.amber.withValues(alpha: 0.18) : VetWarmTheme.background,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? VetWarmTheme.amber : Colors.transparent,
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: VetWarmTheme.card,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: VetWarmTheme.textPrimary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: VetWarmTheme.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: VetWarmTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectableCard({
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? VetWarmTheme.amber.withValues(alpha: 0.24) : VetWarmTheme.background,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? VetWarmTheme.amber : Colors.transparent,
            width: 1.1,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: selected ? VetWarmTheme.textPrimary : VetWarmTheme.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: VetWarmTheme.background,
      appBar: AppBar(
        title: const Text('Onboarding Cliente'),
        backgroundColor: VetWarmTheme.background,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 6, 18, 4),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: _progressValue),
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeInOut,
              builder: (context, value, child) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: value,
                    minHeight: 8,
                    backgroundColor: VetWarmTheme.sand,
                    valueColor: const AlwaysStoppedAnimation<Color>(VetWarmTheme.amber),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Paso ${_currentStep + 1} de $_totalSteps',
              style: const TextStyle(
                color: VetWarmTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStepIdentity(),
                _buildStepLocation(),
                _buildStepPetIdentity(),
                _buildStepBiometry(),
                _buildStepHealth(),
                _buildStepTemperament(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: authProvider.isLoading ? null : _onBackPressed,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 52),
                        side: const BorderSide(color: VetWarmTheme.sand),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text('Atras'),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: authProvider.isLoading ? null : _onNextPressed,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 52),
                      backgroundColor: VetWarmTheme.amber,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: authProvider.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            _currentStep == _totalSteps - 1
                                ? 'Finalizar y Entrar'
                                : 'Siguiente',
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
