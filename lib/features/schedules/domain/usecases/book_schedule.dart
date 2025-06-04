import 'package:dartz/dartz.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/core/usecases/usecase.dart';
import 'package:merema/features/auth/domain/repositories/auth_repository.dart';
import 'package:merema/features/schedules/domain/repositories/schedule_repository.dart';

class BookScheduleUseCase implements UseCase<Either, (String, int)> {
  final AuthRepository authRepository;

  BookScheduleUseCase({required this.authRepository});

  @override
  Future<Either> call((String, int) params) async {
    final token = await authRepository.getToken();

    if (token.isEmpty) {
      return Left(Error());
    }

    return await sl<ScheduleRepository>().bookSchedule(
      token,
      examinationDate: params.$1,
      type: params.$2,
    );
  }
}
