import 'package:flutter/material.dart';
import 'package:merema/core/theme/app_pallete.dart';
import 'package:merema/core/layers/presentation/widgets/custom_dropdown.dart';

class TimePeriodSelector extends StatelessWidget {
  final String selectedTimeUnit;
  final String selectedTimestamp;
  final Function(String timeUnit)? onTimeUnitChanged;
  final Function(String timestamp)? onTimestampChanged;

  const TimePeriodSelector({
    super.key,
    required this.selectedTimeUnit,
    required this.selectedTimestamp,
    this.onTimeUnitChanged,
    this.onTimestampChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Time Period',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppPallete.textColor,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildTimeUnitDropdown(),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    flex: 2,
                    child: _buildDatePicker(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeUnitDropdown() {
    final timeUnits = ['week', 'month', 'year'];

    return CustomDropdown<String>(
      selectedValue: selectedTimeUnit,
      availableItems: timeUnits,
      onChanged: (value) {
        if (value != null && onTimeUnitChanged != null) {
          onTimeUnitChanged!(value);
        }
      },
      labelText: 'Time Unit',
      getDisplayText: (timeUnit) {
        switch (timeUnit) {
          case 'week':
            return 'Week';
          case 'month':
            return 'Month';
          case 'year':
            return 'Year';
          default:
            return timeUnit;
        }
      },
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    final dateTime = DateTime.tryParse(selectedTimestamp) ?? DateTime.now();

    return GestureDetector(
      onTap: () => _selectDate(context),
      child: AbsorbPointer(
        child: TextFormField(
          decoration: const InputDecoration(
            labelText: 'Date',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            suffixIcon: Icon(
              Icons.calendar_today,
              color: AppPallete.primaryColor,
            ),
            labelStyle: TextStyle(color: AppPallete.textColor),
            floatingLabelStyle: TextStyle(color: AppPallete.textColor),
          ),
          controller: TextEditingController(text: _formatDate(dateTime)),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final dateTime = DateTime.tryParse(selectedTimestamp) ?? DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: dateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppPallete.primaryColor,
              onPrimary: Colors.white,
              onSurface: AppPallete.textColor,
              surface: AppPallete.backgroundColor,
            ),
            dialogBackgroundColor: AppPallete.backgroundColor,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppPallete.primaryColor,
              ),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: AppPallete.primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && onTimestampChanged != null) {
      final newTimestamp = picked.toUtc().toIso8601String();
      onTimestampChanged!(newTimestamp);
    }
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/'
        '${dateTime.month.toString().padLeft(2, '0')}'
        '/${dateTime.year}';
  }
}
