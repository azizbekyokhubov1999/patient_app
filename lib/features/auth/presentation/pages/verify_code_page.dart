import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../manager/auth_cubit.dart';
import '../manager/auth_state.dart';

class VerifyCodePage extends StatefulWidget {
  const VerifyCodePage({super.key});

  @override
  State<VerifyCodePage> createState() => _VerifyCodePageState();
}

class _VerifyCodePageState extends State<VerifyCodePage> {
  final _controllers = List.generate(4, (_) => TextEditingController());
  String? _submittedCode;

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _handleVerificationError(
    BuildContext context,
    String message,
  ) async {
    final isSessionError = message.contains('No active session');
    final usedMockOtp = _submittedCode == AuthCubit.mockOtpCode;

    if (isSessionError && usedMockOtp) {
      final cubit = context.read<AuthCubit>();
      final recovered = await cubit.tryRecoverVerificationSession();
      if (!context.mounted) return;

      if (recovered) {
        return;
      }

      await FirebaseAuth.instance.currentUser?.reload();
      if (!context.mounted) return;

      if (FirebaseAuth.instance.currentUser != null) {
        cubit.clearCompletedFlow();
        context.go(AppPaths.yourLocation);
        return;
      }
    }

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return BlocConsumer<AuthCubit, AuthState>(
      listenWhen: (previous, current) =>
          (current is Authenticated &&
              current.completedFlow == AuthFlow.verifyCode) ||
          (current is AuthError && current.flow == AuthFlow.verifyCode),
      listener: (context, state) {
        if (state is Authenticated &&
            state.completedFlow == AuthFlow.verifyCode) {
          context.read<AuthCubit>().clearCompletedFlow();
          if (state.isProfileComplete) {
            context.go(AppPaths.home);
          } else {
            context.push(AppPaths.completeProfile);
          }
        } else if (state is AuthError && state.flow == AuthFlow.verifyCode) {
          _handleVerificationError(context, state.message);
        }
      },
      builder: (context, state) {
        final isSubmitting =
            state is AuthLoading && state.flow == AuthFlow.verifyCode;
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: AnimatedPadding(
              duration: const Duration(milliseconds: 180),
              padding: EdgeInsets.only(
                bottom: MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: CustomScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                    sliver: SliverFillRemaining(
                      hasScrollBody: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: InkWell(
                              onTap: () {
                                if (context.canPop()) {
                                  context.pop();
                                } else {
                                  context.go(AppPaths.createAccount);
                                }
                              },
                              borderRadius: BorderRadius.circular(24),
                              child: Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.stroke),
                                ),
                                child: const Icon(
                                  Icons.arrow_back,
                                  color: AppColors.primaryText,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 56),
                          Text(
                            'Verify Code',
                            textAlign: TextAlign.center,
                            style: textTheme.headlineLarge?.copyWith(
                              color: AppColors.primaryText,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Enter the verification code we sent to',
                            textAlign: TextAlign.center,
                            style: textTheme.bodyLarge?.copyWith(
                              color: AppColors.secondaryText,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'example@email.com',
                            textAlign: TextAlign.center,
                            style: textTheme.bodyLarge?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 44),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(4, (index) {
                              return SizedBox(
                                width: 70,
                                child: TextFormField(
                                  controller: _controllers[index],
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: AppColors.primaryText,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLength: 1,
                                  decoration: InputDecoration(
                                    counterText: '',
                                    hintText: '-',
                                    hintStyle: const TextStyle(
                                      color: AppColors.secondaryText,
                                    ),
                                    filled: true,
                                    fillColor: AppColors.stroke,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(
                                        color: AppColors.primary,
                                        width: 1.2,
                                      ),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    if (value.isNotEmpty && index < 3) {
                                      FocusScope.of(context).nextFocus();
                                    }
                                  },
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 44),
                          Text(
                            'Didn’t receive OTP?',
                            textAlign: TextAlign.center,
                            style: textTheme.bodyLarge?.copyWith(
                              color: AppColors.secondaryText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          GestureDetector(
                            onTap: () {},
                            child: Text(
                              'Resend code',
                              textAlign: TextAlign.center,
                              style: textTheme.titleMedium?.copyWith(
                                color: AppColors.yellow,
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.yellow,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 58,
                            child: ElevatedButton(
                              onPressed: isSubmitting
                                  ? null
                                  : () {
                                      final code = _controllers
                                          .map(
                                            (controller) =>
                                                controller.text.trim(),
                                          )
                                          .join();
                                      _submittedCode = code;
                                      context
                                          .read<AuthCubit>()
                                          .completeVerification(code: code);
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: isSubmitting
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.white,
                                      ),
                                    )
                                  : const Text('Verify'),
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
