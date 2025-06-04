import 'package:dartz/dartz.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/core/usecases/usecase.dart';
import 'package:merema/features/auth/domain/repositories/auth_repository.dart';
import 'package:merema/features/schedules/domain/repositories/schedule_repository.dart';

class UpdateScheduleStatusUseCase
    implements UseCase<Either, Tuple3<int, int, String>> {
  final AuthRepository authRepository;

  UpdateScheduleStatusUseCase({
    required this.authRepository,
  });

  @override
  Future<Either> call(Tuple3<int, int, String> params) async {
    final scheduleId = params.value1;
    final newStatus = params.value2;
    final receptionTime = params.value3;

    final token = await authRepository.getToken();
    if (token.isEmpty) {
      return Left(Error());
    }

    return await sl<ScheduleRepository>().updateScheduleStatus(
      token,
      scheduleId: scheduleId,
      newStatus: newStatus,
      receptionTime: receptionTime,
    );
  }
}
