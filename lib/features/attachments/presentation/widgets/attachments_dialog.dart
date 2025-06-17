import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:merema/core/theme/app_pallete.dart';
import 'package:merema/features/attachments/presentation/bloc/attachments_state_cubit.dart';
import 'package:merema/features/attachments/presentation/bloc/attachments_state.dart';
import 'package:merema/features/attachments/presentation/widgets/attachments_list_widget.dart';

class AttachmentsDialog extends StatefulWidget {
  final int recordId;
  final bool isFromDoctorPage;

  const AttachmentsDialog({
    super.key,
    required this.recordId,
    this.isFromDoctorPage = false,
  });

  @override
  State<AttachmentsDialog> createState() => _AttachmentsDialogState();
}

class _AttachmentsDialogState extends State<AttachmentsDialog> {
  late AttachmentsCubit _attachmentsCubit;

  @override
  void initState() {
    super.initState();
    _attachmentsCubit = AttachmentsCubit();
    _attachmentsCubit.loadAttachments(widget.recordId);
  }

  @override
  void dispose() {
    _attachmentsCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppPallete.backgroundColor,
      child: Container(
        width: 800,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            Expanded(
              child: BlocProvider.value(
                value: _attachmentsCubit,
                child: BlocListener<AttachmentsCubit, AttachmentsState>(
                  listener: (context, state) {
                    if (state is AttachmentsUploadSuccess) {
                      _showSuccessSnackBar('Attachments uploaded successfully');
                    } else if (state is AttachmentsDeleteSuccess) {
                      _showSuccessSnackBar('Attachments deleted successfully');
                    } else if (state is AttachmentsError) {
                      _showErrorSnackBar(state.message);
                    }
                  },
                  child: AttachmentsListWidget(
                    recordId: widget.recordId,
                    showUploadButton: widget.isFromDoctorPage,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Medical Record Attachments',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppPallete.textColor,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close, color: AppPallete.textColor),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (widget.isFromDoctorPage) ...[
          ElevatedButton.icon(
            onPressed: _handleUpload,
            icon: const Icon(Icons.upload),
            label: const Text('Upload Files'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppPallete.primaryColor,
              foregroundColor: AppPallete.backgroundColor,
            ),
          ),
          const SizedBox(width: 8),
        ],
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Close',
            style: TextStyle(color: AppPallete.darkGrayColor),
          ),
        ),
      ],
    );
  }

  Future<void> _handleUpload() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.first.path!);
        _attachmentsCubit.uploadAttachments(widget.recordId, file);
      }
    } catch (e) {
      _showErrorSnackBar('Error selecting file: $e');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}
