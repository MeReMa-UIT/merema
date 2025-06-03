import 'package:flutter/material.dart';
import 'package:merema/core/layers/presentation/widgets/info_row.dart';
import 'package:merema/core/theme/app_pallete.dart';

class InfoField {
  final String label;
  final String value;

  const InfoField({
    required this.label,
    required this.value,
  });
}

class InfoCard extends StatelessWidget {
  final String title;
  final List<InfoField> fields;
  final IconData? icon;

  const InfoCard({
    super.key,
    required this.title,
    required this.fields,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 20,
                    color: AppPallete.primaryColor,
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...fields.map((field) => Column(
                  children: [
                    InfoRow(label: field.label, value: field.value),
                    if (field != fields.last) const Divider(),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
