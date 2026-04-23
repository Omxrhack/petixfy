import 'package:flutter/material.dart';
import 'package:petixfy/services/auth_api.dart';
import 'package:petixfy/services/auth_state.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const int _totalSteps = 6;
  static const List<String> _vetServicesOptions = [
    'vacunacion',
    'curaciones',
    'analisis_laboratorio',
    'eutanasia_casa',
  ];

  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _avatarUrlController = TextEditingController();

  final _addressController = TextEditingController();
  final _addressNotesController = TextEditingController();
  final _clientLatitudeController = TextEditingController();
  final _clientLongitudeController = TextEditingController();
  final _petNameController = TextEditingController();
  final _petSpeciesController = TextEditingController();
  final _petBreedController = TextEditingController();
  final _petWeightController = TextEditingController();
  final _petMedicalNotesController = TextEditingController();

  final _cedulaController = TextEditingController();
  final _universityController = TextEditingController();
  final _vetLatitudeController = TextEditingController();
  final _vetLongitudeController = TextEditingController();
  final _scheduleController = TextEditingController();
  final _clabeController = TextEditingController();
  final _bankController = TextEditingController();
  final _rfcController = TextEditingController();

  String _role = 'client';
  int _step = 0;
  bool _loading = false;

  String _petSex = 'male';
  DateTime? _petBirthDate;
  bool _petNeutered = false;
  String _petVaccines = 'unsure';
  String _petTemperament = 'friendly';

  String _vetExperience = '1-3';
  double _vetCoverage = 10;
  bool _vetHasVehicle = false;
  String _vetSpecialty = 'medicina_general';
  bool _vetAcceptsEmergencies = false;
  final Set<String> _vetOfferedServices = {'vacunacion'};

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _avatarUrlController.dispose();
    _addressController.dispose();
    _addressNotesController.dispose();
    _clientLatitudeController.dispose();
    _clientLongitudeController.dispose();
    _petNameController.dispose();
    _petSpeciesController.dispose();
    _petBreedController.dispose();
    _petWeightController.dispose();
    _petMedicalNotesController.dispose();
    _cedulaController.dispose();
    _universityController.dispose();
    _vetLatitudeController.dispose();
    _vetLongitudeController.dispose();
    _scheduleController.dispose();
    _clabeController.dispose();
    _bankController.dispose();
    _rfcController.dispose();
    super.dispose();
  }

  double get _progress => (_step + 1) / _totalSteps;

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 40, 1, 1),
      lastDate: now,
      initialDate: _petBirthDate ?? DateTime(now.year - 1, now.month, now.day),
    );
    if (picked != null) {
      setState(() => _petBirthDate = picked);
    }
  }

  String? _validateCurrentStep() {
    if (_step == 0) {
      if (_fullNameController.text.trim().isEmpty) return 'Full name is required';
      if (_phoneController.text.trim().isEmpty) return 'Phone is required';
      if (_role == 'vet' && _avatarUrlController.text.trim().isEmpty) {
        return 'Avatar URL is required for vets';
      }
      return null;
    }

    if (_role == 'client') {
      if (_step == 1 && _addressController.text.trim().isEmpty) return 'Address is required';
      if (_step == 2) {
        if (_petNameController.text.trim().isEmpty) return 'Pet name is required';
        if (_petSpeciesController.text.trim().isEmpty) return 'Pet species is required';
      }
      if (_step == 3 && _petWeightController.text.trim().isEmpty) {
        return 'Pet weight is required';
      }
      return null;
    }

    if (_role == 'vet') {
      if (_step == 1 && _cedulaController.text.trim().isEmpty) return 'Cedula is required';
      if (_step == 5) {
        if (_clabeController.text.trim().length != 18) return 'CLABE must be 18 digits';
        if (_bankController.text.trim().isEmpty) return 'Bank name is required';
      }
      return null;
    }

    return null;
  }

  void _nextStep() {
    final error = _validateCurrentStep();
    if (error != null) {
      _showError(error);
      return;
    }
    if (_step < _totalSteps - 1) {
      setState(() => _step += 1);
    }
  }

  void _backStep() {
    if (_step > 0) {
      setState(() => _step -= 1);
    }
  }

  Future<void> _submit() async {
    final error = _validateCurrentStep();
    if (error != null) {
      _showError(error);
      return;
    }

    setState(() => _loading = true);
    try {
      final payload = _role == 'client' ? _buildClientPayload() : _buildVetPayload();
      await AuthApi.onboarding(payload);
      await AppAuthState.save(newOnboardingCompleted: true);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, 'HomeScreen');
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Map<String, dynamic> _buildClientPayload() {
    return {
      'role': 'client',
      'full_name': _fullNameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'avatar_url': _avatarUrlController.text.trim(),
      'client_details': {
        'address_text': _addressController.text.trim(),
        'address_notes': _addressNotesController.text.trim(),
        'latitude': _toDoubleOrNull(_clientLatitudeController.text),
        'longitude': _toDoubleOrNull(_clientLongitudeController.text),
      },
      'pet_profile': {
        'name': _petNameController.text.trim(),
        'species': _petSpeciesController.text.trim(),
        'breed': _petBreedController.text.trim(),
        'sex': _petSex,
        'birth_date': _petBirthDate != null ? _formatDate(_petBirthDate!) : null,
        'weight_kg': _toDoubleOrNull(_petWeightController.text),
        'is_neutered': _petNeutered,
        'vaccines_up_to_date': _petVaccines,
        'medical_notes': _petMedicalNotesController.text.trim(),
        'temperament': _petTemperament,
      },
    };
  }

  Map<String, dynamic> _buildVetPayload() {
    return {
      'role': 'vet',
      'full_name': _fullNameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'avatar_url': _avatarUrlController.text.trim(),
      'vet_details': {
        'cedula': _cedulaController.text.trim(),
        'university': _universityController.text.trim(),
        'experience_years': _vetExperience,
        'base_latitude': _toDoubleOrNull(_vetLatitudeController.text),
        'base_longitude': _toDoubleOrNull(_vetLongitudeController.text),
        'coverage_radius_km': _vetCoverage,
        'has_vehicle': _vetHasVehicle,
      },
      'vet_services': {
        'specialty': _vetSpecialty,
        'offered_services': _vetOfferedServices.toList(),
        'accepts_emergencies': _vetAcceptsEmergencies,
        'schedule_json': {'label': _scheduleController.text.trim()},
      },
      'vet_finances': {
        'clabe': _clabeController.text.trim(),
        'bank_name': _bankController.text.trim(),
        'rfc': _rfcController.text.trim(),
      },
    };
  }

  double? _toDoubleOrNull(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) return null;
    return double.tryParse(normalized);
  }

  String _formatDate(DateTime date) {
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '${date.year}-$m-$d';
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message.replaceFirst('Exception: ', '')),
        backgroundColor: Colors.red,
      ),
    );
  }

  Widget _stepContent() {
    if (_role == 'client') return _clientStepContent();
    return _vetStepContent();
  }

  Widget _clientStepContent() {
    switch (_step) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _stepTitle('Step 1 - Identity and contact'),
            TextField(
              controller: _fullNameController,
              decoration: const InputDecoration(labelText: 'Full name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Mobile phone'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _avatarUrlController,
              decoration: const InputDecoration(labelText: 'Avatar URL (optional)'),
            ),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _stepTitle('Step 2 - Logistics and location'),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Exact address'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _addressNotesController,
              decoration: const InputDecoration(labelText: 'Additional directions'),
              maxLines: 2,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _clientLatitudeController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Latitude'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _clientLongitudeController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Longitude'),
                  ),
                ),
              ],
            ),
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _stepTitle('Step 3 - Pet identity'),
            TextField(
              controller: _petNameController,
              decoration: const InputDecoration(labelText: 'Pet name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _petSpeciesController,
              decoration: const InputDecoration(labelText: 'Species (dog, cat, bird)'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _petBreedController,
              decoration: const InputDecoration(labelText: 'Breed'),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: _petSex,
              items: const [
                DropdownMenuItem(value: 'male', child: Text('Male')),
                DropdownMenuItem(value: 'female', child: Text('Female')),
              ],
              onChanged: (value) => setState(() => _petSex = value ?? 'male'),
              decoration: const InputDecoration(labelText: 'Sex'),
            ),
          ],
        );
      case 3:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _stepTitle('Step 4 - Basic biometrics'),
            OutlinedButton(
              onPressed: _pickBirthDate,
              child: Text(
                _petBirthDate == null ? 'Select birth date' : 'Birth date: ${_formatDate(_petBirthDate!)}',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _petWeightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Weight in kg'),
            ),
            const SizedBox(height: 10),
            SwitchListTile(
              value: _petNeutered,
              onChanged: (value) => setState(() => _petNeutered = value),
              title: const Text('Neutered/Spayed'),
            ),
          ],
        );
      case 4:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _stepTitle('Step 5 - Medical quick history'),
            DropdownButtonFormField<String>(
              initialValue: _petVaccines,
              items: const [
                DropdownMenuItem(value: 'yes', child: Text('Vaccines up to date')),
                DropdownMenuItem(value: 'no', child: Text('Vaccines not up to date')),
                DropdownMenuItem(value: 'unsure', child: Text('Not sure')),
              ],
              onChanged: (value) => setState(() => _petVaccines = value ?? 'unsure'),
              decoration: const InputDecoration(labelText: 'Vaccines status'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _petMedicalNotesController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Allergies or conditions (optional)'),
            ),
          ],
        );
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _stepTitle('Step 6 - Temperament and safety'),
            DropdownButtonFormField<String>(
              initialValue: _petTemperament,
              items: const [
                DropdownMenuItem(value: 'friendly', child: Text('Friendly and calm')),
                DropdownMenuItem(value: 'nervous', child: Text('Nervous or fearful')),
                DropdownMenuItem(value: 'aggressive', child: Text('Aggressive or territorial')),
              ],
              onChanged: (value) => setState(() => _petTemperament = value ?? 'friendly'),
              decoration: const InputDecoration(labelText: 'Temperament'),
            ),
          ],
        );
    }
  }

  Widget _vetStepContent() {
    switch (_step) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _stepTitle('Step 1 - Professional identity'),
            TextField(
              controller: _fullNameController,
              decoration: const InputDecoration(labelText: 'Full name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Mobile phone'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _avatarUrlController,
              decoration: const InputDecoration(labelText: 'Profile photo URL (required)'),
            ),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _stepTitle('Step 2 - Credentials and verification'),
            TextField(
              controller: _cedulaController,
              decoration: const InputDecoration(labelText: 'Professional license (cedula)'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _universityController,
              decoration: const InputDecoration(labelText: 'University'),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: _vetExperience,
              items: const [
                DropdownMenuItem(value: '1-3', child: Text('1-3 years')),
                DropdownMenuItem(value: '4-7', child: Text('4-7 years')),
                DropdownMenuItem(value: '8+', child: Text('8+ years')),
              ],
              onChanged: (value) => setState(() => _vetExperience = value ?? '1-3'),
              decoration: const InputDecoration(labelText: 'Experience'),
            ),
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _stepTitle('Step 3 - Logistics and mobility'),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _vetLatitudeController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Base latitude'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _vetLongitudeController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Base longitude'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text('Coverage radius: ${_vetCoverage.toStringAsFixed(0)} km'),
            Slider(
              value: _vetCoverage,
              min: 1,
              max: 50,
              divisions: 49,
              onChanged: (v) => setState(() => _vetCoverage = v),
            ),
            SwitchListTile(
              value: _vetHasVehicle,
              onChanged: (v) => setState(() => _vetHasVehicle = v),
              title: const Text('Has own vehicle for emergencies'),
            ),
          ],
        );
      case 3:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _stepTitle('Step 4 - Specialty and services'),
            DropdownButtonFormField<String>(
              initialValue: _vetSpecialty,
              items: const [
                DropdownMenuItem(value: 'medicina_general', child: Text('General medicine')),
                DropdownMenuItem(value: 'urgencias', child: Text('Emergency')),
                DropdownMenuItem(value: 'exoticos', child: Text('Exotics')),
                DropdownMenuItem(value: 'nutricion', child: Text('Nutrition')),
                DropdownMenuItem(value: 'fisioterapia', child: Text('Physiotherapy')),
              ],
              onChanged: (value) => setState(() => _vetSpecialty = value ?? 'medicina_general'),
              decoration: const InputDecoration(labelText: 'Main specialty'),
            ),
            const SizedBox(height: 10),
            const Text('Services offered at home'),
            ..._vetServicesOptions.map(
              (service) => CheckboxListTile(
                dense: true,
                title: Text(service),
                value: _vetOfferedServices.contains(service),
                onChanged: (checked) {
                  setState(() {
                    if (checked == true) {
                      _vetOfferedServices.add(service);
                    } else {
                      _vetOfferedServices.remove(service);
                      if (_vetOfferedServices.isEmpty) {
                        _vetOfferedServices.add('vacunacion');
                      }
                    }
                  });
                },
              ),
            ),
          ],
        );
      case 4:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _stepTitle('Step 5 - Availability and emergencies'),
            TextField(
              controller: _scheduleController,
              decoration: const InputDecoration(labelText: 'Regular schedule (ex. Mon-Fri 9:00-18:00)'),
            ),
            const SizedBox(height: 10),
            SwitchListTile(
              value: _vetAcceptsEmergencies,
              onChanged: (v) => setState(() => _vetAcceptsEmergencies = v),
              title: const Text('Available for emergencies outside schedule'),
            ),
          ],
        );
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _stepTitle('Step 6 - Finance details'),
            TextField(
              controller: _clabeController,
              keyboardType: TextInputType.number,
              maxLength: 18,
              decoration: const InputDecoration(labelText: 'CLABE (18 digits)', counterText: ''),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _bankController,
              decoration: const InputDecoration(labelText: 'Bank name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _rfcController,
              decoration: const InputDecoration(labelText: 'RFC (optional)'),
            ),
          ],
        );
    }
  }

  Widget _stepTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Onboarding'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: LinearProgressIndicator(
            minHeight: 6,
            value: _progress,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'client', label: Text('Pet owner')),
                ButtonSegment(value: 'vet', label: Text('Veterinarian')),
              ],
              selected: {_role},
              onSelectionChanged: (selection) {
                setState(() {
                  _role = selection.first;
                  _step = 0;
                });
              },
            ),
            const SizedBox(height: 8),
            Text('Progress: ${(_progress * 100).round()}%'),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                child: _stepContent(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (_step > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _loading ? null : _backStep,
                      child: const Text('Back'),
                    ),
                  ),
                if (_step > 0) const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _loading ? null : (_step == _totalSteps - 1 ? _submit : _nextStep),
                    child: _loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_step == _totalSteps - 1 ? 'Finish onboarding' : 'Next'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
