import 'package:flutter/material.dart';
import 'package:merema/core/theme/app_pallete.dart';

class JsonTreeView extends StatelessWidget {
  final Map<String, dynamic> data;
  final String title;

  const JsonTreeView({
    super.key,
    required this.data,
    required this.title,
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
                const Icon(Icons.account_tree, color: AppPallete.primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppPallete.textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...data.entries.map((entry) => JsonTreeNode(
                  fieldKey: entry.key,
                  fieldValue: entry.value,
                  level: 0,
                )),
          ],
        ),
      ),
    );
  }
}

class JsonTreeNode extends StatelessWidget {
  final String fieldKey;
  final dynamic fieldValue;
  final int level;

  const JsonTreeNode({
    super.key,
    required this.fieldKey,
    required this.fieldValue,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    final indent = level * 40.0;
    final isComplexType = fieldValue is Map || fieldValue is List;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(left: indent, bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                constraints: const BoxConstraints(minWidth: 120),
                child: Text(
                  '$fieldKey:',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppPallete.textColor,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildValueWidget(),
              ),
            ],
          ),
        ),
        if (isComplexType) _buildNestedContent(),
      ],
    );
  }

  Widget _buildValueWidget() {
    if (fieldValue == null) {
      return const Text(
        'null',
        style: TextStyle(
          color: AppPallete.darkGrayColor,
          fontStyle: FontStyle.italic,
          fontSize: 14,
        ),
      );
    }

    if (fieldValue is Map || fieldValue is List) {
      return const SizedBox.shrink();
    }

    return Text(
      _formatValue(fieldValue),
      style: const TextStyle(
        color: AppPallete.textColor,
        fontSize: 14,
      ),
      softWrap: true,
    );
  }

  Widget _buildNestedContent() {
    if (fieldValue is Map) {
      final map = fieldValue as Map<String, dynamic>;
      return Column(
        children: map.entries
            .map((entry) => JsonTreeNode(
                  fieldKey: entry.key,
                  fieldValue: entry.value,
                  level: level + 1,
                ))
            .toList(),
      );
    }

    if (fieldValue is List) {
      final list = fieldValue as List;
      return Column(
        children: list
            .asMap()
            .entries
            .map((entry) => JsonTreeNode(
                  fieldKey: '[${entry.key}]',
                  fieldValue: entry.value,
                  level: level + 1,
                ))
            .toList(),
      );
    }

    return const SizedBox.shrink();
  }

  String _formatValue(dynamic value) {
    if (value == null) return 'null';

    if (value is String) {
      if (value.isEmpty) return '(empty)';

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
      if (value == -0.1) {
        return '0.0';
      }
      return value.toString();
    }
    if (value is bool) return value ? 'Yes' : 'No';

    return value.toString();
  }
}
