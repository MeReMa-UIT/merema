import 'package:dartz/dartz.dart';
import 'package:merema/core/network/dio_client.dart';
import 'package:merema/core/utils/error_handler.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/features/staffs/data/models/staff_infos_model.dart';

abstract class StaffApiService {
  Future<Either<ApiError, StaffsInfosModel>> fetchStaffsList(String token);
  Future<Either<ApiError, StaffInfosModel>> fetchStaffInfos(
      int staffId, String token);
  Future<Either<ApiError, dynamic>> registerStaff(
      Map<String, dynamic> data, String token);
  Future<Either<ApiError, dynamic>> updateStaffInfos(
      Map<String, dynamic> data, int staffId, String token);
}

class StaffApiServiceImpl implements StaffApiService {
  @override
  Future<Either<ApiError, StaffsInfosModel>> fetchStaffsList(
      String token) async {
    try {
      final response = await sl<DioClient>().get(
        '/staffs',
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final staffInfosModel = StaffsInfosModel.fromJson(response.data);

      return Right(staffInfosModel);
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }

  @override
  Future<Either<ApiError, StaffInfosModel>> fetchStaffInfos(
      int staffId, String token) async {
    try {
      final response = await sl<DioClient>().get(
        '/staffs/$staffId',
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final staffInfosModel = StaffInfosModel.fromJson(response.data);

      return Right(staffInfosModel);
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }

  @override
  Future<Either<ApiError, dynamic>> registerStaff(
      Map<String, dynamic> data, String token) async {
    try {
      final response = await sl<DioClient>().post(
        '/accounts/register/staffs',
        data: data,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      return Right(response.data);
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }

  @override
  Future<Either<ApiError, dynamic>> updateStaffInfos(
      Map<String, dynamic> data, int staffId, String token) async {
    try {
      final response = await sl<DioClient>().put(
        '/staffs/$staffId',
        data: data,
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
