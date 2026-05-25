import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../manager/auth_cubit.dart';
import '../manager/auth_state.dart';

/// Sends a Firebase password-reset email to the user.
class NewPasswordPage extends StatefulWidget {
  const NewPasswordPage({super.key});

  @override
  State<NewPasswordPage> createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _resetSubmitted = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    InputDecoration fieldDecoration({required String hintText}) {
      return InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: AppColors.secondaryText),
        filled: true,
        fillColor: AppColors.stroke,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
        ),
      );
    }

    return BlocConsumer<AuthCubit, AuthState>(
      listenWhen: (previous, current) {
        if (current is AuthError && current.flow == AuthFlow.newPassword) {
          return true;
        }
        if (_resetSubmitted &&
            previous is AuthLoading &&
            current is! AuthLoading) {
          return true;
        }
        if (current is Authenticated &&
            current.completedFlow == AuthFlow.newPassword) {
          return true;
        }
        return false;
      },
      listener: (context, state) {
        if (state is AuthError && state.flow == AuthFlow.newPassword) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
          return;
        }

        if (_resetSubmitted &&
            (state is Unauthenticated ||
                (state is Authenticated &&
                    state.completedFlow == AuthFlow.newPassword))) {
          _resetSubmitted = false;
          if (state is Authenticated) {
            context.read<AuthCubit>().clearCompletedFlow();
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Password reset link sent. Check your email inbox.',
              ),
            ),
          );
          context.go(AppPaths.signIn);
        }
      },
      builder: (context, state) {
        final isSubmitting =
            state is AuthLoading && state.flow == AuthFlow.newPassword;
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(
                20,
                10,
                20,
                MediaQuery.viewInsetsOf(context).bottom + 16,
              ),
              child: Form(
                key: _formKey,
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
                            context.go(AppPaths.signIn);
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
                      'Forgot Password',
                      textAlign: TextAlign.center,
                      style: textTheme.headlineLarge?.copyWith(
                        color: AppColors.primaryText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter your account email and we will send you a link to reset your password.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyLarge?.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 46),
                    Text(
                      'Email',
                      style: textTheme.titleMedium?.copyWith(
                        color: AppColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: AppColors.primaryText),
                      decoration: fieldDecoration(hintText: 'example@gmail.com'),
                      validator: (value) {
                        final text = value?.trim() ?? '';
                        if (text.isEmpty) return 'Email is required';
                        if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                            .hasMatch(text)) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 34),
                    SizedBox(
                      height: 58,
                      child: ElevatedButton(
                        onPressed: isSubmitting
                            ? null
                            : () {
                                if (_formKey.currentState?.validate() ?? false) {
                                  _resetSubmitted = true;
                                  context.read<AuthCubit>().sendPasswordReset(
                                    email: _emailController.text,
                                  );
                                }
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
                            : const Text('Send Reset Link'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
