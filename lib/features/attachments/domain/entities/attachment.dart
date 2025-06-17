import 'package:equatable/equatable.dart';

class Attachment extends Equatable {
  final String fileName;
  final String filePath;
  final AttachmentType type;
  final int sizeInBytes;
  final DateTime dateModified;

  const Attachment({
    required this.fileName,
    required this.filePath,
    required this.type,
    required this.sizeInBytes,
    required this.dateModified,
  });

  @override
  List<Object?> get props => [
        fileName,
        filePath,
        type,
        sizeInBytes,
        dateModified,
      ];
}

enum AttachmentType {
  xray,
  ct,
  ultrasound,
  test,
  other,
}

extension AttachmentTypeExtension on AttachmentType {
  String get displayName {
    switch (this) {
      case AttachmentType.xray:
        return 'X-Ray';
      case AttachmentType.ct:
        return 'CT Scan';
      case AttachmentType.ultrasound:
        return 'Ultrasound';
      case AttachmentType.test:
        return 'Test Results';
      case AttachmentType.other:
        return 'Other';
    }
  }

  String get folderName {
    switch (this) {
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

  static AttachmentType fromFolderName(String folderName) {
    switch (folderName.toLowerCase()) {
      case 'xray':
        return AttachmentType.xray;
      case 'ct':
        return AttachmentType.ct;
      case 'ultrasound':
        return AttachmentType.ultrasound;
      case 'test':
        return AttachmentType.test;
      case 'other':
      default:
        return AttachmentType.other;
    }
  }
}
