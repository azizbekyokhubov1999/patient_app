import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/constants/app_paths.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../manager/get_direction_args.dart';
import '../../domain/entities/hospital.dart';
import '../manager/nearby_hospitals_cubit.dart';
import '../manager/nearby_hospitals_state.dart';
import '../models/hospital_detail_args.dart';
import '../widgets/hospital_card.dart';

class NearbyHospitalsPage extends StatefulWidget {
  const NearbyHospitalsPage({super.key});

  @override
  State<NearbyHospitalsPage> createState() => _NearbyHospitalsPageState();
}

class _NearbyHospitalsPageState extends State<NearbyHospitalsPage> {
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
    context.read<NearbyHospitalsCubit>().filterByQuery('');
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
                      onChanged: (v) =>
                          context.read<NearbyHospitalsCubit>().filterByQuery(v),
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
                'Nearby Hospitals',
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
      body: BlocBuilder<NearbyHospitalsCubit, NearbyHospitalsState>(
        builder: (context, state) {
          return switch (state) {
            NearbyHospitalsInitial() ||
            NearbyHospitalsLoading() =>
              const Center(child: CircularProgressIndicator()),
            NearbyHospitalsError(:final message) => _ErrorRecovery(
                message: message,
                onRetry: () =>
                    context.read<NearbyHospitalsCubit>().refresh(),
              ),
            LocationPermissionDenied(:final permanent) => _PermissionBody(
                permanent: permanent,
                onRetry: () =>
                    context.read<NearbyHospitalsCubit>().loadNearbyHospitals(),
              ),
            NearbyHospitalsEmpty() =>
              _EmptyNearby(onExplore: () => context.pop()),
            NearbyHospitalsLoaded(:final filteredHospitals, :final hospitals) =>
              _HospitalList(
                hospitals: hospitals,
                filteredHospitals: filteredHospitals,
              ),
          };
        },
      ),
    );
  }
}

class _HospitalList extends StatelessWidget {
  const _HospitalList({
    required this.hospitals,
    required this.filteredHospitals,
  });

  final List<Hospital> hospitals;
  final List<Hospital> filteredHospitals;

  @override
  Widget build(BuildContext context) {
    if (filteredHospitals.isEmpty && hospitals.isNotEmpty) {
      return RefreshIndicator(
        onRefresh: () => context.read<NearbyHospitalsCubit>().refresh(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl,
            vertical: AppSpacing.lg,
          ),
          children: [
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.18),
            Icon(
              LucideIcons.searchX,
              size: 48,
              color: AppColors.secondaryText.withValues(alpha: 0.45),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No hospitals match your search',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.secondaryText,
                  ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<NearbyHospitalsCubit>().refresh(),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxl,
          vertical: AppSpacing.lg,
        ),
        itemCount: filteredHospitals.length,
        separatorBuilder: (context, index) =>
            const SizedBox(height: AppSpacing.lg),
        itemBuilder: (context, index) {
          final hospital = filteredHospitals[index];
          return HospitalCard(
            hospital: hospital,
            onTap: () => context.push(
              AppPaths.hospitalDetail,
              extra: HospitalDetailArgs(
                hospitalId: hospital.id,
                hospital: hospital,
              ),
            ),
            onFavoriteToggle: () => context
                .read<NearbyHospitalsCubit>()
                .toggleFavorite(hospital.id),
            onDirectionTap: () => context.push(
              AppPaths.getDirection,
              extra: GetDirectionArgs(
                hospitalId: hospital.id,
                hospitalName: hospital.name,
                geoPoint: hospital.geoPoint,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PermissionBody extends StatelessWidget {
  const _PermissionBody({
    required this.permanent,
    required this.onRetry,
  });

  final bool permanent;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.mapPinOff,
              size: 56,
              color: AppColors.secondaryText.withValues(alpha: 0.45),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              permanent
                  ? 'Location permission is turned off. Enable it in Settings to see nearby hospitals.'
                  : 'Location permission is required to find hospitals near you.',
              textAlign: TextAlign.center,
              style: theme.bodyLarge?.copyWith(color: AppColors.secondaryText),
            ),
            const SizedBox(height: AppSpacing.xxl),
            if (permanent)
              FilledButton(
                onPressed: openAppSettings,
                child: const Text('Open settings'),
              )
            else
              FilledButton(
                onPressed: onRetry,
                child: const Text('Try again'),
              ),
          ],
        ),
      ),
    );
  }
}

class _ErrorRecovery extends StatelessWidget {
  const _ErrorRecovery({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.cloudOff,
              size: 56,
              color: AppColors.secondaryText.withValues(alpha: 0.45),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.bodyMedium?.copyWith(color: AppColors.secondaryText),
            ),
            const SizedBox(height: AppSpacing.xxl),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyNearby extends StatelessWidget {
  const _EmptyNearby({required this.onExplore});

  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.building2,
              size: 64,
              color: AppColors.secondaryText.withValues(alpha: 0.45),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No hospitals found nearby',
              textAlign: TextAlign.center,
              style: theme.titleMedium?.copyWith(
                color: AppColors.primaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            OutlinedButton(
              onPressed: onExplore,
              child: const Text('Go back'),
            ),
          ],
        ),
      ),
    );
  }
}
