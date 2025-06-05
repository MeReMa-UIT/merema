import 'package:flutter/material.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/core/theme/app_pallete.dart';
import 'package:merema/core/layers/presentation/widgets/app_button.dart';
import 'package:merema/features/schedules/domain/usecases/book_schedule.dart';

class BookScheduleDialog extends StatefulWidget {
  final VoidCallback? onScheduleBooked;

  const BookScheduleDialog({super.key, this.onScheduleBooked});

  @override
  State<BookScheduleDialog> createState() => _BookScheduleDialogState();
}

class _BookScheduleDialogState extends State<BookScheduleDialog> {
  DateTime? selectedDate = DateTime.now();
  int selectedType = 1;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppPallete.primaryColor,
              onPrimary: AppPallete.textColor,
              onSurface: AppPallete.textColor,
            ),
            dialogBackgroundColor: AppPallete.backgroundColor,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _bookSchedule() async {
    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a date'),
          backgroundColor: AppPallete.errorColor,
        ),
      );
      return;
    }

    try {
      final formattedDate =
          '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}T00:00:00Z';

      final result =
          await sl<BookScheduleUseCase>().call((formattedDate, selectedType));

      result.fold(
        (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to book schedule: ${error.message}'),
              backgroundColor: AppPallete.errorColor,
            ),
          );
        },
        (success) {
          final parentContext = context;
          Navigator.of(context).pop();
          widget.onScheduleBooked?.call();
          Future.delayed(const Duration(milliseconds: 100), () {
            if (parentContext.mounted) {
              _showSuccessDialog(parentContext, success);
            }
          });
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppPallete.errorColor,
        ),
      );
    }
  }

  void _showSuccessDialog(BuildContext parentContext, dynamic scheduleData) {
    showDialog(
      context: Navigator.of(parentContext, rootNavigator: true).context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          'Schedule Booked Successfully!',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppPallete.textColor,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Queue Number',
                scheduleData['queue_number']?.toString() ?? 'N/A'),
            _buildInfoRow(
                'Examination Date',
                scheduleData['examination_date']?.toString().split('T')[0] ??
                    'N/A'),
            _buildInfoRow(
                'Expected Reception Time',
                scheduleData['expected_reception_time']
                        ?.toString()
                        .split('+')[0] ??
                    'N/A'),
            _buildInfoRow('Type', _getTypeText(scheduleData['type'] ?? 1)),
            _buildInfoRow(
                'Status', _getStatusText(scheduleData['status'] ?? 1)),
          ],
        ),
        actions: [
          AppButton(
            text: 'OK',
            onPressed: () => Navigator.of(dialogContext).pop(),
            width: double.infinity,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 200,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppPallete.textColor,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: AppPallete.textColor),
            ),
          ),
        ],
      ),
    );
  }

  String _getTypeText(int type) {
    switch (type) {
      case 1:
        return 'Regular';
      case 2:
        return 'Service';
      default:
        return 'Unknown';
    }
  }

  String _getStatusText(int status) {
    switch (status) {
      case 1:
        return 'Waiting';
      case 2:
        return 'Completed';
      case 3:
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Book Schedule',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: AppPallete.textColor,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Date:',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: AppPallete.textColor,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _selectDate(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(color: AppPallete.lightGrayColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedDate == null
                        ? 'Select examination date'
                        : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                    style: TextStyle(
                      color: selectedDate == null
                          ? AppPallete.lightGrayColor
                          : AppPallete.textColor,
                    ),
                  ),
                  const Icon(
                    Icons.calendar_today,
                    color: AppPallete.primaryColor,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
            value: selectedType,
            decoration: const InputDecoration(
              labelText: 'Type',
              border: OutlineInputBorder(),
              labelStyle: TextStyle(color: AppPallete.textColor),
              floatingLabelStyle: TextStyle(color: AppPallete.textColor),
            ),
            dropdownColor: AppPallete.backgroundColor,
            style: const TextStyle(color: AppPallete.textColor),
            iconEnabledColor: AppPallete.textColor,
            items: const [
              DropdownMenuItem(value: 1, child: Text('Regular')),
              DropdownMenuItem(value: 2, child: Text('Service')),
            ],
            onChanged: (int? newValue) {
              if (newValue != null) {
                setState(() {
                  selectedType = newValue;
                });
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Cancel',
            style: TextStyle(color: AppPallete.lightGrayColor),
          ),
        ),
        ElevatedButton(
          onPressed: _bookSchedule,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppPallete.primaryColor,
            foregroundColor: Colors.white,
          ),
          child: const Text('Book Schedule'),
        ),
      ],
    );
  }
}
