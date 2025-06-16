import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:merema/core/theme/app_pallete.dart';
import 'package:merema/core/layers/presentation/widgets/info_card.dart';
import 'package:merema/features/records/domain/entities/record.dart';
import 'package:merema/features/records/presentation/bloc/records_state_cubit.dart';

class RecordCard extends StatelessWidget {
  final Record record;
  final VoidCallback onViewDetails;

  const RecordCard({
    super.key,
    required this.record,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final recordsCubit = context.read<RecordsCubit>();
    final typeName = recordsCubit.getRecordTypeName(record.typeId);

    final primaryDiagnosisName = record.primaryDiagnosis.isNotEmpty
        ? recordsCubit.getDiagnosisName(record.primaryDiagnosis)
        : 'Not specified';

    final secondaryDiagnosisName = record.secondaryDiagnosis.isNotEmpty
        ? recordsCubit.getDiagnosisName(record.secondaryDiagnosis)
        : 'Not specified';

    return Column(
      children: [
        InfoCard(
          title: 'Medical Record #${record.recordId}',
          icon: Icons.medical_information,
          fields: [
            InfoField(label: 'Type', value: typeName),
            InfoField(label: 'Primary Diagnosis', value: primaryDiagnosisName),
            InfoField(
                label: 'Secondary Diagnosis', value: secondaryDiagnosisName),
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
