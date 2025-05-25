import 'package:flutter/material.dart';
import 'package:merema/features/profile/presentation/widgets/info_row.dart';

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

  const InfoCard({
    super.key,
    required this.title,
    required this.fields,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
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
