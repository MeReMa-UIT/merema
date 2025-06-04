import 'package:dartz/dartz.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/core/usecases/usecase.dart';
import 'package:merema/features/auth/domain/repositories/auth_repository.dart';
import 'package:merema/core/layers/data/model/account_req_params.dart';
import 'package:merema/features/staffs/data/models/staff_req_params.dart';
import 'package:merema/features/staffs/domain/repositories/staff_repository.dart';

class RegisterStaffUseCase
    implements UseCase<Either, Tuple2<AccountReqParams, StaffReqParams>> {
  final AuthRepository authRepository;

  RegisterStaffUseCase({required this.authRepository});

  @override
  Future<Either> call(Tuple2<AccountReqParams, StaffReqParams> params) async {
    final token = await authRepository.getToken();
    if (token.isEmpty) {
      return Left(Error());
    }
    final accountParams = params.value1;
    final staffParams = params.value2;
    return await sl<StaffRepository>()
        .registerStaff(accountParams, staffParams, token);
  }
}
