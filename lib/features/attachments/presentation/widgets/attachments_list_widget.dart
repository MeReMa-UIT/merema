import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:merema/core/theme/app_pallete.dart';
import 'package:merema/core/layers/presentation/widgets/custom_dropdown.dart';
import 'package:merema/features/attachments/domain/entities/attachment.dart';
import 'package:merema/features/attachments/presentation/bloc/attachments_state_cubit.dart';
import 'package:merema/features/attachments/presentation/bloc/attachments_state.dart';
import 'package:merema/features/attachments/presentation/widgets/attachment_item_widget.dart';
import 'package:merema/features/attachments/presentation/widgets/image_viewer_dialog.dart';

class AttachmentsListWidget extends StatelessWidget {
  final int recordId;
  final bool showUploadButton;

  const AttachmentsListWidget({
    super.key,
    required this.recordId,
    this.showUploadButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AttachmentsCubit, AttachmentsState>(
      builder: (context, state) {
        if (state is AttachmentsLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppPallete.primaryColor,
            ),
          );
        }

        if (state is AttachmentsError) {
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
                const Text(
                  'Error loading attachments',
                  style: TextStyle(
                    color: AppPallete.darkGrayColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  style: const TextStyle(
                    color: AppPallete.lightGrayColor,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<AttachmentsCubit>().loadAttachments(recordId);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppPallete.primaryColor,
                    foregroundColor: AppPallete.backgroundColor,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is AttachmentsLoaded) {
          if (state.attachments.isEmpty) {
            return _buildEmptyState(context);
          }

          return Column(
            children: [
              if (showUploadButton) _buildUploadSection(context),
              Expanded(
                child: _buildAttachmentsList(context, state),
              ),
            ],
          );
        }

        return _buildEmptyState(context);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.attachment_outlined,
            size: 64,
            color: AppPallete.lightGrayColor,
          ),
          const SizedBox(height: 16),
          const Text(
            'No attachments found',
            style: TextStyle(
              color: AppPallete.darkGrayColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Medical record attachments will appear here\nwhen they are uploaded',
            style: TextStyle(
              color: AppPallete.lightGrayColor,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          if (showUploadButton) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _handleAddAttachment(context),
              icon: const Icon(Icons.upload),
              label: const Text('Upload Attachments'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppPallete.primaryColor,
                foregroundColor: AppPallete.backgroundColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUploadSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Manage Attachments',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppPallete.textColor,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Upload medical documents, X-rays, test results, etc.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppPallete.darkGrayColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: () => _handleAddAttachment(context),
            icon: const Icon(Icons.upload, size: 16),
            label: const Text('Upload'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppPallete.primaryColor,
              foregroundColor: AppPallete.backgroundColor,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentsList(BuildContext context, AttachmentsLoaded state) {
    return ListView(
      children: [
        ...AttachmentType.values.map((type) {
          final attachments = state.groupedAttachments[type] ?? [];
          if (attachments.isEmpty) return const SizedBox.shrink();

          return _buildTypeSection(context, type, attachments);
        }),
      ],
    );
  }

  Widget _buildTypeSection(
    BuildContext context,
    AttachmentType type,
    List<Attachment> attachments,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Icon(
                _getTypeIcon(type),
                size: 20,
                color: _getTypeColor(type),
              ),
              const SizedBox(width: 8),
              Text(
                type.displayName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppPallete.textColor,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getTypeColor(type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${attachments.length}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _getTypeColor(type),
                  ),
                ),
              ),
            ],
          ),
        ),
        ...attachments.map((attachment) => AttachmentItemWidget(
              attachment: attachment,
              onView: () => _viewAttachment(context, attachment),
              onDelete: () => _deleteAttachment(context, attachment),
              onOpenFolder: () => _openAttachmentFolder(context, attachment),
            )),
        const SizedBox(height: 8),
      ],
    );
  }

  IconData _getTypeIcon(AttachmentType type) {
    switch (type) {
      case AttachmentType.xray:
        return Icons.medical_services;
      case AttachmentType.ct:
        return Icons.scanner;
      case AttachmentType.ultrasound:
        return Icons.monitor_heart;
      case AttachmentType.test:
        return Icons.science;
      case AttachmentType.other:
        return Icons.insert_drive_file;
    }
  }

  Color _getTypeColor(AttachmentType type) {
    switch (type) {
      case AttachmentType.xray:
        return AppPallete.primaryColor;
      case AttachmentType.ct:
        return Colors.blue;
      case AttachmentType.ultrasound:
        return Colors.green;
      case AttachmentType.test:
        return Colors.orange;
      case AttachmentType.other:
        return AppPallete.darkGrayColor;
    }
  }

  void _viewAttachment(BuildContext context, Attachment attachment) async {
    try {
      final attachmentPath = attachment.filePath;
      final file = File(attachmentPath);

      if (!await file.exists()) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('File not found'),
              backgroundColor: AppPallete.errorColor,
            ),
          );
        }
        return;
      }

      final extension = attachment.fileName.toLowerCase().split('.').last;
      final imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];

