import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_paths.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/doctor.dart';
import '../../domain/entities/hospital.dart';
import '../manager/search_cubit.dart';
import '../manager/search_state.dart';
import '../widgets/recent_hospital_card.dart';
import '../widgets/recent_search_chips.dart';
import '../widgets/recent_specialist_card.dart';

const Color _kSearchFieldBackground = Color(0xFFF5F5F5);

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late final TextEditingController _queryController;

  @override
  void initState() {
    super.initState();
    _queryController = TextEditingController();
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SearchCubit()..loadRecentData(),
      child: BlocListener<SearchCubit, SearchState>(
        listenWhen: (previous, current) => previous.query != current.query,
        listener: (context, state) {
          if (_queryController.text != state.query) {
            _queryController.value = TextEditingValue(
              text: state.query,
              selection: TextSelection.collapsed(offset: state.query.length),
            );
          }
        },
        child: BlocBuilder<SearchCubit, SearchState>(
          builder: (context, state) {
            return Scaffold(
              backgroundColor: AppColors.white,
              appBar: _SearchAppBar(
                controller: _queryController,
                query: state.query,
                onQueryChanged: context.read<SearchCubit>().onQueryChanged,
                onClear: context.read<SearchCubit>().clearQuery,
                onBack: () => context.pop(),
              ),
              body: state.isLoading && !state.isInitialized
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : _SearchBody(state: state),
            );
          },
        ),
      ),
    );
  }
}

class _SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _SearchAppBar({
    required this.controller,
    required this.query,
    required this.onQueryChanged,
    required this.onClear,
    required this.onBack,
  });

  final TextEditingController controller;
  final String query;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onClear;
  final VoidCallback onBack;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: IconButton(
          style: IconButton.styleFrom(
            shape: const CircleBorder(),
            side: const BorderSide(color: AppColors.stroke),
          ),
          onPressed: onBack,
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.primaryText, size: 20),
        ),
      ),
      titleSpacing: 0,
      title: Container(
        height: 44,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: _kSearchFieldBackground,
          borderRadius: BorderRadius.circular(24),
        ),
        child: TextField(
          controller: controller,
          autofocus: true,
          onChanged: onQueryChanged,
          style: AppTextStyles.doctorMeta.copyWith(
            color: AppColors.primaryText,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: 'Search..',
            hintStyle: AppTextStyles.doctorMeta.copyWith(fontSize: 16),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            prefixIcon: const Icon(
              LucideIcons.search,
              size: 20,
              color: AppColors.secondaryText,
            ),
            suffixIcon: query.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      controller.clear();
                      onClear();
                    },
                    icon: const Icon(
                      LucideIcons.circleX,
                      size: 20,
                      color: AppColors.secondaryText,
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}

class _SearchBody extends StatelessWidget {
  const _SearchBody({required this.state});

  final SearchState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SearchCubit>();

    if (state.isSearching) {
      if (state.isLoading) {
        return const Center(child: CircularProgressIndicator(color: AppColors.primary));
      }
      if (state.hasNoSearchResults) {
        return Center(
          child: Text(
            'No results found',
            style: AppTextStyles.doctorMeta.copyWith(fontSize: 16),
          ),
        );
      }
      return _SearchResultsList(
        doctors: state.searchedDoctors,
        hospitals: state.searchedHospitals,
        onDoctorTap: (doctor) async {
          await cubit.onDoctorTapped(doctor);
          if (context.mounted) {
            context.push(AppPaths.doctorDetails, extra: doctor);
          }
        },
        onHospitalTap: (hospital) async {
          await cubit.onHospitalTapped(hospital);
          if (context.mounted) {
            context.push(AppPaths.hospitalDetails, extra: hospital);
          }
        },
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RecentSearchChips(
            keywords: state.recentKeywords,
            onKeywordTap: cubit.onKeywordTapped,
            onRemoveKeyword: cubit.removeKeyword,
            onClearAll: cubit.clearAllKeywords,
          ),
          if (state.recentKeywords.isNotEmpty) const SizedBox(height: AppSpacing.xxl),
          _SectionHeader(
            title: 'Recently Searched Specialist',
            onViewAll: () {},
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 190,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: state.recentDoctors.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final doctor = state.recentDoctors[index];
                return RecentSpecialistCard(
                  doctor: doctor,
                  onTap: () async {
                    await cubit.onDoctorTapped(doctor);
                    if (context.mounted) {
                      context.push(AppPaths.doctorDetails, extra: doctor);
                    }
                  },
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          _SectionHeader(
            title: 'Recently Searched Hospitals',
            onViewAll: () {},
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.recentHospitals.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final hospital = state.recentHospitals[index];
              return RecentHospitalCard(
                hospital: hospital,
                onTap: () async {
                  await cubit.onHospitalTapped(hospital);
                  if (context.mounted) {
                    context.push(AppPaths.hospitalDetails, extra: hospital);
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.onViewAll,
  });

  final String title;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.titleMedium.copyWith(fontSize: 18),
          ),
        ),
        TextButton(
          onPressed: onViewAll,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.warning,
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text('View All'),
        ),
      ],
    );
  }
}

class _SearchResultsList extends StatelessWidget {
  const _SearchResultsList({
    required this.doctors,
    required this.hospitals,
    required this.onDoctorTap,
    required this.onHospitalTap,
  });

  final List<Doctor> doctors;
  final List<Hospital> hospitals;
  final ValueChanged<Doctor> onDoctorTap;
  final ValueChanged<Hospital> onHospitalTap;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.xxl),
      children: [
        if (doctors.isNotEmpty) ...[
          Text('Doctors', style: AppTextStyles.titleMedium.copyWith(fontSize: 18)),
          const SizedBox(height: 12),
          ...doctors.map(
            (doctor) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: RecentSpecialistCard(
                doctor: doctor,
                width: double.infinity,
                onTap: () => onDoctorTap(doctor),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
        if (hospitals.isNotEmpty) ...[
          Text('Hospitals', style: AppTextStyles.titleMedium.copyWith(fontSize: 18)),
          const SizedBox(height: 12),
          ...hospitals.map(
            (hospital) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: RecentHospitalCard(
                hospital: hospital,
                onTap: () => onHospitalTap(hospital),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
