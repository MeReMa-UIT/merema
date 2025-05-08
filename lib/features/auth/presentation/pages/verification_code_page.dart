import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:merema/core/utils/service_locator.dart';
import 'package:merema/features/auth/domain/usecases/recovery.dart';
import 'package:merema/features/auth/presentation/bloc/button_bloc/button_state.dart';
import 'package:merema/features/auth/presentation/bloc/button_bloc/button_state_cubit.dart';
import 'package:merema/features/auth/presentation/pages/reset_password_page.dart';
import 'package:merema/features/auth/presentation/widgets/auth_button.dart';
import 'package:merema/features/auth/presentation/widgets/auth_field.dart';
import 'package:merema/features/auth/presentation/widgets/auth_layout.dart';
import 'package:merema/features/auth/data/models/auth_req_params.dart';

class VerificationCodePage extends StatefulWidget {
  static route({required String citizenId, required String email}) =>
      MaterialPageRoute(
        builder: (context) =>
            VerificationCodePage(citizenId: citizenId, email: email),
      );

  final String citizenId;
  final String email;

  const VerificationCodePage({
    super.key,
    required this.citizenId,
    required this.email,
  });

  @override
  State<VerificationCodePage> createState() => _VerificationCodePageState();
}

class _VerificationCodePageState extends State<VerificationCodePage> {
  final _verificationCodeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isResendDisabled = false;
  int _countdownSeconds = 30;
  late final ButtonStateCubit _resendCubit;
  late final ButtonStateCubit _verifyCubit;

  @override
  void initState() {
    super.initState();
    _resendCubit = ButtonStateCubit();
    _verifyCubit = ButtonStateCubit();
  }

  @override
  void dispose() {
    _verificationCodeController.dispose();
    _resendCubit.close();
    _verifyCubit.close();
    super.dispose();
  }

  void _onNextPressed(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      _verifyCubit.execute(
        useCase: sl<RecoveryConfirmUseCase>(),
        params: RecoveryConfirmReqParams(
          citizenId: widget.citizenId,
          otp: _verificationCodeController.text,
        ),
      );
    }
  }

  void _resendCode(BuildContext context) {
    _resendCubit.execute(
      useCase: sl<RecoveryUseCase>(),
      params: RecoveryReqParams(
        citizenId: widget.citizenId,
        email: widget.email,
      ),
    );
    _startResendCountdown();
  }

  void _startResendCountdown() {
    setState(() {
      _isResendDisabled = true;
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _countdownSeconds -= 1;
        });

        if (_countdownSeconds > 0) {
          _startResendCountdown();
        } else {
          setState(() {
            _isResendDisabled = false;
            _countdownSeconds = 30;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _verifyCubit),
        BlocProvider.value(value: _resendCubit),
      ],
      child: Builder(
        builder: (context) {
          return BlocListener<ButtonStateCubit, ButtonState>(
            bloc: _resendCubit,
            listener: (context, state) {
              if (state is ButtonErrorState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.failure.message)),
                );
              } else if (state is ButtonSuccessState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mã xác minh đã được gửi lại')),
                );
              }
            },
            child: BlocConsumer<ButtonStateCubit, ButtonState>(
              bloc: _verifyCubit,
              listener: (context, state) {
                if (state is ButtonErrorState) {
                  if (state.failure.statusCode == 401) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Mã xác minh không chính xác')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.failure.message)),
                    );
                  }
                } else if (state is ButtonSuccessState) {
                  Navigator.push(
                    context,
                    ResetPasswordPage.route(
                        token: state.data, email: widget.email),
                  );
                }
              },
              builder: (context, state) {
                final resendState = _resendCubit.state;

                return Scaffold(
                  body: Form(
                    key: _formKey,
                    child: AuthLayout(
                      showBackButton: true,
                      children: [
                        const Text(
                          'Nhập mã xác minh',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 25),
                        Text(
                          'Mã xác minh đã được gửi đến email ${widget.email}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: AuthField(
                                hintText: 'Mã xác minh',
                                controller: _verificationCodeController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Vui lòng nhập mã xác minh';
                                  }
                                  if (value.length != 6 ||
                                      !RegExp(r'^\d+$').hasMatch(value)) {
                                    return 'Mã xác minh phải có 6 số';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              height: 65,
                              child: AuthButton(
                                onPressed: _isResendDisabled
                                    ? null
                                    : () => _resendCode(context),
                                text: _isResendDisabled
                                    ? 'Gửi lại ($_countdownSeconds)'
                                    : 'Gửi lại',
                                width: 115,
                                showShadow: false,
                                isLoading: !_isResendDisabled &&
                                    resendState is ButtonLoadingState,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),
                        AuthButton(
                          text: 'Tiếp theo',
                          onPressed: () => _onNextPressed(context),
                          isLoading: state is ButtonLoadingState,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
