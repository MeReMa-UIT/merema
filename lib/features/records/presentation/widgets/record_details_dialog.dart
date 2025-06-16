import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:merema/core/theme/app_pallete.dart';
import 'package:merema/core/layers/presentation/widgets/json_tree_view.dart';
import 'package:merema/features/records/presentation/bloc/records_state_cubit.dart';
import 'package:merema/features/prescriptions/presentation/widgets/prescription_list_view.dart';
import 'package:merema/features/prescriptions/presentation/bloc/prescriptions_state_cubit.dart';

class RecordDetailsDialog extends StatelessWidget {
  final dynamic recordDetail;
  final bool isFromDoctorPage;

  const RecordDetailsDialog({
    super.key,
    required this.recordDetail,
    this.isFromDoctorPage = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Medical Record #${recordDetail.recordId}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppPallete.textColor,
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
                  child: const TabBar(
                    labelColor: AppPallete.primaryColor,
                    unselectedLabelColor: AppPallete.darkGrayColor,
                    indicatorColor: AppPallete.primaryColor,
                    tabs: [
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
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
                  _buildInfoRow('Record ID', recordDetail.recordId.toString()),
                  _buildInfoRow(
                      'Type',
                      context
                          .read<RecordsCubit>()
                          .getRecordTypeName(recordDetail.typeId)),
                  _buildInfoRow(
                      'Created At', _formatDateTime(recordDetail.createdAt)),
                  if (recordDetail.expiredAt != null)
                    _buildInfoRow(
                        'Expired At', _formatDateTime(recordDetail.expiredAt!)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          JsonTreeView(
            data: recordDetail.recordDetail,
            title: 'Record Details',
          ),
        ],
      ),
    );
  }

  Widget _buildPrescriptionsTab() {
    return BlocProvider(
      create: (context) => PrescriptionsCubit(),
      child: PrescriptionListView(
        recordId: recordDetail.recordId,
        showCreateButton: isFromDoctorPage,
        isFromDoctorPage: isFromDoctorPage,
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
