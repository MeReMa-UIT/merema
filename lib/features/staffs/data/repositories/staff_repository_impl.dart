import 'package:dartz/dartz.dart';
import 'package:merema/core/layers/data/sources/register_api_service.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/core/utils/error_handler.dart';
import 'package:merema/features/staffs/data/sources/staff_api_service.dart';
import 'package:merema/features/staffs/domain/entities/staff_infos.dart';
import 'package:merema/features/staffs/domain/repositories/staff_repository.dart';
import 'package:merema/core/layers/data/model/account_req_params.dart';
import 'package:merema/features/staffs/data/models/staff_req_params.dart';

class StaffRepositoryImpl extends StaffRepository {
  @override
  Future<Either<Error, StaffsInfos>> getStaffsList(String token) async {
    try {
      final result = await sl<StaffApiService>().fetchStaffsList(token);

      return result.fold(
        (error) => Left(error),
        (staffsList) => Right(staffsList),
      );
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }

  @override
  Future<Either<Error, StaffInfos>> getStaffInfos(
      int staffId, String token) async {
    try {
      final result =
          await sl<StaffApiService>().fetchStaffInfos(staffId, token);

      return result.fold(
        (error) => Left(error),
        (staffInfo) => Right(staffInfo),
      );
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }

  @override
  Future<Either<Error, dynamic>> registerStaff(
    AccountReqParams accountParams,
    StaffReqParams staffParams,
    String token,
  ) async {
    try {
      final regAccResult = await sl<RegisterApiService>().registerAccount({
        'citizen_id': accountParams.citizenId,
      }, token);
      if (regAccResult.isLeft()) {
        return Left(regAccResult.fold((l) => l,
            (r) => ApiErrorHandler.handleError('Registration failed')));
      }

      final regAccData = regAccResult.getOrElse(() => {});
      var accId = regAccData['acc_id'];
      var registerToken = regAccData['token'];

      if (accId == -1) {
        final createAccResult = await sl<RegisterApiService>().createAccount(
          accountParams.toJson(),
          registerToken,
        );
        if (createAccResult.isLeft()) {
          return Left(createAccResult.fold((l) => l,
              (r) => ApiErrorHandler.handleError('Account creation failed')));
        }

        final createAccData = createAccResult.getOrElse(() => {});
        accId = createAccData['acc_id'];
        registerToken = createAccData['token'];
      }

      final staffRequest = accId == -1
          ? {...staffParams.toJson()}
          : {'acc_id': accId, ...staffParams.toJson()};
      final regStaffResult = await sl<StaffApiService>().registerStaff(
        staffRequest,
        registerToken,
      );
      if (regStaffResult.isLeft()) {
        return Left(regStaffResult.fold((l) => l,
            (r) => ApiErrorHandler.handleError('Staff registration failed')));
      }

      return Right(regStaffResult.getOrElse(() => {}));
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }

  @override
  Future<Either<Error, dynamic>> updateStaff(
      StaffReqParams staffParams, int staffId, String token) async {
    try {
      final result = await sl<StaffApiService>().updateStaffInfos(
        staffParams.toJson(),
        staffId,
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
