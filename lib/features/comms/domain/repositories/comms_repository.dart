import 'package:dartz/dartz.dart';
import 'package:merema/features/comms/domain/entities/contacts.dart';
import 'package:merema/features/comms/domain/entities/messages.dart';

abstract class CommsRepository {
  Future<Either<Error, Contacts>> getContacts(String token);
  Future<Either<Error, Messages>> getMessages(int contactId, String token);
  Future<Either<Error, dynamic>> sendMessage(
    String content,
    int receiverId,
    String token,
  );
}
