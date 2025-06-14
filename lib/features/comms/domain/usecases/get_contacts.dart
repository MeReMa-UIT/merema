import 'package:merema/core/usecases/usecase.dart';
import 'package:merema/features/comms/domain/repositories/comms_repository.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/features/comms/domain/entities/contact.dart';

class GetContactsUseCase implements UseCase<List<Contact>, dynamic> {
  @override
  Future<List<Contact>> call(dynamic params) async {
    final rawList = await sl<CommsRepository>().getContacts();
    return rawList.map((e) => Contact.fromMap(e)).toList();
  }
}
