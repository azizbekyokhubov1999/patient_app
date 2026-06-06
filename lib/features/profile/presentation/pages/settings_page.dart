import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../manager/settings_cubit.dart';
import '../manager/settings_state.dart';
import '../widgets/settings_menu_tile.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<bool> _showDeleteConfirmationDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Are you sure?',
          style: AppTextStyles.headlineSmall,
        ),
        content: const Text(
          'This action cannot be undone. Your account and all data will be permanently deleted.',
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
              'Delete Account',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    return confirmed == true;
  }

  Future<void> _showDeletePasswordDialog(BuildContext context) async {
    final passwordController = TextEditingController();
    var obscure = true;
    var isDeleting = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Delete Account',
              style: AppTextStyles.headlineSmall,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Enter your password to confirm account deletion.',
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.45,
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: obscure,
                  enabled: !isDeleting,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    filled: true,
                    fillColor: AppColors.neutral100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      onPressed: isDeleting
                          ? null
                          : () {
                              setDialogState(() => obscure = !obscure);
                            },
                      icon: Icon(
                        obscure
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed:
                    isDeleting ? null : () => Navigator.pop(dialogContext),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: AppColors.secondaryText),
                ),
              ),
              TextButton(
                onPressed: isDeleting
                    ? null
                    : () async {
                        final password = passwordController.text.trim();
                        if (password.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter your password'),
                            ),
                          );
                          return;
                        }

                        setDialogState(() => isDeleting = true);

                        final deleted = await context
                            .read<SettingsCubit>()
                            .deleteUserAccount(
                              confirmationPassword: password,
                            );

                        if (!dialogContext.mounted) return;

                        if (deleted) {
                          Navigator.pop(dialogContext);
                          if (context.mounted) {
                            context.go(AppPaths.signIn);
                          }
                          return;
                        }

                        setDialogState(() => isDeleting = false);
                      },
                child: isDeleting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Delete',
                        style: TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );

    passwordController.dispose();
  }

  Future<void> _showDeleteAccountDialog(BuildContext context) async {
    final confirmed = await _showDeleteConfirmationDialog(context);
    if (!confirmed || !context.mounted) return;

    await _showDeletePasswordDialog(context);

    if (!context.mounted) return;

    final state = context.read<SettingsCubit>().state;
    if (state is SettingsActionSuccess && state.message.contains('mock')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account deletion simulated in mock mode'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsCubit, SettingsState>(
      listenWhen: (previous, current) => current is SettingsError,
      listener: (context, state) {
        if (state is SettingsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: const CustomAppBar(
          title: 'Settings',
          backgroundColor: AppColors.white,
        ),
        body: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, state) {
            if (state is SettingsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return ListView(
              children: [
                SettingsMenuTile(
                  icon: Icons.notifications_none_outlined,
                  title: 'Notification Settings',
                  onTap: () => context.push(AppPaths.notificationSettings),
                ),
                const Divider(height: 1, color: AppColors.stroke),
                SettingsMenuTile(
                  icon: Icons.vpn_key_outlined,
                  title: 'Password Manager',
                  onTap: () => context.push(AppPaths.passwordManager),
                ),
                const Divider(height: 1, color: AppColors.stroke),
                SettingsMenuTile(
                  icon: Icons.delete_outline,
                  title: 'Delete Account',
                  onTap: () => _showDeleteAccountDialog(context),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
