import 'package:dartz/dartz.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/core/usecases/usecase.dart';
import 'package:merema/features/auth/domain/repositories/auth_repository.dart';
import 'package:merema/features/staffs/domain/repositories/staff_repository.dart';

class GetStaffsListUseCase implements UseCase<Either, dynamic> {
  final AuthRepository authRepository;

  GetStaffsListUseCase({required this.authRepository});

  @override
  Future<Either> call(dynamic params) async {
    final token = await authRepository.getToken();

    if (token.isEmpty) {
      return Left(Error());
    }

    return await sl<StaffRepository>().getStaffsList(token);
  }
}
