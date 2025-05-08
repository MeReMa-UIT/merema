import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:merema/features/auth/presentation/bloc/button_bloc/button_state.dart';
import 'package:merema/core/usecases/usecase.dart';
import 'package:merema/core/utils/error_handler.dart';

class ButtonStateCubit extends Cubit<ButtonState> {
  ButtonStateCubit() : super(ButtonInitialState());

  Future<void> execute({dynamic params, required UseCase useCase}) async {
    emit(ButtonLoadingState());
    try {
      Either result = await useCase.call(params);

      result.fold(
        (failure) {
          emit(ButtonErrorState(failure));
        },
        (data) {
          emit(ButtonSuccessState(data));
        },
      );
    } catch (e) {
      emit(ButtonErrorState(ApiErrorHandler.handleError(e)));
    }
  }
}
