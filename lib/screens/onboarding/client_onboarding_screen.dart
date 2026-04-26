import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:petixfy/providers/auth_provider.dart';
import 'package:petixfy/theme/app_colors.dart';
import 'package:petixfy/widgets/onboarding/onboarding_widgets.dart';

class ClientOnboardingScreen extends StatefulWidget {
  const ClientOnboardingScreen({super.key});

  @override
  State<ClientOnboardingScreen> createState() => _ClientOnboardingScreenState();
}

class _ClientOnboardingScreenState extends State<ClientOnboardingScreen>
    with TickerProviderStateMixin {
  static const int _totalSteps = 5;

  final PageController _pageController = PageController();
  late AnimationController _animationController;

  final GlobalKey<FormState> _step1FormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _step3FormKey = GlobalKey<FormState>();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _homeNotesController = TextEditingController();
  final TextEditingController _petNameController = TextEditingController();

  int _currentStep = 0;
  String? _selectedSpecies;
  String? _selectedSex;
  bool? _isNeutered;
  String? _vaccineStatus;
  List<String> _selectedTemperaments = [];
  bool _locationCaptured = false;
  double _weightKg = 12;

  final Map<String, dynamic> onboardingData = <String, dynamic>{
    'role': 'client',
    'client_details': <String, dynamic>{},
    'pet_profile': <String, dynamic>{},
  };

  static const List<_StepInfo> _steps = [
    _StepInfo(
      title: 'Sobre ti',
      subtitle: 'Cuéntanos cómo te llamas para personalizar tu experiencia',
      icon: Icons.person_outline,
    ),
    _StepInfo(
      title: 'Tu ubicación',
      subtitle: 'Ayúdanos a llegar rápido cuando lo necesites',
      icon: Icons.location_on_outlined,
    ),
    _StepInfo(
      title: 'Tu mascota',
      subtitle: 'Háblanos de tu mejor amigo',
      icon: Icons.pets_outlined,
    ),
    _StepInfo(
      title: 'Datos de salud',
      subtitle: 'Información importante para su cuidado',
      icon: Icons.favorite_outline,
    ),
    _StepInfo(
      title: 'Personalidad',
      subtitle: 'Esto ayuda a que el veterinario llegue preparado',
      icon: Icons.psychology_outlined,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _homeNotesController.dispose();
    _petNameController.dispose();
    super.dispose();
  }

  void _useCurrentLocation() {
    setState(() {
      _locationCaptured = true;
      onboardingData['client_details'] = <String, dynamic>{
        ...(onboardingData['client_details'] as Map<String, dynamic>? ??
            <String, dynamic>{}),
        'address_text': 'Ubicación actual detectada',
        'latitude': 19.4326,
        'longitude': -99.1332,
      };
    });
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _step1FormKey.currentState?.validate() ?? false;
      case 1:
        if (!_locationCaptured) {
          _showError('Primero usa tu ubicación actual para continuar.');
          return false;
        }
        return true;
      case 2:
        final isFormValid = _step3FormKey.currentState?.validate() ?? false;
        if (!isFormValid) return false;
        if (_selectedSpecies == null) {
          _showError('Selecciona el tipo de mascota.');
          return false;
        }
        if (_selectedSex == null) {
          _showError('Selecciona el sexo de tu mascota.');
          return false;
        }
        return true;
      case 3:
        if (_isNeutered == null) {
          _showError('Indica si tu mascota está esterilizada.');
          return false;
        }
        if (_vaccineStatus == null) {
          _showError('Selecciona el estado de vacunas.');
          return false;
        }
        return true;
      case 4:
        if (_selectedTemperaments.isEmpty) {
          _showError('Selecciona al menos un rasgo de personalidad.');
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  void _collectCurrentStepData() {
    onboardingData['full_name'] = _fullNameController.text.trim();
    onboardingData['phone'] = _phoneController.text.trim();

    final clientDetails = <String, dynamic>{
      ...(onboardingData['client_details'] as Map<String, dynamic>? ??
          <String, dynamic>{}),
      'address_notes': _homeNotesController.text.trim(),
    };

    final petProfile = <String, dynamic>{
      ...(onboardingData['pet_profile'] as Map<String, dynamic>? ??
          <String, dynamic>{}),
      'name': _petNameController.text.trim(),
      'species': _selectedSpecies,
      'sex': _selectedSex,
      'weight_kg': _weightKg,
      'is_neutered': _isNeutered,
      'vaccines_up_to_date': _vaccineStatus,
      'temperament': _mapTemperamentForApi(_selectedTemperaments),
    };

    onboardingData['client_details'] = clientDetails;
    onboardingData['pet_profile'] = petProfile;
  }

  /// Backend [friendly, nervous, aggressive] a partir de los chips de UI.
  String _mapTemperamentForApi(List<String> selected) {
    if (selected.isEmpty) return 'friendly';
    if (selected.any((id) => id == 'shy' || id == 'protective')) {
      return 'nervous';
    }
    return 'friendly';
  }

  /// Cuerpo conforme a [auth.schema.js] (clientOnboardingSchema).
  Map<String, dynamic> _buildApiPayload() {
    _collectCurrentStepData();

    final rawPhone = _phoneController.text.trim();
    final phoneDigits = rawPhone.replaceAll(RegExp(r'[^0-9]'), '');
    if (phoneDigits.length < 8 || phoneDigits.length > 15) {
      throw Exception(
        'El teléfono debe tener entre 8 y 15 dígitos (sin contar espacios).',
      );
    }
    final phone = phoneDigits.length <= 15
        ? phoneDigits
        : phoneDigits.substring(phoneDigits.length - 15);

    final clientMap = onboardingData['client_details'] as Map<String, dynamic>?;
    var addressText =
        (clientMap?['address_text'] ?? '').toString().trim();
    if (addressText.length < 5) {
      addressText = 'Domicilio registrado en la app';
    }

    final notes = (clientMap?['address_notes'] ?? '').toString().trim();
    final lat = clientMap?['latitude'];
    final lng = clientMap?['longitude'];

    return <String, dynamic>{
      'role': 'client',
      'full_name': _fullNameController.text.trim(),
      'phone': phone,
      'client_details': <String, dynamic>{
        'address_text': addressText,
        if (notes.isNotEmpty) 'address_notes': notes,
        if (lat != null) 'latitude': lat,
        if (lng != null) 'longitude': lng,
      },
      'pet_profile': <String, dynamic>{
        'name': _petNameController.text.trim(),
        'species': _selectedSpecies ?? 'other',
        'sex': _selectedSex,
        'weight_kg': _weightKg,
        'is_neutered': _isNeutered,
        'vaccines_up_to_date': _vaccineStatus,
        'temperament': _mapTemperamentForApi(_selectedTemperaments),
      },
    };
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
    _animationController.reset();
    _animationController.forward();
    _pageController.animateToPage(
      nextStep,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  void _onBackPressed() {
    if (_currentStep == 0) return;
    final previous = _currentStep - 1;
    setState(() => _currentStep = previous);
    _animationController.reset();
    _animationController.forward();
    _pageController.animateToPage(
      previous,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _submitOnboarding() async {
    final authProvider = context.read<AuthProvider>();
    Map<String, dynamic> payload;
    try {
      payload = _buildApiPayload();
    } catch (e) {
      _showError(e.toString().replaceFirst(RegExp(r'^Exception:\s*'), ''));
      return;
    }

    final ok = await authProvider.submitClientOnboarding(payload);
    if (!mounted) return;

    if (ok) {
      Navigator.pushReplacementNamed(context, 'HomeScreen');
      return;
    }

    _showError(
        authProvider.errorMessage ?? 'No se pudo finalizar el onboarding.');
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStepIdentity(),
                  _buildStepLocation(),
                  _buildStepPetIdentity(),
                  _buildStepHealth(),
                  _buildStepTemperament(),
                ],
              ),
            ),
            _buildFooter(authProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Column(
        children: [
          Row(
            children: [
              if (_currentStep > 0)
                IconButton(
                  onPressed: _onBackPressed,
                  icon: const Icon(Icons.arrow_back_ios),
                  color: AppColors.textPrimary,
                )
              else
                const SizedBox(width: 48),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      _steps[_currentStep].title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 16),
          OnboardingProgressBar(
            currentStep: _currentStep,
            totalSteps: _totalSteps,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(AuthProvider authProvider) {
    final isLastStep = _currentStep == _totalSteps - 1;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0) ...[
            Expanded(
              child: OnboardingSecondaryButton(
                text: 'Atrás',
                icon: Icons.arrow_back,
                onPressed: authProvider.isLoading ? null : _onBackPressed,
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            flex: _currentStep > 0 ? 2 : 1,
            child: OnboardingPrimaryButton(
              text: isLastStep ? 'Finalizar' : 'Continuar',
              icon: isLastStep ? Icons.check : Icons.arrow_forward,
              isLoading: authProvider.isLoading,
              onPressed: authProvider.isLoading ? null : _onNextPressed,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContainer({
    required String subtitle,
    required IconData icon,
    required Widget child,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(subtitle, icon),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }

  Widget _buildStepHeader(String subtitle, IconData icon) {
    final animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(animation),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildStepIdentity() {
    return _buildStepContainer(
      subtitle: _steps[0].subtitle,
      icon: _steps[0].icon,
      child: _buildCard(
        child: Form(
          key: _step1FormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Información personal',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre completo',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El nombre es requerido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Teléfono móvil',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El teléfono es requerido';
                  }
                  final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
                  if (digits.length < 8 || digits.length > 15) {
                    return 'Entre 8 y 15 dígitos (puedes usar + y espacios)';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepLocation() {
    return _buildStepContainer(
      subtitle: _steps[1].subtitle,
      icon: _steps[1].icon,
      child: _buildCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dirección de visita',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 20),
            _buildLocationButton(),
            const SizedBox(height: 20),
            TextField(
              controller: _homeNotesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Indicaciones para llegar',
                hintText: 'Casa azul, tocar timbre dos veces...',
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 48),
                  child: Icon(Icons.notes_outlined),
                ),
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationButton() {
    return GestureDetector(
      onTap: _useCurrentLocation,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _locationCaptured
              ? AppColors.successLight
              : AppColors.primarySurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _locationCaptured ? AppColors.success : AppColors.primary,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _locationCaptured ? AppColors.success : AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _locationCaptured ? Icons.check : Icons.my_location,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _locationCaptured
                        ? 'Ubicación guardada'
                        : 'Usar mi ubicación actual',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: _locationCaptured
                              ? AppColors.success
                              : AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _locationCaptured
                        ? 'Tu dirección ha sido registrada'
                        : 'Toca para detectar tu ubicación',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: _locationCaptured ? AppColors.success : AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepPetIdentity() {
    return _buildStepContainer(
      subtitle: _steps[2].subtitle,
      icon: _steps[2].icon,
      child: _buildCard(
        child: Form(
          key: _step3FormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Datos de tu mascota',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _petNameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de tu mascota',
                  prefixIcon: Icon(Icons.pets_outlined),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El nombre es requerido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Text(
                'Tipo de mascota',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),
              PetTypeSelector(
                selectedType: _selectedSpecies,
                onTypeSelected: (type) {
                  setState(() => _selectedSpecies = type);
                },
              ),
              const SizedBox(height: 24),
              Text(
                'Sexo',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),
              PetSexSelector(
                selectedSex: _selectedSex,
                onSexSelected: (sex) {
                  setState(() => _selectedSex = sex);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepHealth() {
    return _buildStepContainer(
      subtitle: _steps[3].subtitle,
      icon: _steps[3].icon,
      child: Column(
        children: [
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Peso aproximado',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${_weightKg.toStringAsFixed(1)}',
                      style:
                          Theme.of(context).textTheme.headlineLarge?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'kg',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppColors.primary,
                    inactiveTrackColor: AppColors.borderLight,
                    thumbColor: AppColors.primary,
                    overlayColor: AppColors.primary.withOpacity(0.2),
                  ),
                  child: Slider(
                    value: _weightKg,
                    min: 1,
                    max: 50,
                    divisions: 98,
                    onChanged: (value) => setState(() => _weightKg = value),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¿Está esterilizado/a?',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildOptionCard(
                        title: 'Sí',
                        icon: Icons.check_circle_outline,
                        isSelected: _isNeutered == true,
                        onTap: () => setState(() => _isNeutered = true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildOptionCard(
                        title: 'No',
                        icon: Icons.cancel_outlined,
                        isSelected: _isNeutered == false,
                        onTap: () => setState(() => _isNeutered = false),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estado de vacunas',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 16),
                _buildVaccineOption(
                  title: 'Vacunas al día',
                  icon: Icons.verified_outlined,
                  value: 'yes',
                ),
                const SizedBox(height: 8),
                _buildVaccineOption(
                  title: 'Vacunas pendientes',
                  icon: Icons.schedule_outlined,
                  value: 'no',
                ),
                const SizedBox(height: 8),
                _buildVaccineOption(
                  title: 'No estoy seguro',
                  icon: Icons.help_outline,
                  value: 'unsure',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primarySurface : AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color:
                        isSelected ? AppColors.primary : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVaccineOption({
    required String title,
    required IconData icon,
    required String value,
  }) {
    final isSelected = _vaccineStatus == value;

    return GestureDetector(
      onTap: () => setState(() => _vaccineStatus = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primarySurface : AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color:
                        isSelected ? AppColors.primary : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepTemperament() {
    return _buildStepContainer(
      subtitle: _steps[4].subtitle,
      icon: _steps[4].icon,
      child: _buildCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personalidad de tu mascota',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Selecciona los rasgos que mejor describan a tu mascota',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 20),
            TemperamentSelector(
              selectedTemperaments: _selectedTemperaments,
              onChanged: (temps) {
                setState(() => _selectedTemperaments = temps);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StepInfo {
  final String title;
  final String subtitle;
  final IconData icon;

  const _StepInfo({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}
