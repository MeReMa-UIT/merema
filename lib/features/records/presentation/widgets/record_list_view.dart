import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:merema/core/theme/app_pallete.dart';
import 'package:merema/core/layers/presentation/widgets/json_tree_view.dart';
import 'package:merema/features/records/domain/entities/record.dart';
import 'package:merema/features/records/presentation/bloc/records_state_cubit.dart';
import 'package:merema/features/records/presentation/bloc/records_state.dart';
import 'package:merema/features/records/presentation/widgets/record_card.dart';

class RecordListView extends StatelessWidget {
  final int? patientId;
  final String? emptyMessage;
  final bool showPatientInfo;

  const RecordListView({
    super.key,
    this.patientId,
    this.emptyMessage,
    this.showPatientInfo = false,
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
    _showRecordDetailsDialog(context, record.recordId);
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
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.95,
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
                        child: DefaultTabController(
                          length: 2,
                          child: Column(
                            children: [
                              const TabBar(
                                labelColor: AppPallete.primaryColor,
                                unselectedLabelColor: AppPallete.darkGrayColor,
                                indicatorColor: AppPallete.primaryColor,
                                tabs: [
                                  Tab(
                                    icon: Icon(Icons.info),
                                    text: 'Details',
                                  ),
                                  Tab(
                                    icon: Icon(Icons.attachment),
                                    text: 'Attachments',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Expanded(
                                child: TabBarView(
                                  children: [
                                    _buildDetailsTab(state, context),
                                    _buildAttachmentsTab(),
                                  ],
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

  Widget _buildDetailsTab(RecordDetailsLoaded state, BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.info, color: AppPallete.primaryColor),
                      SizedBox(width: 8),
                      Text(
                        'Basic Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppPallete.textColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                      'Record ID', state.recordDetail.recordId.toString()),
                  _buildInfoRow(
                      'Type',
                      context
                          .read<RecordsCubit>()
                          .getRecordTypeName(state.recordDetail.typeId)),
                  _buildInfoRow('Created At',
                      _formatDateTime(state.recordDetail.createdAt)),
                  if (state.recordDetail.expiredAt != null)
                    _buildInfoRow('Expired At',
                        _formatDateTime(state.recordDetail.expiredAt!)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildJsonTreeView(state.recordDetail.recordDetail),
        ],
      ),
    );
  }

  Widget _buildAttachmentsTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.attachment_outlined,
            size: 64,
            color: AppPallete.lightGrayColor,
          ),
          SizedBox(height: 16),
          Text(
            'Attachments feature coming soon',
            style: TextStyle(
              color: AppPallete.darkGrayColor,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'This will display medical record attachments\nsuch as X-rays, CT scans, test results, etc.',
            style: TextStyle(
              color: AppPallete.lightGrayColor,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
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

  String _formatDateTime(String dateTime) {
    try {
      final parsedDate = DateTime.parse(dateTime);
      return '${parsedDate.day}/${parsedDate.month}/${parsedDate.year} ${parsedDate.hour.toString().padLeft(2, '0')}:${parsedDate.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTime;
    }
  }

  Widget _buildJsonTreeView(Map<String, dynamic> recordDetail) {
    return JsonTreeView(
      data: recordDetail,
      title: 'Record Details',
    );
  }
}
