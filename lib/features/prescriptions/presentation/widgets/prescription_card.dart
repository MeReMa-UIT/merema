import 'package:flutter/material.dart';
import 'package:merema/core/theme/app_pallete.dart';
import 'package:merema/core/layers/presentation/widgets/info_card.dart';

class PrescriptionCard extends StatelessWidget {
  final dynamic prescription;
  final VoidCallback onViewDetails;

  const PrescriptionCard({
    super.key,
    required this.prescription,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final createdDate = prescription.createdAt.split('T')[0];
    final receivedDate =
        prescription.receivedAt?.split('T')[0] ?? 'Not yet received';

    return Column(
      children: [
        InfoCard(
          title: 'Prescription #${prescription.prescriptionId}',
          icon: Icons.medical_services,
          fields: [
            InfoField(label: 'Created Date', value: createdDate),
            InfoField(label: 'Received At', value: receivedDate),
            InfoField(
                label: 'Insurance Covered',
                value: prescription.isInsuranceCovered ? 'Yes' : 'No'),
            InfoField(
                label: 'Notes',
                value: prescription.prescriptionNote.isNotEmpty
                    ? prescription.prescriptionNote
                    : 'No notes'),
          ],
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: onViewDetails,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppPallete.primaryColor,
            foregroundColor: AppPallete.textColor,
          ),
          child: const Text('View Details'),
        ),
      ],
    );
  }
}
