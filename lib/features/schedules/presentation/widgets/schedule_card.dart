import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart' hide State;
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/core/theme/app_pallete.dart';
import 'package:merema/features/schedules/domain/entities/schedule.dart';
import 'package:merema/features/schedules/domain/usecases/update_schedule_status.dart';

class ScheduleCard extends StatefulWidget {
  final Schedule schedule;
  final bool isReceptionist;
  final VoidCallback? onStatusUpdated;

  const ScheduleCard({
    super.key,
    required this.schedule,
    required this.isReceptionist,
    this.onStatusUpdated,
  });

  @override
  State<ScheduleCard> createState() => _ScheduleCardState();
}

class _ScheduleCardState extends State<ScheduleCard> {
  int? selectedStatus;

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.schedule.status;
  }

  @override
  void didUpdateWidget(covariant ScheduleCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.schedule.scheduleId != widget.schedule.scheduleId ||
        oldWidget.schedule.status != widget.schedule.status) {
      selectedStatus = widget.schedule.status;
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

  void _onStatusChanged(int? newStatus) async {
    if (newStatus != null && newStatus != selectedStatus) {
      try {
        final currentTime = '${DateTime.now().toIso8601String()}Z';
        final result = await sl<UpdateScheduleStatusUseCase>().call(
          Tuple3(widget.schedule.scheduleId, newStatus, currentTime),
        );

        result.fold(
          (error) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to update status: ${error.toString()}'),
                ),
              );
              setState(() {
                selectedStatus = widget.schedule.status;
              });
            }
          },
          (success) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Status updated successfully'),
                ),
              );
              setState(() {
                selectedStatus = newStatus;
              });
              widget.onStatusUpdated?.call();
            }
          },
        );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
            ),
          );
          setState(() {
            selectedStatus = widget.schedule.status;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Schedule #${widget.schedule.scheduleId}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Queue: ${widget.schedule.queueNumber}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildInfoRow('Examination Date',
                widget.schedule.examinationDate.split('T')[0]),
            _buildInfoRow('Expected Reception Time',
                widget.schedule.expectedReceptionTime.split('+')[0]),
            _buildInfoRow('Type', _getTypeText(widget.schedule.type)),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 200,
                    child: Text(
                      'Status:',
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: widget.isReceptionist
                          ? (selectedStatus == 1
                              ? SizedBox(
                                  width: 120,
                                  child: ElevatedButton(
                                    onPressed: () => _onStatusChanged(2),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor:
                                          AppPallete.backgroundColor,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                      textStyle: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.normal),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: const Text('Completed'),
                                  ),
                                )
                              : Text(
                                  _getStatusText(
                                      selectedStatus ?? widget.schedule.status),
                                  style: TextStyle(
                                    color: selectedStatus == 2
                                        ? Colors.green
                                        : selectedStatus == 3
                                            ? Colors.red
                                            : Colors.orange,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ))
                          : Text(
                              _getStatusText(widget.schedule.status),
                              style: TextStyle(
                                color: widget.schedule.status == 1
                                    ? Colors.orange
                                    : widget.schedule.status == 2
                                        ? Colors.green
                                        : Colors.red,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 200,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
