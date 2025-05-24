import 'package:merema/core/utils/error_handler.dart';

abstract class ButtonState {}

class ButtonInitialState extends ButtonState {}

class ButtonLoadingState extends ButtonState {}

class ButtonWaitingState extends ButtonState {}

class ButtonSuccessState extends ButtonState {
  final dynamic data;
  ButtonSuccessState(this.data);
}

class ButtonErrorState extends ButtonState {
  final ApiError failure;
  ButtonErrorState(this.failure);
}
