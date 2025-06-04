import 'package:dartz/dartz.dart';
import 'package:merema/core/usecases/usecase.dart';
import 'package:merema/features/auth/domain/repositories/auth_repository.dart';
import 'package:merema/features/staffs/domain/repositories/staff_repository.dart';
import 'package:merema/core/services/service_locator.dart';

class GetStaffInfosUseCase implements UseCase<Either, int> {
  final AuthRepository authRepository;

  GetStaffInfosUseCase({required this.authRepository});

  @override
  Future<Either> call(int staffId) async {
    final token = await authRepository.getToken();

    if (token.isEmpty) {
      return Left(Error());
    }

    return await sl<StaffRepository>().getStaffInfos(staffId, token);
  }
}
