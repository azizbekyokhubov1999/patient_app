import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/complete_profile_page.dart';
import '../../features/auth/presentation/pages/create_account_page.dart';
import '../../features/auth/presentation/pages/enter_location_page.dart';
import '../../features/auth/presentation/pages/new_password_page.dart';
import '../../features/auth/presentation/pages/notification_access_page.dart';
import '../../features/auth/presentation/pages/onboarding_screen.dart';
import '../../features/auth/presentation/pages/signin_page.dart';
import '../../features/auth/presentation/pages/splash_screen.dart';
import '../../features/auth/presentation/pages/verify_code_page.dart';
import '../../features/auth/presentation/pages/welcome_screen.dart';
import '../../features/auth/presentation/pages/your_location_page.dart';
import '../../features/booking/presentation/pages/appointment_page.dart';
import '../../features/chat/presentation/pages/chat_page.dart';
import '../../features/explore/presentation/pages/explore_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/main_navigation/presentation/pages/main_wrapper_page.dart';
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
        builder: (context, state) => const CreateAccountPage(),
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
        path: AppPaths.yourLocation,
        builder: (context, state) => const YourLocationPage(),
      ),
      GoRoute(
        path: AppPaths.enterLocation,
        builder: (context, state) => const EnterLocationPage(),
      ),
      GoRoute(
        path: AppPaths.notificationAccess,
        builder: (context, state) => const NotificationAccessPage(),
      ),
      GoRoute(
        path: AppPaths.auth,
        builder: (context, state) => const SignInPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainWrapperPage(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppPaths.home,
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppPaths.explore,
                builder: (context, state) => const ExplorePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppPaths.booking,
                builder: (context, state) => const AppointmentPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppPaths.chat,
                builder: (context, state) => const ChatPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppPaths.profile,
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
