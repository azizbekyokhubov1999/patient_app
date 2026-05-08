import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../booking/presentation/utils/booking_navigation.dart';
import '../../../home/domain/entities/doctor.dart';
import '../../../home/domain/entities/doctor_review.dart';
import '../../../home/domain/entities/hospital.dart';
import '../../../home/domain/entities/hospital_contact_person.dart';
import '../../../home/domain/entities/working_hours_entry.dart';
import '../../../home/domain/entities/hospital_review.dart';
import '../manager/hospital_details_cubit.dart';
import '../manager/hospital_details_state.dart';

final List<Doctor> _kFallbackHospitalSpecialists = [
  Doctor(
    name: 'Dr. Robert Fox',
    specialty: 'Dentist',
    rating: 5.0,
    reviewsCount: 12,
    imageUrl:
        'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?auto=format&fit=crop&w=800&q=80',
    about:
        'Experienced dentist focusing on minimally invasive treatment and preventive care.',
    patientsCount: 890,
    experienceYears: 4,
    workingHours: const [
      WorkingHoursEntry('Monday - Friday', '09:00 am - 06:00 pm'),
    ],
    address: '2464 Royal Ln. Mesa, New Jersey 45463',
    latitude: 40.7153,
    longitude: -74.0024,
    mapImageUrl:
        'https://images.unsplash.com/photo-1524661135-423995f22d0b?auto=format&fit=crop&w=1200&q=80',
    patientReviews: const <DoctorReview>[],
  ),
  Doctor(
    name: 'Dr. Sophia Rossi',
    specialty: 'Otology Specialist',
    rating: 4.9,
    reviewsCount: 53,
    imageUrl:
        'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?auto=format&fit=crop&w=800&q=80',
    about:
        'Specialist in ear disorders with extensive surgical and non-surgical care experience.',
    patientsCount: 1200,
    experienceYears: 8,
    workingHours: const [
      WorkingHoursEntry('Monday - Friday', '10:00 am - 06:00 pm'),
      WorkingHoursEntry('Saturday', '10:00 am - 02:00 pm'),
    ],
    address: '2464 Royal Ln. Mesa, New Jersey 45463',
    latitude: 40.7153,
    longitude: -74.0024,
    mapImageUrl:
        'https://images.unsplash.com/photo-1524661135-423995f22d0b?auto=format&fit=crop&w=1200&q=80',
    patientReviews: const <DoctorReview>[],
  ),
];

class HospitalDetailsPage extends StatelessWidget {
  const HospitalDetailsPage({required this.hospital, super.key});

  final Hospital hospital;

