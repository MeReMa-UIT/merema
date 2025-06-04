import 'package:dartz/dartz.dart';
import 'package:merema/features/staffs/domain/entities/staff_infos.dart';
import 'package:merema/core/layers/data/model/account_req_params.dart';
import 'package:merema/features/staffs/data/models/staff_req_params.dart';

abstract class StaffRepository {
  Future<Either<Error, StaffsInfos>> getStaffsList(String token);
  Future<Either<Error, StaffInfos>> getStaffInfos(int staffId, String token);
  Future<Either<Error, dynamic>> registerStaff(
    AccountReqParams accountParams,
    StaffReqParams staffParams,
    String token,
  );
  Future<Either<Error, dynamic>> updateStaff(
    StaffReqParams staffParams,
    int staffId,
    String token,
  );
}
