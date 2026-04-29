import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/auth_page.dart';
import '../../features/auth/presentation/pages/complete_profile_page.dart';
import '../../features/auth/presentation/pages/create_account_page.dart';
import '../../features/auth/presentation/pages/new_password_page.dart';
import '../../features/auth/presentation/pages/onboarding_screen.dart';
import '../../features/auth/presentation/pages/signin_page.dart';
import '../../features/auth/presentation/pages/splash_screen.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/auth/presentation/pages/verify_code_page.dart';
import '../../features/auth/presentation/pages/welcome_screen.dart';
import '../../features/booking/presentation/pages/appointments_page.dart';
import '../../features/home/presentation/pages/explore_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../constants/app_paths.dart';

abstract final class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppPaths.splash,
    routes: [
      GoRoute(
        path: AppPaths.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppPaths.welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: AppPaths.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppPaths.signUp,
        builder: (context, state) => const SignUpPage(),
      ),
      GoRoute(
        path: AppPaths.signIn,
        builder: (context, state) => const SignInPage(),
      ),
      GoRoute(
        path: AppPaths.createAccount,
        builder: (context, state) => const CreateAccountPage(),
      ),
      GoRoute(
        path: AppPaths.verifyCode,
        builder: (context, state) => const VerifyCodePage(),
      ),
      GoRoute(
        path: AppPaths.newPassword,
        builder: (context, state) => const NewPasswordPage(),
      ),
      GoRoute(
        path: AppPaths.completeProfile,
        builder: (context, state) => const CompleteProfilePage(),
      ),
      GoRoute(
        path: AppPaths.auth,
        builder: (context, state) => const AuthPage(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return MainNavigationScaffold(child: child);
        },
        routes: [
          GoRoute(
            path: AppPaths.home,
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: AppPaths.explore,
            builder: (context, state) => const ExplorePage(),
          ),
          GoRoute(
            path: AppPaths.appointments,
            builder: (context, state) => const AppointmentsPage(),
          ),
          GoRoute(
            path: AppPaths.profile,
            builder: (context, state) => const ProfilePage(),
          ),
        ],
      ),
    ],
  );
}

class MainNavigationScaffold extends StatelessWidget {
  const MainNavigationScaffold({
    required this.child,
    super.key,
  });

  final Widget child;

  int _selectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith(AppPaths.explore)) return 1;
    if (location.startsWith(AppPaths.appointments)) return 2;
    if (location.startsWith(AppPaths.profile)) return 3;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppPaths.home);
      case 1:
        context.go(AppPaths.explore);
      case 2:
        context.go(AppPaths.appointments);
      case 3:
        context.go(AppPaths.profile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex(context),
        onDestinationSelected: (index) => _onTap(context, index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: 'Appointments',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