  static Hospital fallbackById(String id) {
    return Hospital(
      id: id,
      name: 'BrightCare Medical',
      rating: 4.8,
      tags: 'Dentist, Ophthalmologist, Otology',
      address: '2464 Royal Ln. Mesa, New Jersey 45463',
      distance: '3.5 Miles',
      eta: '15 Min',
      imageUrl:
          'https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?auto=format&fit=crop&w=1200&q=80',
      description:
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
      treatments: const [
        'Dental Treatments',
        'Eye Treatments',
        'Ear Treatments',
      ],
      specialists: _kFallbackHospitalSpecialists,
      timings: const {
        'Monday': '00:00 - 00:00',
        'Tuesday': '00:00 - 00:00',
        'Wednesday': '00:00 - 00:00',
        'Thursday': '00:00 - 00:00',
        'Friday': '00:00 - 00:00',
        'Saturday': '00:00 - 00:00',
        'Sunday': '00:00 - 00:00',
      },
      contactPerson: const HospitalContactPerson(
        name: 'Amelia Clarke',
        role: 'Receptionist',
        avatarUrl:
            'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=300&q=80',
      ),
      images: const [
        'https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?auto=format&fit=crop&w=1200&q=80',
        'https://images.unsplash.com/photo-1579684385127-1ef15d508118?auto=format&fit=crop&w=1200&q=80',
        'https://images.unsplash.com/photo-1631815588090-d4bfec5b1ccb?auto=format&fit=crop&w=1200&q=80',
        'https://images.unsplash.com/photo-1631248055158-edec7a3c072b?auto=format&fit=crop&w=1200&q=80',
        'https://images.unsplash.com/photo-1584982751601-97dcc096659c?auto=format&fit=crop&w=1200&q=80',
      ],
      galleryImages: const [
        'https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?auto=format&fit=crop&w=1200&q=80',
        'https://images.unsplash.com/photo-1579684385127-1ef15d508118?auto=format&fit=crop&w=1200&q=80',
        'https://images.unsplash.com/photo-1631815588090-d4bfec5b1ccb?auto=format&fit=crop&w=1200&q=80',
        'https://images.unsplash.com/photo-1631248055158-edec7a3c072b?auto=format&fit=crop&w=1200&q=80',
        'https://images.unsplash.com/photo-1584982751601-97dcc096659c?auto=format&fit=crop&w=1200&q=80',
        'https://images.unsplash.com/photo-1505751172876-fa1923c5c528?auto=format&fit=crop&w=1200&q=80',
        'https://images.unsplash.com/photo-1486825586573-7131f7991bdd?auto=format&fit=crop&w=1200&q=80',
        'https://images.unsplash.com/photo-1516549655169-df83a0774514?auto=format&fit=crop&w=1200&q=80',
      ],
      reviews: const [
        HospitalReview(
          userName: 'Leslie Alexander',
          userAvatar:
              'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=200&q=80',
          rating: 5.0,
          comment:
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt.',
          createdAt: '1 months ago',
          isVerified: true,
        ),
        HospitalReview(
          userName: 'Jenny Wilson',
          userAvatar:
              'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&w=200&q=80',
          rating: 5.0,
          comment:
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt.',
          createdAt: '2 months ago',
          isVerified: true,
          reviewImages: [
            'https://images.unsplash.com/photo-1606811971618-4486d14f3f99?auto=format&fit=crop&w=400&q=80',
            'https://plus.unsplash.com/premium_photo-1664475450083-5c9eef17a191?w=500&q=80',
          ],
        ),
      ],
      latitude: 40.7153,
      longitude: -74.0024,
      mapImageUrl:
          'https://images.unsplash.com/photo-1524661135-423995f22d0b?auto=format&fit=crop&w=1200&q=80',
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HospitalDetailsCubit(hospital),
      child: const _HospitalDetailsView(),
    );
  }
}

class _HospitalDetailsView extends StatefulWidget {
  const _HospitalDetailsView();

  @override
  State<_HospitalDetailsView> createState() => _HospitalDetailsViewState();
}

