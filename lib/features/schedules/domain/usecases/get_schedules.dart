import 'package:dartz/dartz.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/core/usecases/usecase.dart';
import 'package:merema/features/auth/domain/repositories/auth_repository.dart';
import 'package:merema/features/schedules/domain/repositories/schedule_repository.dart';

class GetSchedulesUseCase
    implements UseCase<Either, (List<int>?, List<int>?)?> {
  final AuthRepository authRepository;

  GetSchedulesUseCase({required this.authRepository});

  @override
  Future<Either> call((List<int>?, List<int>?)? params) async {
    final token = await authRepository.getToken();

    if (token.isEmpty) {
      return Left(Error());
    }

    return await sl<ScheduleRepository>().getSchedules(
      token,
      types: params?.$1,
      statuses: params?.$2,
    );
  }
}
