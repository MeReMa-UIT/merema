import 'package:flutter/material.dart';
import 'package:merema/core/theme/app_pallete.dart';
import 'package:merema/features/attachments/domain/entities/attachment.dart';

class AttachmentItemWidget extends StatelessWidget {
  final Attachment attachment;
  final VoidCallback? onView;
  final VoidCallback? onDelete;
  final VoidCallback? onOpenFolder;

  const AttachmentItemWidget({
    super.key,
    required this.attachment,
    this.onView,
    this.onDelete,
    this.onOpenFolder,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                _buildFileIcon(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        attachment.fileName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AppPallete.textColor,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        attachment.type.displayName,
                        style: const TextStyle(
                          color: AppPallete.darkGrayColor,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            _formatFileSize(attachment.sizeInBytes),
                            style: const TextStyle(
                              color: AppPallete.lightGrayColor,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            '•',
                            style: TextStyle(
                              color: AppPallete.lightGrayColor,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatDate(attachment.dateModified),
                            style: const TextStyle(
                              color: AppPallete.lightGrayColor,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (onView != null) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onView,
                      icon: const Icon(Icons.visibility, size: 16),
                      label: const Text('View'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppPallete.primaryColor,
                        foregroundColor: AppPallete.backgroundColor,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (onOpenFolder != null) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onOpenFolder,
                      icon: const Icon(Icons.folder_open, size: 16),
                      label: const Text('Folder'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: AppPallete.backgroundColor,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (onDelete != null) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete, size: 16),
                      label: const Text('Delete'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppPallete.errorColor,
                        foregroundColor: AppPallete.backgroundColor,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileIcon() {
    IconData iconData;
    Color iconColor;

    switch (attachment.type) {
      case AttachmentType.xray:
        iconData = Icons.medical_services;
        iconColor = AppPallete.primaryColor;
        break;
      case AttachmentType.ct:
        iconData = Icons.scanner;
        iconColor = Colors.blue;
        break;
      case AttachmentType.ultrasound:
        iconData = Icons.monitor_heart;
        iconColor = Colors.green;
        break;
      case AttachmentType.test:
        iconData = Icons.science;
        iconColor = Colors.orange;
        break;
      case AttachmentType.other:
        iconData = Icons.insert_drive_file;
        iconColor = AppPallete.darkGrayColor;
        break;
    }

    return CircleAvatar(
      backgroundColor: iconColor.withOpacity(0.1),
      child: Icon(
        iconData,
        color: iconColor,
        size: 20,
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