class _HospitalDetailsViewState extends State<_HospitalDetailsView> {
  static const _tabs = [
    'About',
    'Treatments',
    'Specialist',
    'Gallery',
    'Review',
  ];
  static const _previewLength = 140;
  bool _expandedAbout = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HospitalDetailsCubit, HospitalDetailsState>(
      builder: (context, state) {
        final h = state.hospital;

        return Scaffold(
          backgroundColor: AppColors.white,
          bottomNavigationBar: SafeArea(
            top: false,
            minimum: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: () => BookingNavigation.startBooking(
                  context,
                  hospital: h,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  elevation: 6,
                ),
                child: const Text('Book Appointment'),
              ),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _TopImageHeader(hospital: h),
                        _HeaderInfo(hospital: h),
                        const SizedBox(height: 14),
                        const Divider(height: 1, color: AppColors.neutral200),
                        _ActionRow(hospital: h),
                        const Divider(height: 1, color: AppColors.neutral200),
                        _Tabs(
                          selectedIndex: state.selectedTabIndex,
                          onTap: (index) => context
                              .read<HospitalDetailsCubit>()
                              .setTab(index),
                        ),
                        IndexedStack(
                          index: state.selectedTabIndex,
                          children: [
                            _AboutTab(
                              hospital: h,
                              expanded: _expandedAbout,
                              onToggleReadMore: () {
                                setState(
                                  () => _expandedAbout = !_expandedAbout,
                                );
                              },
                            ),
                            _TreatmentsTab(treatments: h.treatments),
                            _SpecialistsTab(
                              specialists: h.specialists,
                              hospital: h,
                            ),
                            _GalleryTab(galleryImages: h.galleryImages),
                            _ReviewsTab(
                              reviews: context
                                  .read<HospitalDetailsCubit>()
                                  .filteredReviews,
                              activeFilters: state.activeReviewFilters,
                              onTapAddReview: () async {
                                final updatedHospital = await context
                                    .push<Hospital>(
                                      AppPaths.leaveReviewHospital,
                                      extra: h,
                                    );
                                if (updatedHospital != null &&
                                    context.mounted) {
                                  context
                                      .read<HospitalDetailsCubit>()
                                      .updateHospital(updatedHospital);
                                }
                              },
                              onSearchChanged: context
                                  .read<HospitalDetailsCubit>()
                                  .setReviewQuery,
                              onToggleFilter: context
                                  .read<HospitalDetailsCubit>()
                                  .toggleReviewFilter,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TopImageHeader extends StatelessWidget {
  const _TopImageHeader({required this.hospital});

  final Hospital hospital;

  @override
  Widget build(BuildContext context) {
    final images = hospital.images.isNotEmpty
        ? hospital.images
        : [hospital.imageUrl];
    final thumbs = images.take(5).toList();
    while (thumbs.length < 5) {
      thumbs.add(hospital.imageUrl);
    }

    return Column(
      children: [
        SizedBox(
          height: 210,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                images.first,
                fit: BoxFit.cover,
                errorBuilder: (context, error, _) =>
                    const ColoredBox(color: AppColors.neutral200),
              ),
              Positioned(
                left: 16,
                top: 14,
                child: _CircleIconButton(
                  icon: LucideIcons.arrowLeft,
                  onTap: () => context.pop(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 44,
          child: Row(
            children: List.generate(thumbs.length, (index) {
              final isLast = index == thumbs.length - 1;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: index == 0 ? 0 : 2),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        thumbs[index],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, _) =>
                            const ColoredBox(color: AppColors.neutral200),
                      ),
                      if (isLast)
                        Container(
                          color: AppColors.primaryText.withValues(alpha: 0.35),
                          child: Center(
                            child: Text(
                              '+10',
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _HeaderInfo extends StatelessWidget {
  const _HeaderInfo({required this.hospital});

  final Hospital hospital;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  hospital.tags,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(
                LucideIcons.star,
                color: Colors.amber,
                size: 18,
                fill: 1,
              ),
              const SizedBox(width: 4),
              Text(
                hospital.rating.toStringAsFixed(1),
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            hospital.name,
            style: textTheme.headlineSmall?.copyWith(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                LucideIcons.mapPin,
                size: 16,
                color: AppColors.secondaryText,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  hospital.address,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                LucideIcons.clock3,
                size: 16,
                color: AppColors.secondaryText,
              ),
              const SizedBox(width: 6),
              Text(
                '${hospital.distance} • ${hospital.eta}',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.hospital});

  final Hospital hospital;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _ActionItem(
            icon: LucideIcons.globe,
            label: 'Website',
            onTap: () => debugPrint('Open website: ${hospital.name}'),
          ),
          _ActionItem(
            icon: LucideIcons.map,
            label: 'Direction',
            onTap: () => debugPrint('Directions: ${hospital.name}'),
          ),
          _ActionItem(
            icon: LucideIcons.messageSquare,
            label: 'Message',
            onTap: () => debugPrint('Message: ${hospital.name}'),
          ),
          _ActionItem(
            icon: LucideIcons.send,
            label: 'Share',
            onTap: () => debugPrint('Share: ${hospital.name}'),
          ),
        ],
      ),
    );
  }
}

class _Tabs extends StatelessWidget {
  const _Tabs({required this.selectedIndex, required this.onTap});

  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 0),
      child: Row(
        children: List.generate(_HospitalDetailsViewState._tabs.length, (
          index,
        ) {
          final selected = index == selectedIndex;
          return Padding(
            padding: const EdgeInsets.only(right: 20),
            child: InkWell(
              onTap: () => onTap(index),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      _HospitalDetailsViewState._tabs[index],
                      style: textTheme.bodyMedium?.copyWith(
                        color: selected
                            ? AppColors.primaryText
                            : AppColors.secondaryText,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    width: 24,
                    height: 3,
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _AboutTab extends StatelessWidget {
  const _AboutTab({
    required this.hospital,
    required this.expanded,
    required this.onToggleReadMore,
  });

  final Hospital hospital;
  final bool expanded;
  final VoidCallback onToggleReadMore;

  @override
  Widget build(BuildContext context) {
    final description = hospital.description;
    final showReadMore =
        description.length > _HospitalDetailsViewState._previewLength;
    final shownText = (!expanded && showReadMore)
        ? '${description.substring(0, _HospitalDetailsViewState._previewLength)}...'
        : description;
    const orderedDays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.primaryText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.secondaryText,
                height: 1.45,
              ),
              children: [
                TextSpan(text: shownText),
                if (showReadMore)
                  WidgetSpan(
                    baseline: TextBaseline.alphabetic,
                    alignment: PlaceholderAlignment.baseline,
                    child: GestureDetector(
                      onTap: onToggleReadMore,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Text(
                          expanded ? 'Read less' : 'Read more',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppColors.yellow,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Hospital Timings',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.primaryText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          ...orderedDays.map((day) {
            final value = hospital.timings[day] ?? 'Closed';
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      day,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 20),
          Text(
            'Hospital Contact',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.primaryText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          _ContactCard(contact: hospital.contactPerson),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(
                'Address',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primaryText,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => debugPrint('View on map: ${hospital.name}'),
                child: Text(
                  'View on Map',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                LucideIcons.mapPin,
                size: 14,
                color: AppColors.secondaryText,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  hospital.address,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              height: 170,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    hospital.mapImageUrl ?? hospital.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, _) =>
                        const ColoredBox(color: AppColors.neutral200),
                  ),
                  Center(
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({required this.contact});

  final HospitalContactPerson contact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.neutral200,
            backgroundImage: NetworkImage(contact.avatarUrl),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  contact.role,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          _CircleIconButton(
            icon: LucideIcons.messageCircle,
            onTap: () => debugPrint('Contact chat'),
          ),
          const SizedBox(width: 8),
          _CircleIconButton(
            icon: LucideIcons.phone,
            onTap: () => debugPrint('Contact call'),
          ),
        ],
      ),
    );
  }
}

class _TreatmentsTab extends StatelessWidget {
  const _TreatmentsTab({required this.treatments});

  final List<String> treatments;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Treatments (${treatments.length})',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.primaryText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            itemCount: treatments.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final treatment = treatments[index];
              return Material(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => debugPrint('Selected: $treatment'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.neutral200),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryText.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            treatment,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  color: AppColors.primaryText,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                        const Icon(
                          LucideIcons.chevronRight,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SpecialistsTab extends StatelessWidget {
  const _SpecialistsTab({
    required this.specialists,
    required this.hospital,
  });

  final List<Doctor> specialists;
  final Hospital hospital;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Specialist (${specialists.length})',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.primaryText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          if (specialists.isEmpty)
            Text(
              'No specialists available yet.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.secondaryText),
            )
          else
            ListView.separated(
              itemCount: specialists.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) =>
                  _SpecialistCard(
                    doctor: specialists[index],
                    hospital: hospital,
                  ),
            ),
        ],
      ),
    );
  }
}

class _SpecialistCard extends StatefulWidget {
  const _SpecialistCard({
    required this.doctor,
    required this.hospital,
  });

  final Doctor doctor;
  final Hospital hospital;

  @override
  State<_SpecialistCard> createState() => _SpecialistCardState();
}

class _SpecialistCardState extends State<_SpecialistCard> {
  bool _favorite = false;

  @override
  Widget build(BuildContext context) {
    final doctor = widget.doctor;

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push(AppPaths.doctorDetails, extra: doctor),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.neutral200),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryText.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: AppColors.neutral200,
                        backgroundImage: NetworkImage(doctor.imageUrl),
                      ),
                      Positioned(
                        right: -2,
                        bottom: -2,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: AppColors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            LucideIcons.badgeCheck,
                            size: 18,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doctor.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: AppColors.primaryText,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          doctor.specialty,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.secondaryText),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            for (var i = 0; i < 5; i++)
                              const Padding(
                                padding: EdgeInsets.only(right: 2),
                                child: Icon(
                                  LucideIcons.star,
                                  size: 14,
                                  color: Colors.amber,
                                  fill: 1,
                                ),
                              ),
                            const SizedBox(width: 4),
                            Text(
                              doctor.rating.toStringAsFixed(1),
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(
                                    color: AppColors.primaryText,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: Container(
                                width: 1,
                                height: 12,
                                color: AppColors.neutral300,
                              ),
                            ),
                            Flexible(
                              child: Text(
                                '${doctor.reviewsCount} Reviews',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: AppColors.secondaryText),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Material(
                    color: _favorite
                        ? AppColors.error.withValues(alpha: 0.12)
                        : AppColors.background,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => setState(() => _favorite = !_favorite),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          LucideIcons.heart,
                          size: 18,
                          color: _favorite ? Colors.red : Colors.grey,
                          fill: _favorite ? 1 : 0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () =>
                      BookingNavigation.startBooking(
                        context,
                        hospital: widget.hospital,
                        selectedSpecialist: doctor,
                      ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.background,
                    foregroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Make Appointment',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GalleryTab extends StatelessWidget {
  const _GalleryTab({required this.galleryImages});

  final List<String> galleryImages;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gallery (${galleryImages.length})',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.primaryText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          if (galleryImages.isEmpty)
            Text(
              'No gallery images yet.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.secondaryText),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: galleryImages.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                final imageUrl = galleryImages[index];
                return GestureDetector(
                  onTap: () => _openFullScreenGallery(
                    context,
                    imageUrl: imageUrl,
                    heroTag: 'gallery_${index}_$imageUrl',
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      color: AppColors.neutral200,
                      child: Hero(
                        tag: 'gallery_${index}_$imageUrl',
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: Icon(
                                LucideIcons.image,
                                color: AppColors.secondaryText,
                                size: 24,
                              ),
                            );
                          },
                          errorBuilder: (context, error, _) => const Center(
                            child: Icon(
                              LucideIcons.imageOff,
                              color: AppColors.secondaryText,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  void _openFullScreenGallery(
    BuildContext context, {
    required String imageUrl,
    required String heroTag,
  }) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) {
        return GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(
              children: [
                Center(
                  child: Hero(
                    tag: heroTag,
                    child: InteractiveViewer(
                      minScale: 0.8,
                      maxScale: 4,
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, _) => const Icon(
                          LucideIcons.imageOff,
                          color: AppColors.white,
                          size: 38,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: MediaQuery.paddingOf(context).top + 8,
                  right: 16,
                  child: Material(
                    color: Colors.black54,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => Navigator.of(context).pop(),
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(
                          LucideIcons.x,
                          color: AppColors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ReviewsTab extends StatelessWidget {
  const _ReviewsTab({
    required this.reviews,
    required this.activeFilters,
    required this.onTapAddReview,
    required this.onSearchChanged,
    required this.onToggleFilter,
  });

  final List<HospitalReview> reviews;
  final Set<String> activeFilters;
  final VoidCallback onTapAddReview;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onToggleFilter;

  @override
  Widget build(BuildContext context) {
    const filters = <String>[
      HospitalDetailsCubit.filterVerified,
      HospitalDetailsCubit.filterLatest,
      HospitalDetailsCubit.filterDetailed,
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Reviews',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primaryText,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: onTapAddReview,
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.pencilLine,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'add review',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              onChanged: onSearchChanged,
              decoration: const InputDecoration(
                hintText: 'Search in reviews',
                prefixIcon: Icon(
                  LucideIcons.search,
                  color: AppColors.secondaryText,
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterButton(),
                const SizedBox(width: 8),
                for (final filter in filters)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _ReviewFilterChip(
                      label: filter,
                      active: activeFilters.contains(filter),
                      onTap: () => onToggleFilter(filter),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (reviews.isEmpty)
            Text(
              'No reviews found.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.secondaryText),
            )
          else
            ListView.separated(
              itemCount: reviews.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) =>
                  _HospitalReviewCard(review: reviews[index]),
            ),
        ],
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(
            LucideIcons.slidersHorizontal,
            size: 14,
            color: AppColors.secondaryText,
          ),
          const SizedBox(width: 4),
          Text(
            'Filter',
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: AppColors.secondaryText),
          ),
          const SizedBox(width: 2),
          Icon(
            LucideIcons.chevronDown,
            size: 14,
            color: AppColors.secondaryText,
          ),
        ],
      ),
    );
  }
}

class _ReviewFilterChip extends StatelessWidget {
  const _ReviewFilterChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: active ? AppColors.white : AppColors.primaryText,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _HospitalReviewCard extends StatefulWidget {
  const _HospitalReviewCard({required this.review});

  final HospitalReview review;

  @override
  State<_HospitalReviewCard> createState() => _HospitalReviewCardState();
}

class _HospitalReviewCardState extends State<_HospitalReviewCard> {
  static const int _previewLength = 95;
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final review = widget.review;
    final showReadMore = review.comment.length > _previewLength;
    final text = showReadMore && !_expanded
        ? '${review.comment.substring(0, _previewLength).trim()}...'
        : review.comment;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.neutral200,
                    backgroundImage: NetworkImage(review.userAvatar),
                  ),
                  if (review.isVerified)
                    const Positioned(
                      right: -2,
                      bottom: -2,
                      child: Icon(
                        LucideIcons.badgeCheck,
                        color: AppColors.primary,
                        size: 16,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  review.userName,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                review.createdAt,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.secondaryText),
              ),
            ],
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.secondaryText,
                height: 1.4,
              ),
              children: [
                TextSpan(text: text),
                if (showReadMore)
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: GestureDetector(
                      onTap: () => setState(() => _expanded = !_expanded),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Text(
                          _expanded ? 'Read less' : 'Read more',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (var i = 0; i < 5; i++)
                const Padding(
                  padding: EdgeInsets.only(right: 2),
                  child: Icon(
                    LucideIcons.star,
                    size: 14,
                    color: Colors.amber,
                    fill: 1,
                  ),
                ),
              const SizedBox(width: 4),
              Text(
                review.rating.toStringAsFixed(1),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.primaryText,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          if (review.reviewImages.isNotEmpty) ...[
            const SizedBox(height: 10),
            GridView.builder(
              itemCount: review.reviewImages.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.35,
              ),
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    review.reviewImages[index],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, _) =>
                        const ColoredBox(color: AppColors.neutral200),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionItem extends StatelessWidget {
  const _ActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.neutral200),
            ),
            child: Icon(icon, size: 20, color: AppColors.primaryText),
          ),
          const SizedBox(height: 7),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: AppColors.primaryText),
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      shape: const CircleBorder(),
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: Icon(icon, size: 18, color: AppColors.primaryText),
        ),
      ),
    );
  }
}
