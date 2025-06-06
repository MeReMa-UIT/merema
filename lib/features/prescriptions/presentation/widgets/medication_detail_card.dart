import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:merema/features/prescriptions/presentation/bloc/medications_state_cubit.dart';
import 'package:merema/features/prescriptions/presentation/bloc/medications_state.dart';
import 'package:merema/core/layers/presentation/widgets/info_card.dart';

class MedicationDetailCard extends StatelessWidget {
  final dynamic detail;

  const MedicationDetailCard({
    super.key,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MedicationsCubit, MedicationsState>(
      builder: (context, medicationState) {
        final medicationsCubit = context.read<MedicationsCubit>();
        final medication = medicationsCubit.getMedicationById(detail.medId);

        return InfoCard(
          title: medication != null
              ? '${medication.genericName} (${medication.strength})'
              : 'Loading medication...',
          icon: Icons.medication,
          fields: [
            if (medication != null) ...[
              InfoField(label: 'Name', value: medication.name),
              InfoField(label: 'Type', value: medication.medType),
              InfoField(
                  label: 'Route', value: medication.routeOfAdministration),
              InfoField(label: 'Manufacturer', value: medication.manufacturer),
            ],
            InfoField(
                label: 'Morning Dosage',
                value:
                    '${detail.morningDosage.toStringAsFixed(1)} ${detail.dosageUnit}'),
            InfoField(
                label: 'Afternoon Dosage',
                value:
                    '${detail.afternoonDosage.toStringAsFixed(1)} ${detail.dosageUnit}'),
            InfoField(
                label: 'Evening Dosage',
                value:
                    '${detail.eveningDosage.toStringAsFixed(1)} ${detail.dosageUnit}'),
            InfoField(
                label: 'Total Dosage',
                value:
                    '${detail.totalDosage.toStringAsFixed(1)} ${detail.dosageUnit}'),
            InfoField(label: 'Duration', value: '${detail.durationDays} days'),
            InfoField(
                label: 'Instructions',
                value: detail.instructions.isNotEmpty
                    ? detail.instructions
                    : 'No specific instructions'),
          ],
        );
      },
    );
  }
}
