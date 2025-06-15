import 'package:flutter/material.dart';
import 'package:merema/core/theme/app_pallete.dart';
import 'package:merema/features/records/domain/entities/record_detail.dart';
import 'package:merema/features/records/presentation/widgets/record_details_view.dart';

class RecordDetailsDialog extends StatelessWidget {
  final RecordDetail recordDetail;

  const RecordDetailsDialog({
    super.key,
    required this.recordDetail,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Record Details',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppPallete.textColor,
                ),
              ),
            ),
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close, color: AppPallete.textColor),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: RecordDetailsView(
            recordDetail: recordDetail,
            showHeader: false,
          ),
        ),
      ],
    );
  }
}
