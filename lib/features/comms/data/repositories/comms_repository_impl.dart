import 'package:dartz/dartz.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/core/utils/error_handler.dart';
import 'package:merema/features/comms/data/sources/comms_api_service.dart';
import 'package:merema/features/comms/data/sources/comms_local_service.dart';
import 'package:merema/features/comms/domain/entities/contacts.dart';
import 'package:merema/features/comms/domain/entities/messages.dart';
import 'package:merema/features/comms/domain/repositories/comms_repository.dart';

class CommsRepositoryImpl extends CommsRepository {
  @override
  Future<Either<Error, Contacts>> getContacts(String token) async {
    try {
      final result = await sl<CommsApiService>().fetchContacts(token);

      return result.fold(
        (error) async {
          final cachedContacts =
              await sl<CommsLocalService>().getCachedContacts();
          if (cachedContacts != null) {
            return Right(cachedContacts);
          } else {
            return Left(error);
          }
        },
        (contacts) async {
          await sl<CommsLocalService>().cacheContacts(contacts);
          return Right(contacts);
        },
      );
    } catch (e) {
      try {
        final cachedContacts =
            await sl<CommsLocalService>().getCachedContacts();
        if (cachedContacts != null) {
          return Right(cachedContacts);
        }
      } catch (_) {}
      return Left(ApiErrorHandler.handleError(e));
    }
  }

  @override
  Future<Either<Error, Messages>> getMessages(
      int contactId, String token) async {
    try {
      final result =
          await sl<CommsApiService>().fetchMessages(contactId, token);

      return result.fold(
        (error) async {
          final cachedMessages =
              await sl<CommsLocalService>().getCachedMessages(contactId);
          if (cachedMessages != null) {
            return Right(cachedMessages);
          } else {
            return Left(error);
          }
        },
        (messages) async {
          await sl<CommsLocalService>().cacheMessages(contactId, messages);
          return Right(messages);
        },
      );
    } catch (e) {
      try {
        final cachedMessages =
            await sl<CommsLocalService>().getCachedMessages(contactId);
        if (cachedMessages != null) {
          return Right(cachedMessages);
        }
      } catch (_) {}
      return Left(ApiErrorHandler.handleError(e));
    }
  }

  @override
  Future<Either<Error, dynamic>> sendMessage(
    String content,
    int receiverId,
    String token,
  ) async {
    try {
      final result = await sl<CommsApiService>().sendMessage(
        content,
        receiverId,
        token,
      );

      return result.fold(
        (error) => Left(error),
        (response) => Right(response),
      );
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }
}
