import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:merema/core/theme/app_pallete.dart';
import 'package:merema/features/records/domain/entities/record.dart';
import 'package:merema/features/records/presentation/bloc/records_state_cubit.dart';
import 'package:merema/features/records/presentation/bloc/records_state.dart';
import 'package:merema/features/records/presentation/widgets/record_card.dart';
import 'package:merema/features/records/presentation/pages/record_details_page.dart';

class RecordListView extends StatelessWidget {
  final int? patientId;
  final String? emptyMessage;
  final bool showPatientInfo;
  final bool useNavigation; // If true, navigate to page; if false, show dialog

  const RecordListView({
    super.key,
    this.patientId,
    this.emptyMessage,
    this.showPatientInfo = false,
    this.useNavigation = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecordsCubit, RecordsState>(
      builder: (context, state) {
        if (state is RecordsLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppPallete.primaryColor,
            ),
          );
        } else if (state is RecordsLoaded) {
          final records = state.filteredRecords;

          if (records.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.medical_information_outlined,
                    size: 64,
                    color: AppPallete.lightGrayColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    emptyMessage ?? 'No medical records found',
                    style: const TextStyle(
                      color: AppPallete.textColor,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: RecordCard(
                  record: record,
                  onViewDetails: () => _handleViewDetails(context, record),
                ),
              );
            },
          );
        } else if (state is RecordsError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppPallete.errorColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error: ${state.message}',
                  style: const TextStyle(
                    color: AppPallete.errorColor,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (patientId != null) {
                      context
                          .read<RecordsCubit>()
                          .getRecordsByPatient(patientId!);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppPallete.primaryColor,
                    foregroundColor: AppPallete.textColor,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _handleViewDetails(BuildContext context, Record record) {
    if (useNavigation) {
      Navigator.of(context).push(
        RecordDetailsPage.route(
          recordId: record.recordId,
          title: 'Medical Record #${record.recordId}',
        ),
      );
    } else {
      _showRecordDetailsDialog(context, record.recordId);
    }
  }

  void _showRecordDetailsDialog(BuildContext context, int recordId) {
    final recordsCubit = context.read<RecordsCubit>();
    final currentState = recordsCubit.state;
    RecordsState? storedState;

    if (currentState is RecordsLoaded) {
      storedState = currentState;
    }

    recordsCubit.getRecordDetails(recordId);

    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: recordsCubit,
        child: Dialog(
          backgroundColor: AppPallete.backgroundColor,
          child: Container(
            width: 600,
            height: MediaQuery.of(context).size.height * 0.8,
            padding: const EdgeInsets.all(16),
            child: BlocBuilder<RecordsCubit, RecordsState>(
              builder: (context, state) {
                if (state is RecordDetailsLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppPallete.primaryColor,
                    ),
                  );
                } else if (state is RecordDetailsLoaded) {
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
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            icon: const Icon(Icons.close,
                                color: AppPallete.textColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Basic Information
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.info,
                                              color: AppPallete.primaryColor),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Basic Information',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: AppPallete.textColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      _buildInfoRow(
                                          'Record ID',
                                          state.recordDetail.recordId
                                              .toString()),
                                      _buildInfoRow(
                                          'Type',
                                          context
                                              .read<RecordsCubit>()
                                              .getRecordTypeName(
                                                  state.recordDetail.typeId)),
                                      _buildInfoRow(
                                          'Created At',
                                          _formatDateTime(
                                              state.recordDetail.createdAt)),
                                      if (state.recordDetail.expiredAt != null)
                                        _buildInfoRow(
                                            'Expired At',
                                            _formatDateTime(
                                                state.recordDetail.expiredAt!)),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Record Details
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.description,
                                              color: AppPallete.primaryColor),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Record Details',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: AppPallete.textColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      ..._buildRecordDetailRows(
                                          state.recordDetail.recordDetail),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                } else if (state is RecordsError) {
                  return Center(
                    child: Text(
                      'Error loading details: ${state.message}',
                      style: const TextStyle(color: AppPallete.errorColor),
                    ),
                  );
                }
                return const Center(
                  child: Text(
                    'Loading...',
                    style: TextStyle(color: AppPallete.textColor),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    ).then((_) {
      if (storedState != null) {
        recordsCubit.restoreRecordsState(storedState);
      }
    });
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
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

  List<Widget> _buildRecordDetailRows(Map<String, dynamic> recordDetail) {
    final rows = <Widget>[];

    for (final entry in recordDetail.entries) {
      final key = _formatFieldKey(entry.key);
      final value = _formatFieldValue(entry.value);

      rows.add(_buildInfoRow(key, value));
    }

    return rows;
  }

  String _formatFieldKey(String key) {
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

    if (value is num) return value.toString();
    if (value is bool) return value ? 'Yes' : 'No';
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

  String _formatDateTime(String dateTime) {
    try {
      final parsedDate = DateTime.parse(dateTime);
      return '${parsedDate.day}/${parsedDate.month}/${parsedDate.year} ${parsedDate.hour.toString().padLeft(2, '0')}:${parsedDate.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTime;
    }
  }
}
