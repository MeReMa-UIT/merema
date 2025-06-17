import 'package:merema/features/attachments/domain/entities/attachment.dart';

abstract class AttachmentsState {}

class AttachmentsInitial extends AttachmentsState {}

class AttachmentsLoading extends AttachmentsState {}

class AttachmentsLoaded extends AttachmentsState {
  final List<Attachment> attachments;
  final Map<AttachmentType, List<Attachment>> groupedAttachments;

  AttachmentsLoaded({
    required this.attachments,
    required this.groupedAttachments,
  });
}

class AttachmentsError extends AttachmentsState {
  final String message;

  AttachmentsError(this.message);
}

class AttachmentsUploading extends AttachmentsState {}

class AttachmentsUploadSuccess extends AttachmentsState {}

class AttachmentsDeleting extends AttachmentsState {}

class AttachmentsDeleteSuccess extends AttachmentsState {}
