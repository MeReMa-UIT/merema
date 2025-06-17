import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/features/attachments/domain/usecases/get_attachments.dart';
import 'package:merema/features/attachments/domain/usecases/upload_attachments.dart';
import 'package:merema/features/attachments/domain/usecases/delete_attachments.dart';
import 'package:merema/features/attachments/domain/entities/attachment.dart';
import 'package:merema/features/attachments/presentation/bloc/attachments_state.dart';

class AttachmentsCubit extends Cubit<AttachmentsState> {
  AttachmentsCubit() : super(AttachmentsInitial());

  Future<void> loadAttachments(int recordId) async {
    emit(AttachmentsLoading());

    try {
      final useCase = sl<GetAttachmentsUseCase>();
      final result = await useCase.call(recordId);

      result.fold(
        (error) => emit(AttachmentsError(error.toString())),
        (attachments) {
          final groupedAttachments = _groupAttachmentsByType(attachments);
          emit(AttachmentsLoaded(
            attachments: attachments,
            groupedAttachments: groupedAttachments,
          ));
        },
      );
    } catch (e) {
      emit(AttachmentsError('Failed to load attachments: $e'));
    }
  }

  Future<void> uploadAttachments(int recordId, File file) async {
    emit(AttachmentsUploading());

    try {
      final useCase = sl<UploadAttachmentsUseCase>();
      final result = await useCase.call((recordId, file));

      result.fold(
        (error) => emit(AttachmentsError(error.toString())),
        (_) {
          emit(AttachmentsUploadSuccess());
          loadAttachments(recordId);
        },
      );
    } catch (e) {
      emit(AttachmentsError('Failed to upload attachments: $e'));
    }
  }

  Future<void> deleteAttachmentFile(int recordId, String fileName) async {
    emit(AttachmentsDeleting());

    try {
      final useCase = sl<DeleteAttachmentsUseCase>();
      final result = await useCase.call((recordId, fileName));

      result.fold(
        (error) => emit(AttachmentsError(error.toString())),
        (_) {
          emit(AttachmentsDeleteSuccess());
          loadAttachments(recordId);
        },
      );
    } catch (e) {
      emit(AttachmentsError('Failed to delete attachment: $e'));
    }
  }

  Map<AttachmentType, List<Attachment>> _groupAttachmentsByType(
    List<Attachment> attachments,
  ) {
    final Map<AttachmentType, List<Attachment>> grouped = {};

    for (final attachment in attachments) {
      if (!grouped.containsKey(attachment.type)) {
        grouped[attachment.type] = [];
      }
      grouped[attachment.type]!.add(attachment);
    }

    return grouped;
  }
}
