import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:merema/core/theme/app_pallete.dart';
import 'package:merema/core/layers/presentation/widgets/info_card.dart';
import 'package:merema/core/layers/presentation/widgets/json_tree_view.dart';
import 'package:merema/features/records/domain/entities/record_detail.dart';
import 'package:merema/features/records/presentation/bloc/records_state_cubit.dart';

class RecordDetailsView extends StatelessWidget {
  final RecordDetail recordDetail;
  final bool showHeader;

  const RecordDetailsView({
    super.key,
    required this.recordDetail,
    this.showHeader = true,
  });

  @override
  Widget build(BuildContext context) {
    final recordsCubit = context.read<RecordsCubit>();
    final typeName = recordsCubit.getRecordTypeName(recordDetail.typeId);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showHeader) ...[
            Row(
              children: [
                const Icon(Icons.medical_information,
                    color: AppPallete.primaryColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Medical Record #${recordDetail.recordId}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppPallete.textColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          InfoCard(
            title: 'Basic Information',
            icon: Icons.info,
            fields: [
              InfoField(
                  label: 'Record ID', value: recordDetail.recordId.toString()),
              InfoField(label: 'Type', value: typeName),
              InfoField(
                  label: 'Created At',
                  value: _formatDateTime(recordDetail.createdAt)),
              if (recordDetail.expiredAt != null)
                InfoField(
                    label: 'Expired At',
                    value: _formatDateTime(recordDetail.expiredAt!)),
            ],
          ),
          const SizedBox(height: 16),
          JsonTreeView(
            data: recordDetail.recordDetail,
            title: 'Record Details',
          ),
        ],
      ),
    );
  }

  String _formatDateTime(String dateTime) {
    try {
      final parsedDate = DateTime.parse(dateTime);
      return '${parsedDate.day}/${parsedDate.month}/${parsedDate.year} ${parsedDate.hour.toString().padLeft(2, '0')}:${parsedDate.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTime;
    }
  }
}
