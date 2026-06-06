import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../manager/settings_cubit.dart';
import '../manager/settings_state.dart';

class NotificationSettingsPage extends StatelessWidget {
  const NotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsCubit, SettingsState>(
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
      builder: (context, state) {
        final isInitialLoading = state is SettingsLoading;
        final enabled = switch (state) {
          SettingsLoaded(:final notificationsEnabled) => notificationsEnabled,
          _ => context.read<SettingsCubit>().notificationsEnabled,
        };

        return Scaffold(
          backgroundColor: AppColors.white,
          appBar: const CustomAppBar(
            title: 'Notification Settings',
            backgroundColor: AppColors.white,
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.md,
            ),
            children: [
              if (isInitialLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              else
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Push Notifications',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryText,
                    ),
                  ),
                  subtitle: const Text(
                    'Receive appointment reminders and updates',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  value: enabled,
                  activeThumbColor: AppColors.white,
                  activeTrackColor: AppColors.primary,
                  onChanged: (value) => context
                      .read<SettingsCubit>()
                      .updateNotificationPreferences(value),
                ),
            ],
          ),
        );
      },
    );
  }
}
