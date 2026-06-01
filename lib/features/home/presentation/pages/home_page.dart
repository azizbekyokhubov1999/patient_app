import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../notification/presentation/manager/notification_cubit.dart';
import '../../../notification/presentation/manager/notification_state.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/entities/doctor.dart';
import '../../domain/entities/filter_result.dart';
import '../../domain/entities/hospital.dart';
import '../../domain/entities/service_category.dart';
import '../../../../core/di/app_dependencies.dart';
import '../models/filter_args.dart';
import '../manager/home_cubit.dart';
import '../manager/home_state.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final PageController _appointmentController;

  @override
  void initState() {
    super.initState();
    _appointmentController = PageController(viewportFraction: 0.93);
  }

  @override
  void dispose() {
    _appointmentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocProvider(
      create: (_) => HomeCubit(
        repository: AppDependencies.instance.homeRepository,
      )..loadHomeData(),
      child: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _HomeHeader(textTheme: textTheme)),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _SectionTitle(
                        title: 'Upcoming Appointment',
                        onTapSeeAll: () => context.push(AppPaths.upcomingAppointments),
                      ),
                      const SizedBox(height: 12),
                      if (state.isLoading && state.appointments.isEmpty)
                        const SizedBox(
                          height: 170,
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (state.appointments.isEmpty)
                        const SizedBox(
                          height: 170,
                          child: _NoUpcomingAppointmentsCard(),
                        )
                      else
                        SizedBox(
                          height: 170,
                          child: PageView.builder(
                            controller: _appointmentController,
                            itemCount: state.appointments.length,
                            onPageChanged: context
                                .read<HomeCubit>()
                                .updateCurrentAppointment,
                            itemBuilder: (context, index) {
                              final appointment = state.appointments[index];
                              return Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child:
                                    _AppointmentCard(appointment: appointment),
                              );
                            },
                          ),
                        ),
                      if (state.appointments.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _DotIndicators(
                          count: state.appointments.length,
                          currentIndex: state.currentAppointmentIndex,
                        ),
                      ],
                      const SizedBox(height: 20),
                      _SectionTitle(
                        title: 'Services',
                        onTapSeeAll: () => unawaited(_openServices(context)),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 46,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: state.services.length,
                          separatorBuilder: (_, index) =>
                              const SizedBox(width: 10),
                          itemBuilder: (context, index) {
                            final service = state.services[index];
                            final isSelected =
                                state.selectedServiceIndex == index;
                            return InkWell(
                              onTap: () => context
                                  .read<HomeCubit>()
                                  .selectService(index),
                              borderRadius: BorderRadius.circular(22),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.white,
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(color: AppColors.stroke),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      service.icon,
                                      size: 19,
                                      color: isSelected
                                          ? AppColors.white
                                          : AppColors.primaryText,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      service.title,
                                      style: textTheme.labelLarge?.copyWith(
                                        color: isSelected
                                            ? AppColors.white
                                            : AppColors.primaryText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 22),
                      _SectionTitle(
                        title: 'Nearby Hospitals',
                        onTapSeeAll: () =>
                            context.push(AppPaths.nearbyHospitals),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 260,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: state.hospitals.length,
                          separatorBuilder: (_, index) =>
                              const SizedBox(width: 14),
                          itemBuilder: (context, index) {
                            return _HospitalCard(
                              hospital: state.hospitals[index],
                              onTap: () => context.push(
                                AppPaths.hospitalDetails,
                                extra: state.hospitals[index],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 22),
                      _SectionTitle(
                        title: 'Top Specialist',
                        onTapSeeAll: () => context.push(AppPaths.topSpecialist),
                      ),
                      const SizedBox(height: 12),
                      GridView.builder(
                        itemCount: state.doctors.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.9,
                            ),
                        itemBuilder: (context, index) {
                          return _DoctorCard(
                            doctor: state.doctors[index],
                            onTap: () => context.push(
                              AppPaths.doctorDetails,
                              extra: state.doctors[index],
                            ),
                          );
                        },
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _openServices(BuildContext context) async {
    final selected = await context.push<ServiceCategory>(AppPaths.services);
    if (!context.mounted) return;
    if (selected != null) {
      context.read<HomeCubit>().filterByServiceCategory(selected);
    }
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.textTheme});

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(20, 42, 20, 88),
          decoration: const BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Location',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(
                          LucideIcons.mapPin,
                          color: AppColors.yellow,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'New York, USA',
                          style: textTheme.titleMedium?.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(
                          LucideIcons.chevronDown,
                          color: AppColors.white,
                          size: 20,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              BlocBuilder<NotificationCubit, NotificationState>(
                builder: (context, notifState) {
                  final count = notifState.unreadCount;
                  return InkWell(
                    onTap: () => context.push(AppPaths.notifications),
                    borderRadius: BorderRadius.circular(16),
                    child: Badge(
                      isLabelVisible: count > 0,
                      backgroundColor: AppColors.error,
                      label: Text(
                        '$count',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          LucideIcons.bell,
                          color: AppColors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        Positioned(
          left: 20,
          right: 20,
          bottom: 16,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => context.push(AppPaths.search),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Icon(
                              LucideIcons.search,
                              color: AppColors.secondaryText,
                              size: 22,
                            ),
                          ),
                          Text(
                            'Search',
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    final homeCubit = context.read<HomeCubit>();
                    final current = homeCubit.currentFilter ?? FilterResult.defaults();
                    final result = await context.push<FilterResult>(
                      AppPaths.filter,
                      extra: FilterArgs(initialFilter: current),
                    );
                    if (result != null && context.mounted) {
                      homeCubit.applyFilters(result);
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    child: Icon(
                      LucideIcons.slidersHorizontal,
                      color: AppColors.primaryText,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.onTapSeeAll});

  final String title;
  final VoidCallback onTapSeeAll;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: textTheme.titleLarge?.copyWith(
              color: AppColors.primaryText,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        InkWell(
          onTap: onTapSeeAll,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Text(
              'See All',
              style: textTheme.bodyMedium?.copyWith(color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }
}

class _NoUpcomingAppointmentsCard extends StatelessWidget {
  const _NoUpcomingAppointmentsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.stroke),
      ),
      alignment: Alignment.center,
      child: Text(
        'No upcoming appointments',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.secondaryText,
              fontWeight: FontWeight.w500,
            ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _DoctorImage extends StatelessWidget {
  const _DoctorImage({this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim() ?? '';
    if (url.isEmpty) {
      return const Icon(
        LucideIcons.userRound,
        color: AppColors.secondaryText,
        size: 34,
      );
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => const Icon(
        LucideIcons.userRound,
        color: AppColors.secondaryText,
        size: 34,
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({required this.appointment});

  final Appointment appointment;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: () => debugPrint('Appointment card tapped'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.stroke),
        ),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                child: Row(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.stroke,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: _DoctorImage(
                        imageUrl: appointment.doctorImageUrl,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            appointment.doctorName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.titleMedium?.copyWith(
                              color: AppColors.primaryText,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            appointment.specialty,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppColors.secondaryText,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                LucideIcons.star,
                                color: Colors.amber,
                                size: 18,
                                fill: 1,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '${appointment.rating}',
                                style: textTheme.labelLarge?.copyWith(
                                  color: AppColors.primaryText,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  const Icon(
                    LucideIcons.calendar,
                    size: 18,
                    color: AppColors.white,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    appointment.dateLabel,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    LucideIcons.clock,
                    size: 18,
                    color: AppColors.white,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    appointment.timeLabel,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DotIndicators extends StatelessWidget {
  const _DotIndicators({required this.count, required this.currentIndex});

  final int count;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isCurrent = index == currentIndex;
        return Container(
          width: isCurrent ? 10 : 8,
          height: isCurrent ? 10 : 8,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: isCurrent ? AppColors.yellow : AppColors.stroke,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}

class _HospitalCard extends StatefulWidget {
  const _HospitalCard({required this.hospital, required this.onTap});

  final Hospital hospital;
  final VoidCallback onTap;

  @override
  State<_HospitalCard> createState() => _HospitalCardState();
}

class _HospitalCardState extends State<_HospitalCard> {
  bool _favorite = true;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 258,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.stroke),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 112,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14),
                ),
                image: DecorationImage(
                  image: NetworkImage(widget.hospital.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        setState(() => _favorite = !_favorite);
                      },
                      customBorder: const CircleBorder(),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          LucideIcons.heart,
                          color: _favorite ? Colors.red : Colors.grey,
                          fill: _favorite ? 1 : 0,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.hospital.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleMedium?.copyWith(
                            color: AppColors.primaryText,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Icon(
                        LucideIcons.star,
                        color: Colors.amber,
                        size: 18,
                        fill: 1,
                      ),
                      Text(
                        widget.hospital.rating.toStringAsFixed(1),
                        style: textTheme.labelLarge?.copyWith(
                          color: AppColors.primaryText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.hospital.tags,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        LucideIcons.mapPin,
                        color: AppColors.secondaryText,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.hospital.address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        LucideIcons.clock,
                        color: AppColors.secondaryText,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.hospital.eta,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        LucideIcons.navigation,
                        color: AppColors.primary,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          widget.hospital.distance,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  const _DoctorCard({required this.doctor, required this.onTap});

  final Doctor doctor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.stroke),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 23,
                      backgroundImage: NetworkImage(doctor.imageUrl),
                    ),
                    Positioned(
                      right: -2,
                      bottom: -1,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          LucideIcons.badgeCheck,
                          size: 12,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    doctor.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryText,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              doctor.specialty,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.secondaryText,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                const Icon(
                  LucideIcons.star,
                  color: Colors.amber,
                  size: 18,
                  fill: 1,
                ),
                const SizedBox(width: 3),
                Text(
                  doctor.rating.toStringAsFixed(1),
                  style: textTheme.labelLarge?.copyWith(
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${doctor.reviewsCount} Reviews',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                ),
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    LucideIcons.arrowUpRight,
                    size: 17,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
