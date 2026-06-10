import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../booking/presentation/utils/booking_navigation.dart';
import '../../../../core/constants/app_paths.dart';
import '../../../../core/di/app_dependencies.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/link_launcher.dart';
import '../../data/models/review_model.dart';
import '../../domain/entities/doctor.dart';
import '../../domain/entities/doctor_review.dart';
import '../../domain/entities/working_hours_entry.dart';

class DoctorDetailsPage extends StatefulWidget {
  const DoctorDetailsPage({required this.doctor, super.key});

  final Doctor doctor;

  @override
  State<DoctorDetailsPage> createState() => _DoctorDetailsPageState();
}

class _DoctorDetailsPageState extends State<DoctorDetailsPage> {
  static const int _aboutPreviewLength = 160;
  bool _aboutExpanded = false;
  bool _favorite = false;
  bool _favoriteBusy = false;
  bool _hospitalNavBusy = false;
  late Doctor _doctor;
  StreamSubscription<bool>? _favoriteSubscription;
  StreamSubscription<Doctor?>? _doctorSubscription;
  StreamSubscription<List<ReviewModel>>? _reviewsSubscription;
  final TextEditingController _reviewSearchController = TextEditingController();
  String _reviewQuery = '';
  final Set<String> _selectedFilters = {'Verified', 'Latest'};
  List<ReviewModel> _reviews = const [];
  String? _currentUserId;

  Doctor get _d => _doctor;

  @override
  void initState() {
    super.initState();
    _doctor = widget.doctor;
    _favorite = widget.doctor.isFavorite;
    _currentUserId = FirebaseAuth.instance.currentUser?.uid;
    _refreshDoctorFromFirestore();
    _listenToFavoriteChanges();
    _listenToDoctorUpdates();
    _listenToReviews();
  }

  Future<void> _refreshDoctorFromFirestore() async {
    final id = _doctor.documentId;
    if (id.isEmpty) return;

    try {
      final fresh =
          await AppDependencies.instance.doctorsRepository.getDoctorById(id);
      if (!mounted || fresh == null) return;
      setState(() => _doctor = fresh);
    } catch (_) {}
  }

  void _listenToDoctorUpdates() {
    final id = _doctor.documentId;
    if (id.isEmpty) return;

    _doctorSubscription?.cancel();
    _doctorSubscription = AppDependencies.instance.doctorsRepository
        .watchDoctorById(id)
        .listen((doctor) {
      if (!mounted || doctor == null) return;
      setState(() => _doctor = doctor);
    });
  }

  void _listenToReviews() {
    final id = _doctor.documentId;
    if (id.isEmpty) return;

    _reviewsSubscription?.cancel();
    _reviewsSubscription = AppDependencies.instance.doctorsRepository
        .getDoctorReviews(id)
        .listen((reviews) {
      if (!mounted) return;
      setState(() => _reviews = reviews);
    });
  }

  void _listenToFavoriteChanges() {
    final id = _doctor.documentId;
    if (id.isEmpty) return;

    _favoriteSubscription?.cancel();
    _favoriteSubscription = AppDependencies.instance.doctorsRepository
        .watchDoctorFavorite(id)
        .listen((isFavorite) {
      if (!mounted) return;
      setState(() => _favorite = isFavorite);
    });
  }

  Future<void> _toggleFavorite() async {
    final id = _doctor.documentId;
    if (id.isEmpty || _favoriteBusy) return;

    final next = !_favorite;
    setState(() {
      _favorite = next;
      _favoriteBusy = true;
    });

    try {
      await AppDependencies.instance.doctorsRepository.toggleDoctorFavorite(
        doctorId: id,
        isFavorite: next,
      );
    } catch (_) {
      if (mounted) setState(() => _favorite = !next);
    } finally {
      if (mounted) setState(() => _favoriteBusy = false);
    }
  }

  Future<void> _openHospitalDetails() async {
    if (_hospitalNavBusy) return;

    final hospitalName = _d.hospitalName.trim();
    if (hospitalName.isEmpty) return;

    setState(() => _hospitalNavBusy = true);

    try {
      final hospital = await AppDependencies.instance.homeRepository
          .getHospitalByName(hospitalName);
      if (!mounted) return;

      if (hospital != null) {
        context.push(AppPaths.hospitalDetails, extra: hospital);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hospital information not available'),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hospital information not available'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _hospitalNavBusy = false);
    }
  }

  @override
  void dispose() {
    _favoriteSubscription?.cancel();
    _doctorSubscription?.cancel();
    _reviewsSubscription?.cancel();
    _reviewSearchController.dispose();
    super.dispose();
  }

