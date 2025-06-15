import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:merema/core/theme/app_pallete.dart';
import 'package:merema/core/layers/presentation/widgets/info_card.dart';
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

          // Basic Information Card
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

          // Record Details Card - Dynamic content based on the JSON structure
          InfoCard(
            title: 'Record Details',
            icon: Icons.description,
            fields: _buildRecordDetailFields(recordDetail.recordDetail),
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

  List<InfoField> _buildRecordDetailFields(Map<String, dynamic> recordDetail) {
    final fields = <InfoField>[];

    for (final entry in recordDetail.entries) {
      final key = entry.key;
      final value = entry.value;

      // Convert the key to a more readable format
      final readableKey = _formatFieldKey(key);

      // Format the value based on its type
      final formattedValue = _formatFieldValue(value);

      fields.add(InfoField(
        label: readableKey,
        value: formattedValue,
      ));
    }

    return fields;
  }

  String _formatFieldKey(String key) {
    // Convert snake_case or camelCase to Title Case
    return key
        .replaceAll('_', ' ')
        .replaceAllMapped(RegExp(r'([a-z])([A-Z])'),
            (match) => '${match.group(1)} ${match.group(2)}')
        .split(' ')
        .map((word) => word.isNotEmpty
            ? word[0].toUpperCase() + word.substring(1).toLowerCase()
            : '')
        .join(' ');
  }

  String _formatFieldValue(dynamic value) {
    if (value == null) return 'Not specified';

    if (value is String) {
      if (value.isEmpty) return 'Not specified';

      // Try to format if it looks like a date
      if (RegExp(r'^\d{4}-\d{2}-\d{2}').hasMatch(value)) {
        try {
          final parsedDate = DateTime.parse(value);
          return '${parsedDate.day}/${parsedDate.month}/${parsedDate.year}';
        } catch (e) {
          return value;
        }
      }

      return value;
    }

    if (value is num) {
      return value.toString();
    }

    if (value is bool) {
      return value ? 'Yes' : 'No';
    }

    if (value is List) {
      if (value.isEmpty) return 'None';
      return value.map((item) => _formatFieldValue(item)).join(', ');
    }

    if (value is Map) {
      final entries = value.entries
          .map((entry) =>
              '${_formatFieldKey(entry.key.toString())}: ${_formatFieldValue(entry.value)}')
          .join('\n');
      return entries.isNotEmpty ? entries : 'Empty';
    }

    return value.toString();
  }
}
