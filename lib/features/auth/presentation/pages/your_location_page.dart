import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../manager/auth_cubit.dart';
import '../manager/auth_state.dart';

class YourLocationPage extends StatelessWidget {
  const YourLocationPage({super.key});

  void _showLocationNotice(BuildContext context, Authenticated state) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(state.noticeMessage!),
        duration: const Duration(seconds: 5),
        action: state.offerOpenSettings
            ? SnackBarAction(
                label: 'Settings',
                onPressed: () => Geolocator.openAppSettings(),
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocConsumer<AuthCubit, AuthState>(
      listenWhen: (previous, current) =>
          (current is Authenticated &&
              current.completedFlow == AuthFlow.locationAccess) ||
          (current is AuthError && current.flow == AuthFlow.locationAccess),
      listener: (context, state) {
        if (state is Authenticated &&
            state.completedFlow == AuthFlow.locationAccess) {
          if (state.noticeMessage != null) {
            _showLocationNotice(context, state);
          }
          context.read<AuthCubit>().clearCompletedFlow();
          context.push(AppPaths.notificationAccess);
        } else if (state is AuthError &&
            state.flow == AuthFlow.locationAccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              action: SnackBarAction(
                label: 'Continue',
                onPressed: () => context.push(AppPaths.notificationAccess),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        final isSubmitting =
            state is AuthLoading && state.flow == AuthFlow.locationAccess;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: const BoxDecoration(
                        color: AppColors.stroke,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/images/location_illustration.png',
                          width: 72,
                          height: 72,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 42),
                  Text(
                    'What is Your Location?',
                    textAlign: TextAlign.center,
                    style: textTheme.headlineLarge?.copyWith(
                      color: AppColors.primaryText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Allow location access to find services near you.',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyLarge?.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 58,
                    child: ElevatedButton(
                      onPressed: isSubmitting
                          ? null
                          : () => context
                              .read<AuthCubit>()
                              .requestLocationAccess(),
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
                          : const Text('Allow Location Access'),
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextButton(
                    onPressed: isSubmitting
                        ? null
                        : () => context.push(AppPaths.enterLocation),
                    child: Text(
                      'Enter Location Manually',
                      style: textTheme.titleMedium?.copyWith(
                        color: AppColors.yellow,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: isSubmitting
                        ? null
                        : () => context.push(AppPaths.notificationAccess),
                    child: Text(
                      'Skip for now',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.secondaryText,
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