  List<DoctorReview> get _displayReviews {
    return _reviews
        .map((review) => _toDoctorReview(review, _currentUserId))
        .toList(growable: false);
  }

  List<DoctorReview> get _filteredReviews {
    var list = List<DoctorReview>.from(_displayReviews);
    if (_selectedFilters.contains('Verified')) {
      list = list.where((r) => r.verified).toList();
    }
    if (_selectedFilters.contains('Detailed Reviews')) {
      list = list.where((r) => r.text.length >= 80).toList();
    }
    if (_reviewQuery.trim().isNotEmpty) {
      final q = _reviewQuery.trim().toLowerCase();
      list = list
          .where(
            (r) =>
                r.authorName.toLowerCase().contains(q) ||
                r.text.toLowerCase().contains(q),
          )
          .toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final aboutText = _d.about.trim();
    final aboutBody = aboutText.isEmpty
        ? 'No biography available for this doctor yet.'
        : aboutText;
    final showReadMore = aboutBody.length > _aboutPreviewLength;
    final aboutDisplay = (!_aboutExpanded && showReadMore)
        ? '${aboutBody.substring(0, _aboutPreviewLength).trim()}…'
        : aboutBody;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    _CircleHeaderIcon(
                      icon: LucideIcons.arrowLeft,
                      onTap: () => context.pop(),
                    ),
                    Expanded(
                      child: Text(
                        'Doctor Details',
                        textAlign: TextAlign.center,
                        style: textTheme.titleLarge?.copyWith(
                          color: AppColors.primaryText,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    _CircleHeaderIcon(
                      icon: LucideIcons.heart,
                      iconColor: _favorite ? Colors.red : Colors.grey,
                      iconFill: _favorite ? 1 : 0,
                      onTap: _favoriteBusy ? () {} : _toggleFavorite,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.stroke,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _d.specialty,
                              style: textTheme.bodySmall?.copyWith(
                                color: AppColors.secondaryText,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (_d.hospitalName.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(
                                  LucideIcons.building2,
                                  size: 14,
                                  color: AppColors.secondaryText,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    _d.hospitalName,
                                    style: textTheme.bodySmall?.copyWith(
                                      fontSize: 13,
                                      color: AppColors.secondaryText,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                child: Text(
                                  _d.name,
                                  style: textTheme.headlineMedium?.copyWith(
                                    color: AppColors.primaryText,
                                    fontWeight: FontWeight.w700,
                                    height: 1.15,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Icon(
                                  LucideIcons.badgeCheck,
                                  color: AppColors.primary,
                                  size: 22,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                LucideIcons.star,
                                color: Colors.amber,
                                size: 18,
                                fill: 1,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _d.rating.toStringAsFixed(1),
                                style: textTheme.titleMedium?.copyWith(
                                  color: AppColors.primaryText,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        _d.imageUrl,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, _) => Container(
                          width: 100,
                          height: 100,
                          color: AppColors.stroke,
                          child: const Icon(
                            LucideIcons.userRound,
                            size: 40,
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _StatsRow(doctor: _d),
                const SizedBox(height: 28),
                Text(
                  'About Doctor',
                  style: textTheme.titleLarge?.copyWith(
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      aboutDisplay,
                      style: textTheme.bodyLarge?.copyWith(
                        color: AppColors.secondaryText,
                        height: 1.5,
                      ),
                    ),
                    if (showReadMore) ...[
                      const SizedBox(height: 6),
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          foregroundColor: AppColors.primary,
                        ),
                        onPressed: () =>
                            setState(() => _aboutExpanded = !_aboutExpanded),
                        child: Text(
                          _aboutExpanded ? 'Read less' : 'Read more',
                          style: textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Doctor Contact',
                  style: textTheme.titleLarge?.copyWith(
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.stroke),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.neutral200,
                        backgroundImage: _d.imageUrl.trim().isNotEmpty
                            ? NetworkImage(_d.imageUrl)
                            : null,
                        child: _d.imageUrl.trim().isEmpty
                            ? const Icon(
                                LucideIcons.userRound,
                                color: AppColors.secondaryText,
                              )
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _d.name,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryText,
                              ),
                            ),
                            Text(
                              _d.specialty,
                              style: textTheme.bodySmall?.copyWith(
                                color: AppColors.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _CircleActionIcon(
                        icon: LucideIcons.messageCircle,
                        onTap: () => debugPrint('Chat tapped'),
                      ),
                      const SizedBox(width: 8),
                      _CircleActionIcon(
                        icon: LucideIcons.phone,
                        onTap: () {
                          final phone = _d.phone.trim();
                          if (phone.isEmpty) return;
                          LinkLauncher.openExternalUrl('tel:$phone');
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Working Hours',
                  style: textTheme.titleLarge?.copyWith(
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                if (_d.workingHours.isEmpty)
                  Text(
                    'Working hours not listed yet.',
                    style: textTheme.bodyLarge?.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  )
                else
                  ..._d.workingHours.map(
                    (WorkingHoursEntry e) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              e.daysLabel,
                              style: textTheme.bodyLarge?.copyWith(
                                color: AppColors.secondaryText,
                              ),
                            ),
                          ),
                          Text(
                            e.hoursLabel,
                            style: textTheme.bodyLarge?.copyWith(
                              color: AppColors.primaryText,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 14),
                Text(
                  'Address',
                  style: textTheme.titleLarge?.copyWith(
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      LucideIcons.mapPin,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _d.address.trim().isEmpty
                            ? 'Address not available'
                            : _d.address,
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.secondaryText,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
                if (_d.hospitalName.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: _hospitalNavBusy ? null : _openHospitalDetails,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const Icon(
                            LucideIcons.building2,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _d.hospitalName,
                              style: textTheme.bodySmall?.copyWith(
                                fontSize: 13,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (_hospitalNavBusy)
                            const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          else
                            const Icon(
                              LucideIcons.chevronRight,
                              size: 14,
                              color: AppColors.primary,
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Reviews',
                        style: textTheme.titleLarge?.copyWith(
                          color: AppColors.primaryText,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => context.pushNamed(
                        'leave-review-doctor',
                        extra: _d,
                      ),
                      child: Text(
                        '+ add review',
                        style: textTheme.labelLarge?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _reviewSearchController,
                  onChanged: (v) => setState(() => _reviewQuery = v),
                  decoration: InputDecoration(
                    hintText: 'Search in reviews',
                    hintStyle: textTheme.bodyMedium?.copyWith(
                      color: AppColors.secondaryText,
                    ),
                    filled: true,
                    fillColor: AppColors.stroke,
                    prefixIcon: const Icon(
                      LucideIcons.search,
                      color: AppColors.secondaryText,
                      size: 20,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 38,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _FilterChipButton(
                        label: 'Filter',
                        trailing: LucideIcons.chevronDown,
                        selected: false,
                        onTap: () => debugPrint('Filter menu'),
                      ),
                      const SizedBox(width: 8),
                      _FilterChipButton(
                        label: 'Verified',
                        selected: _selectedFilters.contains('Verified'),
                        onTap: () => setState(() {
                          if (_selectedFilters.contains('Verified')) {
                            _selectedFilters.remove('Verified');
                          } else {
                            _selectedFilters.add('Verified');
                          }
                        }),
                      ),
                      const SizedBox(width: 8),
                      _FilterChipButton(
                        label: 'Latest',
                        selected: _selectedFilters.contains('Latest'),
                        onTap: () => setState(() {
                          if (_selectedFilters.contains('Latest')) {
                            _selectedFilters.remove('Latest');
                          } else {
                            _selectedFilters.add('Latest');
                          }
                        }),
                      ),
                      const SizedBox(width: 8),
                      _FilterChipButton(
                        label: 'Detailed Reviews',
                        selected: _selectedFilters.contains('Detailed Reviews'),
                        onTap: () => setState(() {
                          if (_selectedFilters.contains('Detailed Reviews')) {
                            _selectedFilters.remove('Detailed Reviews');
                          } else {
                            _selectedFilters.add('Detailed Reviews');
                          }
                        }),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                if (_filteredReviews.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'No reviews yet',
                        style: textTheme.bodyLarge?.copyWith(
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ),
                  )
                else
                  ..._filteredReviews.map(
                    (r) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _ReviewCard(review: r),
                    ),
                  ),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Material(
        elevation: 12,
        shadowColor: Colors.black26,
        color: AppColors.white,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: () => BookingNavigation.startBooking(
                  context,
                  doctor: _d,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Book Appointment',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CircleHeaderIcon extends StatelessWidget {
  const _CircleHeaderIcon({
    required this.icon,
    required this.onTap,
    this.iconColor,
    this.iconFill = 0,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;
  final double iconFill;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      shape: const CircleBorder(),
      elevation: 1,
      shadowColor: Colors.black12,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            icon,
            size: 20,
            color: iconColor ?? AppColors.primaryText,
            fill: iconFill,
          ),
        ),
      ),
    );
  }
}

class _CircleActionIcon extends StatelessWidget {
  const _CircleActionIcon({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      shape: const CircleBorder(),
      elevation: 1,
      shadowColor: Colors.black12,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, size: 20, color: AppColors.primary),
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.doctor});

  final Doctor doctor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final stats = <({IconData icon, String value, String label})>[
      (
        icon: LucideIcons.users,
        value: _statValue(doctor.patientsCount),
        label: 'Patients',
      ),
      (
        icon: LucideIcons.briefcase,
        value: _statValue(doctor.experienceYears),
        label: 'Years Exp',
      ),
      (
        icon: LucideIcons.star,
        value: doctor.rating > 0
            ? doctor.rating.toStringAsFixed(1)
            : '—',
        label: 'Rating',
      ),
      (
        icon: LucideIcons.messageCircle,
        value: _statValue(doctor.reviewsCount),
        label: 'Reviews',
      ),
    ];

    return Row(
      children: stats
          .map(
            (s) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x12000000),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(s.icon, color: AppColors.primary, size: 20),
                        const SizedBox(height: 4),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            s.value,
                            style: textTheme.labelLarge?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            s.label,
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.secondaryText,
                              fontSize: 9,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  static String _statValue(int n) {
    if (n <= 0) return '—';
    return '${_formatThousands(n)}+';
  }

  static String _formatThousands(int n) {
    final digits = n.abs().toString();
    final buf = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        buf.write(',');
      }
      buf.write(digits[i]);
    }
    return buf.toString();
  }
}

class _FilterChipButton extends StatelessWidget {
  const _FilterChipButton({
    required this.label,
    required this.selected,
    required this.onTap,
    this.trailing,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? trailing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.stroke,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: textTheme.labelLarge?.copyWith(
                color: selected ? AppColors.white : AppColors.primaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 4),
              Icon(
                trailing,
                size: 16,
                color: selected ? AppColors.white : AppColors.primaryText,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final DoctorReview review;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(14),
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
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.neutral200,
                backgroundImage: review.avatarUrl.trim().isNotEmpty
                    ? NetworkImage(review.avatarUrl)
                    : null,
                child: review.avatarUrl.trim().isEmpty
                    ? Text(
                        _initialsFromName(review.authorName),
                        style: textTheme.labelLarge?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            review.authorName,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryText,
                            ),
                          ),
                        ),
                        if (review.verified) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            LucideIcons.badgeCheck,
                            size: 18,
                            color: AppColors.primary,
                          ),
                        ],
                      ],
                    ),
                    Text(
                      review.timeAgo,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            review.text,
            softWrap: true,
            overflow: TextOverflow.visible,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.secondaryText,
              height: 1.45,
            ),
          ),
          if (review.imageUrls.isNotEmpty) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 72,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: review.imageUrls.take(2).length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final url = review.imageUrls[index];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      url,
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 72,
                        height: 72,
                        color: AppColors.stroke,
                        alignment: Alignment.center,
                        child: const Icon(
                          LucideIcons.imageOff,
                          size: 18,
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              ...List.generate(
                5,
                (i) => Icon(
                  LucideIcons.star,
                  size: 16,
                  color: i < review.rating.round()
                      ? Colors.amber
                      : AppColors.stroke,
                  fill: i < review.rating.round() ? 1 : 0,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                review.rating.toStringAsFixed(1),
                style: textTheme.labelLarge?.copyWith(
                  color: AppColors.primaryText,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

DoctorReview _toDoctorReview(ReviewModel review, String? currentUserId) {
  final isCurrentUser =
      currentUserId != null && review.userId == currentUserId;

  return DoctorReview(
    authorName: isCurrentUser ? 'You' : review.userName,
    avatarUrl: review.userPhoto,
    verified: isCurrentUser,
    timeAgo: _formatReviewDate(review.createdAt),
    text: review.comment,
    rating: review.rating,
  );
}

String _formatReviewDate(DateTime date) {
  final now = DateTime.now();
  final difference = now.difference(date);

  if (difference.inMinutes < 1) return 'just now';
  if (difference.inHours < 24) {
    if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    }
    return '${difference.inHours}h ago';
  }
  if (difference.inDays < 7) return '${difference.inDays}d ago';
  return DateFormat('MMM d, yyyy').format(date);
}

String _initialsFromName(String name) {
  final parts =
      name.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts.first[0].toUpperCase();
  return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
}
