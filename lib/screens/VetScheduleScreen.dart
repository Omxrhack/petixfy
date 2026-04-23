import 'package:flutter/material.dart';
import 'package:petixfy/widgets/vet_appointment_card.dart';
import 'package:petixfy/widgets/vet_warm_theme.dart';

class VetScheduleScreen extends StatelessWidget {
  const VetScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appointments = [
      (
        hour: '08:30',
        petName: 'Luna',
        ownerName: 'Daniela Perez',
        colony: 'Col. Del Valle',
        type: 'Vacunacion',
        urgency: false,
      ),
      (
        hour: '10:15',
        petName: 'Toby',
        ownerName: 'Marco Rojas',
        colony: 'Napoles',
        type: 'Curaciones',
        urgency: false,
      ),
      (
        hour: '12:40',
        petName: 'Nala',
        ownerName: 'Sofia Leon',
        colony: 'Condesa',
        type: 'Urgencia',
        urgency: true,
      ),
    ];

    return Scaffold(
      backgroundColor: VetWarmTheme.background,
      appBar: AppBar(
        title: const Text('Agenda y Ruta'),
        backgroundColor: VetWarmTheme.background,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          final item = appointments[index];
          return VetAppointmentCard(
            hour: item.hour,
            petName: item.petName,
            ownerName: item.ownerName,
            colony: item.colony,
            serviceType: item.type,
            isUrgency: item.urgency,
            onRouteTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Abriendo ruta para ${item.petName}...'),
                  backgroundColor: VetWarmTheme.textPrimary,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
