import 'package:dartz/dartz.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/core/usecases/usecase.dart';
import 'package:merema/features/auth/domain/repositories/auth_repository.dart';
import 'package:merema/features/staffs/data/models/staff_req_params.dart';
import 'package:merema/features/staffs/domain/repositories/staff_repository.dart';

class UpdateStaffUseCase
    implements UseCase<Either, Tuple2<StaffReqParams, int>> {
  final AuthRepository authRepository;

  UpdateStaffUseCase({required this.authRepository});

  @override
  Future<Either> call(Tuple2<StaffReqParams, int> params) async {
    final token = await authRepository.getToken();
    if (token.isEmpty) {
      return Left(Error());
    }
    final staffParams = params.value1;
    final staffId = params.value2;
    return await sl<StaffRepository>().updateStaff(staffParams, staffId, token);
  }
}