      if (imageExtensions.contains(extension)) {
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (context) => ImageViewerDialog(
              imagePath: attachmentPath,
              fileName: attachment.fileName,
            ),
          );
        }
      } else {
        final result = await OpenFile.open(attachmentPath);
        if (context.mounted) {
          if (result.type != ResultType.done) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Cannot open file: ${result.message}'),
                backgroundColor: AppPallete.errorColor,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening file: $e'),
            backgroundColor: AppPallete.errorColor,
          ),
        );
      }
    }
  }

  void _deleteAttachment(BuildContext context, Attachment attachment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppPallete.backgroundColor,
        title: const Text(
          'Delete Attachment',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppPallete.textColor,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${attachment.fileName}"?\n\nThis action cannot be undone.',
          style: const TextStyle(color: AppPallete.textColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppPallete.darkGrayColor),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppPallete.errorColor,
              foregroundColor: AppPallete.backgroundColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await context.read<AttachmentsCubit>().deleteAttachmentFile(
              recordId,
              attachment.fileName,
            );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Attachment deleted successfully'),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting attachment: $e'),
            ),
          );
        }
      }
    }
  }

  void _openAttachmentFolder(
      BuildContext context, Attachment attachment) async {
    try {
      final file = File(attachment.filePath);
      final directory = file.parent;

      if (!await directory.exists()) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Folder not found'),
              backgroundColor: AppPallete.errorColor,
            ),
          );
        }
        return;
      }

      final uri = Uri.file(directory.path);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (Platform.isLinux) {
          await OpenFile.open(directory.path);
        } else if (Platform.isWindows) {
          await OpenFile.open(directory.path);
        } else if (Platform.isMacOS) {
          await OpenFile.open(directory.path);
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Cannot open folder on this platform'),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening folder: $e'),
          ),
        );
      }
    }
  }

  Future<void> _handleAddAttachment(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
        dialogTitle: 'Select medical attachments',
      );

      if (result != null && result.files.isNotEmpty && context.mounted) {
        final selectedType = await _showTypeSelectionDialog(context);

        if (selectedType == null) return;

        if (!context.mounted) return;

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: AppPallete.backgroundColor,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: AppPallete.primaryColor),
                const SizedBox(height: 16),
                Text(
                  'Uploading ${result.files.length} file(s)...',
                  style: const TextStyle(color: AppPallete.textColor),
                ),
              ],
            ),
          ),
        );

        try {
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          int successCount = 0;
          final cubit = context.read<AttachmentsCubit>();

          for (int i = 0; i < result.files.length; i++) {
            final originalFile = File(result.files[i].path!);
            final originalName = result.files[i].name;
            final extension = originalName.split('.').last;

            final typePrefix = _getTypePrefix(selectedType);
            final newFileName =
                '${typePrefix}_${timestamp}_${i + 1}.$extension';

            try {
              final tempDir =
                  await Directory.systemTemp.createTemp('attachments_');
              final renamedFile = File('${tempDir.path}/$newFileName');

              await originalFile.copy(renamedFile.path);

              await cubit.uploadAttachments(recordId, renamedFile);

              await renamedFile.delete();
              await tempDir.delete();

              successCount++;
            } catch (e) {
              debugPrint('Failed to upload file $originalName: $e');
            }
          }

          if (context.mounted) {
            Navigator.of(context).pop();

            if (successCount == result.files.length) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'All $successCount attachment(s) uploaded successfully as ${selectedType.displayName}'),
                ),
              );
            } else if (successCount > 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      '$successCount of ${result.files.length} attachment(s) uploaded successfully'),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Failed to upload attachments'),
                ),
              );
            }
          }
        } catch (e) {
          if (context.mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Upload failed: $e'),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting files: $e'),
          ),
        );
      }
    }
  }

  Future<AttachmentType?> _showTypeSelectionDialog(BuildContext context) async {
    AttachmentType? selectedType;

    return await showDialog<AttachmentType>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppPallete.backgroundColor,
        title: const Row(
          children: [
            Icon(Icons.category, color: AppPallete.primaryColor),
            SizedBox(width: 8),
            Text(
              'Select Attachment Type',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppPallete.textColor,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose the type for all selected attachments:',
              style: TextStyle(
                color: AppPallete.darkGrayColor,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            CustomDropdown<AttachmentType>(
              selectedValue: selectedType,
              availableItems: AttachmentType.values,
              onChanged: (type) {
                selectedType = type;
              },
              labelText: 'Select attachment type',
              getDisplayText: (type) => type.displayName,
              width: double.infinity,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(null),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppPallete.darkGrayColor),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(selectedType),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppPallete.primaryColor,
              foregroundColor: AppPallete.backgroundColor,
            ),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  String _getTypePrefix(AttachmentType type) {
    switch (type) {
      case AttachmentType.xray:
        return 'xray';
      case AttachmentType.ct:
        return 'ct';
      case AttachmentType.ultrasound:
        return 'ultrasound';
      case AttachmentType.test:
        return 'test';
      case AttachmentType.other:
        return 'other';
    }
  }
}
