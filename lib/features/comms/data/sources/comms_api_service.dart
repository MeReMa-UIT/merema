import 'package:dartz/dartz.dart';
import 'package:merema/core/network/dio_client.dart';
import 'package:merema/core/utils/error_handler.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/features/comms/data/models/contacts_model.dart';
import 'package:merema/features/comms/data/models/messages_model.dart';

abstract class CommsApiService {
  Future<Either<ApiError, ContactsModel>> fetchContacts(String token);
  Future<Either<ApiError, MessagesModel>> fetchMessages(
      int contactId, String token);
  Future<Either<ApiError, dynamic>> sendMessage(
      String content, int receiverId, String token);
}

class CommsApiServiceImpl implements CommsApiService {
  @override
  Future<Either<ApiError, ContactsModel>> fetchContacts(String token) async {
    try {
      final response = await sl<DioClient>().get(
        '/comms/contacts',
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final contactsModel = ContactsModel.fromJson(response.data);

      return Right(contactsModel);
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }

  @override
  Future<Either<ApiError, MessagesModel>> fetchMessages(
      int contactId, String token) async {
    try {
      final response = await sl<DioClient>().get(
        '/comms/messages/$contactId',
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final messagesModel = MessagesModel.fromJson(response.data);

      return Right(messagesModel);
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }

  @override
  Future<Either<ApiError, dynamic>> sendMessage(
      String content, int receiverId, String token) async {
    try {
      final response = await sl<DioClient>().post(
        '/comms/messages',
        data: {
          'content': content,
          'to_acc_id': receiverId,
        },
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      return Right(response.data);
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }
}
