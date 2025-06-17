import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:merema/core/theme/app_pallete.dart';
import 'package:merema/core/layers/presentation/widgets/json_tree_view.dart';
import 'package:merema/features/records/presentation/bloc/records_state_cubit.dart';
import 'package:merema/features/records/presentation/bloc/records_state.dart';
import 'package:merema/features/prescriptions/presentation/widgets/prescription_list_view.dart';
import 'package:merema/features/prescriptions/presentation/bloc/prescriptions_state_cubit.dart';
import 'package:merema/features/records/presentation/widgets/record_update_dialog.dart';
import 'package:merema/features/patients/presentation/bloc/patient_infos_state_cubit.dart';
import 'package:merema/core/layers/domain/entities/user_role.dart';

class RecordDetailsDialog extends StatefulWidget {
  final dynamic recordDetail;
  final bool isFromDoctorPage;
  final VoidCallback? onPrescriptionCreated;
  final VoidCallback? onRecordUpdated;

  const RecordDetailsDialog({
    super.key,
    required this.recordDetail,
    this.isFromDoctorPage = false,
    this.onPrescriptionCreated,
    this.onRecordUpdated,
  });

  @override
  State<RecordDetailsDialog> createState() => _RecordDetailsDialogState();
}

class _RecordDetailsDialogState extends State<RecordDetailsDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late PrescriptionsCubit _prescriptionsCubit;
  dynamic _currentRecordDetail;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _prescriptionsCubit = PrescriptionsCubit();
    _currentRecordDetail = widget.recordDetail;
  }

  @override
  void dispose() {
    _tabController.dispose();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!_prescriptionsCubit.isClosed) {
        _prescriptionsCubit.close();
      }
    });
    super.dispose();
  }

  void _switchToPrescriptionsTab() {
    _tabController.animateTo(1);
  }

  void _showRecordUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider(
        create: (_) => PatientInfosCubit(),
        child: Dialog(
          backgroundColor: AppPallete.backgroundColor,
          child: Container(
            width: 600,
            height: MediaQuery.of(context).size.height * 0.8,
            padding: const EdgeInsets.all(16),
            child: RecordUpdateDialog(
              recordDetail: widget.recordDetail,
              userRole: widget.isFromDoctorPage
                  ? UserRole.doctor
                  : UserRole.receptionist,
              onCancel: () => Navigator.of(dialogContext).pop(),
              onSuccess: () async {
                Navigator.of(dialogContext).pop();

                final recordsCubit = context.read<RecordsCubit?>();
                if (recordsCubit != null) {
                  await recordsCubit
                      .getRecordDetails(widget.recordDetail.recordId);
                  final state = recordsCubit.state;
                  if (state is RecordDetailsLoaded && mounted) {
                    setState(() {
                      _currentRecordDetail = state.recordDetail;
                    });
                  }
                }

                if (widget.onRecordUpdated != null && mounted) {
                  widget.onRecordUpdated!();
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Medical Record #${widget.recordDetail.recordId}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppPallete.textColor,
                ),
              ),
            ),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close, color: AppPallete.textColor),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: DefaultTabController(
            length: 3,
            child: Column(
              children: [
                Container(
                  color: AppPallete.backgroundColor,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: AppPallete.primaryColor,
                    unselectedLabelColor: AppPallete.darkGrayColor,
                    indicatorColor: AppPallete.primaryColor,
                    tabs: const [
                      Tab(
                        icon: Icon(Icons.info),
                        text: 'Details',
                      ),
                      Tab(
                        icon: Icon(Icons.medication),
                        text: 'Prescriptions',
                      ),
                      Tab(
                        icon: Icon(Icons.attachment),
                        text: 'Attachments',
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildDetailsTab(context),
                      _buildPrescriptionsTab(),
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
  }

  Widget _buildDetailsTab(BuildContext context) {
    final displayRecordDetail = _currentRecordDetail ?? widget.recordDetail;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.isFromDoctorPage)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.edit, color: AppPallete.primaryColor),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Update this medical record',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppPallete.textColor,
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showRecordUpdateDialog(context),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Update'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppPallete.primaryColor,
                        foregroundColor: AppPallete.backgroundColor,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (widget.isFromDoctorPage) const SizedBox(height: 16),
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
                      'Record ID', displayRecordDetail.recordId.toString()),
                  _buildInfoRow(
                      'Type',
                      context
                          .read<RecordsCubit>()
                          .getRecordTypeName(displayRecordDetail.typeId)),
                  _buildInfoRow('Created At',
                      _formatDateTime(displayRecordDetail.createdAt)),
                  if (displayRecordDetail.expiredAt != null)
                    _buildInfoRow('Expired At',
                        _formatDateTime(displayRecordDetail.expiredAt!)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          JsonTreeView(
            data: displayRecordDetail.recordDetail,
            title: 'Record Details',
          ),
        ],
      ),
    );
  }

  Widget _buildPrescriptionsTab() {
    return BlocProvider.value(
      value: _prescriptionsCubit,
      child: PrescriptionListView(
        recordId: widget.recordDetail.recordId,
        showCreateButton: widget.isFromDoctorPage,
        isFromDoctorPage: widget.isFromDoctorPage,
        prescriptionsCubit: _prescriptionsCubit,
        onPrescriptionCreated: () async {
          _switchToPrescriptionsTab();

          final recordsCubit = context.read<RecordsCubit?>();

          await Future.delayed(const Duration(milliseconds: 100));

          _prescriptionsCubit
              .getPrescriptionsByRecord(widget.recordDetail.recordId);

          if (mounted &&
              recordsCubit != null &&
              widget.recordDetail.patientId != null) {
            recordsCubit.getRecordsByPatient(widget.recordDetail.patientId);
          }
          if (widget.onPrescriptionCreated != null) {
            widget.onPrescriptionCreated!();
          }
        },
        onSwitchToPrescriptionsTab: _switchToPrescriptionsTab,
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
}
