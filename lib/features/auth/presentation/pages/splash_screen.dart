import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../manager/auth_cubit.dart';
import '../manager/auth_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        context.read<AuthCubit>().checkSession();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (previous, current) =>
          current is Authenticated &&
              current.completedFlow == AuthFlow.sessionCheck ||
          current is Unauthenticated ||
          (current is AuthError && current.flow == AuthFlow.sessionCheck),
      listener: (context, state) {
        if (!mounted) return;

        if (state is Authenticated &&
            state.completedFlow == AuthFlow.sessionCheck) {
          context.read<AuthCubit>().clearCompletedFlow();
          context.go(
            state.isProfileComplete
                ? AppPaths.home
                : AppPaths.completeProfile,
          );
          return;
        }

        context.go(AppPaths.welcome);
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: Stack(
          children: const [
            _SplashDecor(),
            _SplashLogo(),
          ],
        ),
      ),
    );
  }
}

class _SplashDecor extends StatelessWidget {
  const _SplashDecor();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned(
            top: -80,
            left: -90,
            child: _FadedBlob(
              size: 220,
              color: AppColors.neutral200.withValues(alpha: 0.45),
            ),
          ),
          Positioned(
            right: -50,
            bottom: 60,
            child: _FadedBlob(
              size: 150,
              color: AppColors.neutral200.withValues(alpha: 0.35),
            ),
          ),
        ],
      ),
    );
  }
}

class _SplashLogo extends StatelessWidget {
  const _SplashLogo();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            'assets/images/logo.svg',
            width: 220,
            fit: BoxFit.contain,
            colorFilter: const ColorFilter.mode(
              AppColors.primaryText,
              BlendMode.srcIn,
            ),
            semanticsLabel: 'Logo',
          ),
        ],
      ),
    );
  }
}

class _FadedBlob extends StatelessWidget {
  const _FadedBlob({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(120),
          topRight: Radius.circular(40),
          bottomLeft: Radius.circular(60),
          bottomRight: Radius.circular(120),
        ),
      ),
    );
  }
}
