import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:merema/core/theme/app_pallete.dart';
import 'package:merema/features/prescriptions/presentation/bloc/medications_state_cubit.dart';
import 'package:merema/features/prescriptions/presentation/widgets/medication_detail_card.dart';

class PrescriptionDetailsDialog extends StatelessWidget {
  final List<dynamic> prescriptionDetails;

  const PrescriptionDetailsDialog({
    super.key,
    required this.prescriptionDetails,
  });

  @override
  Widget build(BuildContext context) {
    for (var detail in prescriptionDetails) {
      context.read<MedicationsCubit>().fetchMedicationById(detail.medId);
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Prescription Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppPallete.textColor,
              ),
            ),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close, color: AppPallete.textColor),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  children: [
                    ...prescriptionDetails.map<Widget>((detail) => Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: MedicationDetailCard(detail: detail),
                        )),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
