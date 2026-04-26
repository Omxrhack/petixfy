import 'package:flutter/material.dart';
import 'package:petixfy/theme/app_colors.dart';

/// Selector visual de tipo de mascota
class PetTypeSelector extends StatelessWidget {
  final String? selectedType;
  final ValueChanged<String> onTypeSelected;

  const PetTypeSelector({
    super.key,
    this.selectedType,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _PetTypeCard(
            type: 'dog',
            label: 'Perro',
            icon: Icons.pets,
            emoji: '🐕',
            isSelected: selectedType == 'dog',
            onTap: () => onTypeSelected('dog'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _PetTypeCard(
            type: 'cat',
            label: 'Gato',
            icon: Icons.pets,
            emoji: '🐈',
            isSelected: selectedType == 'cat',
            onTap: () => onTypeSelected('cat'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _PetTypeCard(
            type: 'other',
            label: 'Otro',
            icon: Icons.cruelty_free,
            emoji: '🐾',
            isSelected: selectedType == 'other',
            onTap: () => onTypeSelected('other'),
          ),
        ),
      ],
    );
  }
}

class _PetTypeCard extends StatelessWidget {
  final String type;
  final String label;
  final IconData icon;
  final String emoji;
  final bool isSelected;
  final VoidCallback onTap;

  const _PetTypeCard({
    required this.type,
    required this.label,
    required this.icon,
    required this.emoji,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primarySurface : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 40),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Selector de temperamento con chips visuales
class TemperamentSelector extends StatelessWidget {
  final List<String> selectedTemperaments;
  final ValueChanged<List<String>> onChanged;

  const TemperamentSelector({
    super.key,
    required this.selectedTemperaments,
    required this.onChanged,
  });

  static const List<Map<String, dynamic>> temperaments = [
    {'id': 'calm', 'label': 'Tranquilo', 'icon': Icons.spa},
    {'id': 'playful', 'label': 'Juguetón', 'icon': Icons.sports_tennis},
    {'id': 'friendly', 'label': 'Amigable', 'icon': Icons.favorite},
    {'id': 'shy', 'label': 'Tímido', 'icon': Icons.visibility_off},
    {'id': 'energetic', 'label': 'Enérgico', 'icon': Icons.bolt},
    {'id': 'protective', 'label': 'Protector', 'icon': Icons.shield},
  ];

  void _toggleTemperament(String id) {
    final newList = List<String>.from(selectedTemperaments);
    if (newList.contains(id)) {
      newList.remove(id);
    } else {
      newList.add(id);
    }
    onChanged(newList);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: temperaments.map((temp) {
        final isSelected = selectedTemperaments.contains(temp['id']);
        return _TemperamentChip(
          label: temp['label'],
          icon: temp['icon'],
          isSelected: isSelected,
          onTap: () => _toggleTemperament(temp['id']),
        );
      }).toList(),
    );
  }
}

class _TemperamentChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TemperamentChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Selector de sexo de mascota
class PetSexSelector extends StatelessWidget {
  final String? selectedSex;
  final ValueChanged<String> onSexSelected;

  const PetSexSelector({
    super.key,
    this.selectedSex,
    required this.onSexSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SexOption(
            value: 'male',
            label: 'Macho',
            icon: Icons.male,
            isSelected: selectedSex == 'male',
            onTap: () => onSexSelected('male'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _SexOption(
            value: 'female',
            label: 'Hembra',
            icon: Icons.female,
            isSelected: selectedSex == 'female',
            onTap: () => onSexSelected('female'),
          ),
        ),
      ],
    );
  }
}

class _SexOption extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _SexOption({
    required this.value,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = value == 'male' ? Colors.blue : Colors.pink;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : AppColors.borderLight,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? color : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: isSelected ? color : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
