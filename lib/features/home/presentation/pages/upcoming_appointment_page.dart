import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_paths.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../manager/upcoming_appointment_cubit.dart';
import '../manager/upcoming_appointment_state.dart';
import '../models/appointment_detail_args.dart';
import '../widgets/upcoming_appointment_card.dart';

class UpcomingAppointmentPage extends StatefulWidget {
  const UpcomingAppointmentPage({super.key});

  @override
  State<UpcomingAppointmentPage> createState() =>
      _UpcomingAppointmentPageState();
}

class _UpcomingAppointmentPageState extends State<UpcomingAppointmentPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _searchOpen = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _closeSearch(BuildContext context) {
    setState(() {
      _searchOpen = false;
      _searchController.clear();
    });
    context.read<UpcomingAppointmentCubit>().filterByQuery('');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: () => context.pop(),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.stroke),
                color: AppColors.white,
              ),
              child: const Icon(
                LucideIcons.arrowLeft,
                size: 20,
                color: AppColors.primaryText,
              ),
            ),
          ),
        ),
        title: _searchOpen
            ? Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: 'Search..',
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      style: theme.titleMedium?.copyWith(
                        color: AppColors.primaryText,
                      ),
                      onChanged: (value) => context
                          .read<UpcomingAppointmentCubit>()
                          .filterByQuery(value),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    color: AppColors.secondaryText,
                    onPressed: () => _closeSearch(context),
                  ),
                ],
              )
            : Text(
                'Upcoming Appointment',
                style: theme.titleMedium?.copyWith(
                  color: AppColors.primaryText,
                  fontWeight: FontWeight.w700,
                ),
              ),
        centerTitle: !_searchOpen,
        actions: [
          if (!_searchOpen)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () => setState(() => _searchOpen = true),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.stroke),
                    color: AppColors.white,
                  ),
                  child: const Icon(
                    LucideIcons.search,
                    size: 20,
                    color: AppColors.primaryText,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: BlocBuilder<UpcomingAppointmentCubit, UpcomingAppointmentState>(
        builder: (context, state) {
          if (state is UpcomingAppointmentInitial ||
              state is UpcomingAppointmentLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is UpcomingAppointmentError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: theme.bodyMedium?.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ),
            );
          }

          if (state is UpcomingAppointmentEmpty) {
            return _EmptyBookPrompt(
              onBookNow: () => context.push(AppPaths.bookAppointment),
            );
          }

          if (state is UpcomingAppointmentLoaded) {
            final filtered = state.filteredAppointments;

            if (filtered.isEmpty && state.appointments.isNotEmpty) {
              return RefreshIndicator(
                onRefresh: () =>
                    context.read<UpcomingAppointmentCubit>().refresh(),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxl,
                    vertical: AppSpacing.lg,
                  ),
                  children: [
                    SizedBox(height: MediaQuery.sizeOf(context).height * 0.2),
                    Icon(
                      LucideIcons.searchX,
                      size: 56,
                      color: AppColors.secondaryText.withValues(alpha: 0.45),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'No matching appointments',
                      textAlign: TextAlign.center,
                      style: theme.titleMedium?.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () =>
                  context.read<UpcomingAppointmentCubit>().refresh(),
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xxl,
                  vertical: AppSpacing.lg,
                ),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final apt = filtered[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom:
                          index < filtered.length - 1 ? AppSpacing.md : 0,
                    ),
                    child: UpcomingAppointmentCard(
                      appointment: apt,
                      onTap: () => context.push(
                        AppPaths.appointmentDetail,
                        extra: AppointmentDetailArgs(
                          appointmentId: apt.appointmentId,
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _EmptyBookPrompt extends StatelessWidget {
  const _EmptyBookPrompt({required this.onBookNow});

  final VoidCallback onBookNow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.calendarOff,
              size: 72,
              color: AppColors.secondaryText.withValues(alpha: 0.45),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No upcoming appointments',
              textAlign: TextAlign.center,
              style: theme.titleMedium?.copyWith(
                color: AppColors.primaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onBookNow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Book Now',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
