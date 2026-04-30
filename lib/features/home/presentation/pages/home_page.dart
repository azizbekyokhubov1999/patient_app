import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/entities/doctor.dart';
import '../../domain/entities/hospital.dart';
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
      create: (_) => HomeCubit(),
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
                        onTapSeeAll: () =>
                            debugPrint('Upcoming see all tapped'),
                      ),
                      const SizedBox(height: 12),
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
                              child: _AppointmentCard(appointment: appointment),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      _DotIndicators(
                        count: state.appointments.length,
                        currentIndex: state.currentAppointmentIndex,
                      ),
                      const SizedBox(height: 20),
                      _SectionTitle(
                        title: 'Services',
                        onTapSeeAll: () =>
                            debugPrint('Services see all tapped'),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 42,
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
                                      size: 14,
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
                            debugPrint('Hospitals see all tapped'),
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
                              onTap: () => debugPrint('Hospital card tapped'),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 22),
                      _SectionTitle(
                        title: 'Top Specialist',
                        onTapSeeAll: () =>
                            debugPrint('Top specialists see all tapped'),
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
                            onTap: () => debugPrint('Doctor card tapped'),
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
                          Icons.location_on_rounded,
                          color: AppColors.yellow,
                          size: 18,
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
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.white,
                          size: 20,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () => debugPrint('Notification icon tapped'),
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.notifications_none_rounded,
                        color: AppColors.white,
                      ),
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
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
            child: TextField(
              readOnly: true,
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: textTheme.bodyMedium?.copyWith(
                  color: AppColors.secondaryText,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.secondaryText,
                ),
                suffixIcon: const Icon(
                  Icons.tune_rounded,
                  color: AppColors.primaryText,
                ),
              ),
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
                      child: const Icon(
                        Icons.person,
                        color: AppColors.secondaryText,
                        size: 34,
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
                            style: textTheme.titleMedium?.copyWith(
                              color: AppColors.primaryText,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            appointment.specialty,
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppColors.secondaryText,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: AppColors.yellow,
                                size: 17,
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
                    Icons.calendar_today_rounded,
                    size: 15,
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
                    Icons.access_time_rounded,
                    size: 15,
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

class _HospitalCard extends StatelessWidget {
  const _HospitalCard({required this.hospital, required this.onTap});

  final Hospital hospital;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
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
                  image: NetworkImage(hospital.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: AppColors.error,
                      size: 16,
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
                          hospital.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleMedium?.copyWith(
                            color: AppColors.primaryText,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.star_rounded,
                        color: AppColors.yellow,
                        size: 16,
                      ),
                      Text(
                        hospital.rating.toStringAsFixed(1),
                        style: textTheme.labelLarge?.copyWith(
                          color: AppColors.primaryText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hospital.tags,
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
                        Icons.location_on_outlined,
                        color: AppColors.secondaryText,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          hospital.address,
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
                        Icons.access_time_rounded,
                        color: AppColors.secondaryText,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        hospital.eta,
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.secondaryText,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.near_me_rounded,
                        color: AppColors.primary,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        hospital.distance,
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.secondaryText,
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
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 11,
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
                  Icons.star_rounded,
                  color: AppColors.yellow,
                  size: 16,
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
                    '${doctor.reviews} Reviews',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                ),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.north_east_rounded,
                    size: 15,
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
