import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../auth/presentation/manager/auth_cubit.dart';
import '../../../auth/presentation/manager/auth_state.dart';
import '../manager/profile_cubit.dart';
import '../manager/profile_state.dart';
import '../widgets/profile_menu_item.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthCubit>().state;
      if (authState is Authenticated) {
        context.read<ProfileCubit>().loadUserProfile();
      }
    });
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Logout',
          style: AppTextStyles.headlineSmall,
        ),
        content: const Text(
          'Are you sure you want to log out of your account?',
          style: TextStyle(
            fontSize: 15,
            height: 1.45,
            color: AppColors.secondaryText,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.secondaryText),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Log out',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    await context.read<AuthCubit>().signOut();
    if (context.mounted) {
      context.go(AppPaths.signIn);
    }
  }

  void _openPaymentMethods(BuildContext context) {
    context.push(AppPaths.profilePaymentMethods);
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature — coming soon')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showBack = context.canPop();

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: showBack
          ? CustomAppBar(
              title: 'Profile',
              backgroundColor: AppColors.white,
            )
          : AppBar(
              backgroundColor: AppColors.white,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              automaticallyImplyLeading: false,
              title: const Text(
                'Profile',
                style: AppTextStyles.headlineSmall,
              ),
            ),
      body: BlocListener<AuthCubit, AuthState>(
        listenWhen: (previous, current) =>
            current is Unauthenticated ||
            (current is Authenticated && previous is! Authenticated),
        listener: (context, authState) {
          if (authState is Unauthenticated) {
            context.go(AppPaths.signIn);
            return;
          }
          if (authState is Authenticated) {
            context.read<ProfileCubit>().loadUserProfile();
          }
        },
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, authState) {
            if (authState is! Authenticated) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Sign in to view your profile',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.secondaryText),
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () => context.go(AppPaths.signIn),
                        child: const Text('Sign In'),
                      ),
                    ],
                  ),
                ),
              );
            }

            return BlocBuilder<ProfileCubit, ProfileState>(
              builder: (context, state) {
                if (state.status == ProfileState.loading &&
                    state.user == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.status == ProfileState.failure &&
                    state.user == null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            state.errorMessage ?? 'Failed to load profile',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.secondaryText,
                            ),
                          ),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: () => context
                                .read<ProfileCubit>()
                                .loadUserProfile(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final user = state.user;
                final displayName =
                    user?.displayName ?? authState.user.name;
                final photoUrl =
                    user?.photoUrl ?? authState.user.photoUrl;

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      _ProfileHeader(
                        displayName: displayName,
                        photoUrl: photoUrl,
                        isUpdatingAvatar:
                            state.status == ProfileState.updatingAvatar,
                        onEditAvatar: () => context
                            .read<ProfileCubit>()
                            .updateProfilePicture(),
                      ),
                      const SizedBox(height: 28),
                      const Divider(height: 1, color: AppColors.stroke),
                      ProfileMenuItem(
                        icon: Icons.person_outline,
                        title: 'Your profile',
                        onTap: () async {
                          await context.push(AppPaths.editProfile);
                          if (context.mounted) {
                            context.read<ProfileCubit>().loadUserProfile();
                          }
                        },
                      ),
                      const Divider(height: 1, color: AppColors.stroke),
                      ProfileMenuItem(
                        icon: Icons.credit_card_outlined,
                        title: 'Payment Methods',
                        onTap: () => _openPaymentMethods(context),
                      ),
                      const Divider(height: 1, color: AppColors.stroke),
                      ProfileMenuItem(
                        icon: Icons.favorite_border_outlined,
                        title: 'My Favourites',
                        onTap: () => context.push(AppPaths.myFavourites),
                      ),
                      const Divider(height: 1, color: AppColors.stroke),
                      ProfileMenuItem(
                        icon: Icons.confirmation_number_outlined,
                        title: 'My Coupons',
                        onTap: () => context.push(AppPaths.myCoupons),
                      ),
                      const Divider(height: 1, color: AppColors.stroke),
                      ProfileMenuItem(
                        icon: Icons.account_balance_wallet_outlined,
                        title: 'My Wallet',
                        onTap: () => context.push(AppPaths.myWallet),
                      ),
                      const Divider(height: 1, color: AppColors.stroke),
                      ProfileMenuItem(
                        icon: Icons.settings_outlined,
                        title: 'Settings',
                        onTap: () => context.push(AppPaths.settings),
                      ),
                      const Divider(height: 1, color: AppColors.stroke),
                      ProfileMenuItem(
                        icon: Icons.info_outline,
                        title: 'Help Center',
                        onTap: () => context.push(AppPaths.helpCenter),
                      ),
                      const Divider(height: 1, color: AppColors.stroke),
                      ProfileMenuItem(
                        icon: Icons.lock_outline,
                        title: 'Privacy Policy',
                        onTap: () => context.push(AppPaths.privacyPolicy),
                      ),
                      const Divider(height: 1, color: AppColors.stroke),
                      ProfileMenuItem(
                        icon: Icons.logout_outlined,
                        title: 'Log out',
                        onTap: () => _showLogoutDialog(context),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.displayName,
    required this.photoUrl,
    required this.isUpdatingAvatar,
    required this.onEditAvatar,
  });

  final String displayName;
  final String photoUrl;
  final bool isUpdatingAvatar;
  final VoidCallback onEditAvatar;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.stroke, width: 2),
              ),
              child: CircleAvatar(
                radius: 56,
                backgroundColor: AppColors.neutral200,
                backgroundImage:
                    photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                child: photoUrl.isEmpty
                    ? Icon(
                        Icons.person_rounded,
                        size: 56,
                        color: AppColors.secondaryText.withValues(alpha: 0.45),
                      )
                    : null,
              ),
            ),
            if (isUpdatingAvatar)
              Positioned.fill(
                child: Container(
                  margin: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Colors.black38,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Material(
                color: AppColors.primary,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: isUpdatingAvatar ? null : onEditAvatar,
                  customBorder: const CircleBorder(),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.edit,
                      size: 16,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          displayName,
          textAlign: TextAlign.center,
          style: AppTextStyles.headlineSmall,
        ),
      ],
    );
  }
}
