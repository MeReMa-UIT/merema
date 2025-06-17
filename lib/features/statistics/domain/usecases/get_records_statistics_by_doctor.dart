import 'package:dartz/dartz.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/core/usecases/usecase.dart';
import 'package:merema/features/auth/domain/repositories/auth_repository.dart';
import 'package:merema/features/statistics/domain/entities/statistic_request.dart';
import 'package:merema/features/statistics/domain/repositories/statistic_repository.dart';

class GetRecordsStatisticsByDoctorUseCase
    implements UseCase<Either, StatisticRequest> {
  final AuthRepository authRepository;

  GetRecordsStatisticsByDoctorUseCase({required this.authRepository});

  @override
  Future<Either> call(StatisticRequest request) async {
    final token = await authRepository.getToken();

    if (token.isEmpty) {
      return Left(Error());
    }

    return await sl<StatisticRepository>()
        .getRecordsStatisticsByDoctor(request, token);
  }
}
