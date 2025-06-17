import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:merema/core/theme/app_pallete.dart';
import 'package:merema/features/records/domain/entities/record.dart';
import 'package:merema/features/records/presentation/bloc/records_state_cubit.dart';
import 'package:merema/features/records/presentation/bloc/records_state.dart';
import 'package:merema/features/records/presentation/widgets/record_card.dart';
import 'package:merema/features/records/presentation/widgets/record_details_dialog.dart';
import 'package:merema/features/records/presentation/widgets/record_create_dialog.dart';
import 'package:merema/features/patients/presentation/bloc/patient_infos_state_cubit.dart';

class RecordListView extends StatefulWidget {
  final int? patientId;
  final String? patientName;
  final String? emptyMessage;
  final bool isFromDoctorPage;
  final VoidCallback? onPrescriptionCreated;
  final VoidCallback? onRecordCreated;
  final VoidCallback? onRecordUpdated;

  const RecordListView({
    super.key,
    this.patientId,
    this.patientName,
    this.emptyMessage,
    this.isFromDoctorPage = false,
    this.onPrescriptionCreated,
    this.onRecordCreated,
    this.onRecordUpdated,
  });

  @override
  State<RecordListView> createState() => _RecordListViewState();
}

class _RecordListViewState extends State<RecordListView> {
  RecordsState? _storedRecordsState;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.isFromDoctorPage &&
            widget.patientId != null &&
            widget.patientName != null)
          _buildHeader(context),
        Expanded(
          child: BlocBuilder<RecordsCubit, RecordsState>(
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
                          widget.emptyMessage ?? 'No medical records found',
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
                        onViewDetails: () =>
                            _handleViewDetails(context, record),
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
                          if (widget.patientId != null) {
                            context
                                .read<RecordsCubit>()
                                .getRecordsByPatient(widget.patientId!);
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
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppPallete.backgroundColor,
        border: Border(
          bottom: BorderSide(
            color: AppPallete.lightGrayColor.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.medical_information,
            color: AppPallete.primaryColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Medical Records',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppPallete.textColor,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => _showCreateRecordDialog(context),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Create Record'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppPallete.primaryColor,
              foregroundColor: AppPallete.textColor,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateRecordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                PatientInfosCubit()..getInfos(widget.patientId!),
          ),
        ],
        child: RecordCreateDialog(
          patientId: widget.patientId!,
          patientName: widget.patientName!,
          onCancel: () => Navigator.of(dialogContext).pop(),
          onSuccess: () {
            Navigator.of(dialogContext).pop();
            context.read<RecordsCubit>().getRecordsByPatient(widget.patientId!);
            widget.onRecordCreated!();
          },
        ),
      ),
    );
  }

  void _handleViewDetails(BuildContext context, Record record) {
    final currentState = context.read<RecordsCubit>().state;
    if (currentState is RecordsLoaded) {
      _storedRecordsState = currentState;
    }

    final recordsCubit = context.read<RecordsCubit>();

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
            child: Builder(
              builder: (context) {
                context.read<RecordsCubit>().getRecordDetails(record.recordId);

                return BlocBuilder<RecordsCubit, RecordsState>(
                  builder: (context, state) {
                    if (state is RecordDetailsLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is RecordDetailsLoaded) {
                      return RecordDetailsDialog(
                        recordDetail: state.recordDetail,
                        isFromDoctorPage: widget.isFromDoctorPage,
                        onPrescriptionCreated: widget.onPrescriptionCreated,
                        onRecordUpdated: () {
                          widget.onRecordUpdated?.call();
                        },
                      );
                    } else if (state is RecordsError) {
                      return Center(
                        child: Text(
                          'Error loading details: ${state.message}',
                          style: const TextStyle(color: AppPallete.errorColor),
                        ),
                      );
                    }
                    return const Center(child: Text('Loading...'));
                  },
                );
              },
            ),
          ),
        ),
      ),
    ).then((_) {
      if (_storedRecordsState != null && mounted) {
        recordsCubit.restoreRecordsState(_storedRecordsState!);
      }
    });
  }
}
