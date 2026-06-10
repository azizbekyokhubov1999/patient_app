import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_paths.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../manager/top_specialist_cubit.dart';
import '../manager/top_specialist_state.dart';
import '../widgets/specialist_grid_card.dart';

class TopSpecialistPage extends StatefulWidget {
  const TopSpecialistPage({
    this.initialSpecialty,
    super.key,
  });

  final String? initialSpecialty;

  @override
  State<TopSpecialistPage> createState() => _TopSpecialistPageState();
}

class _TopSpecialistPageState extends State<TopSpecialistPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _closeSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
    });
    context.read<TopSpecialistCubit>().clearFilter();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
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
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  border: InputBorder.none,
                  isDense: true,
                ),
                style: theme.titleMedium?.copyWith(
                  color: AppColors.primaryText,
                ),
                onChanged: (v) =>
                    context.read<TopSpecialistCubit>().filterByQuery(v),
              )
            : Text(
                'Specialists',
                style: theme.titleMedium?.copyWith(
                  color: const Color(0xFF1A1A2E),
                  fontWeight: FontWeight.w700,
                ),
              ),
        centerTitle: !_isSearching,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: () {
                if (_isSearching) {
                  _closeSearch();
                } else {
                  setState(() => _isSearching = true);
                }
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.stroke),
                  color: AppColors.white,
                ),
                child: Icon(
                  _isSearching ? LucideIcons.x : LucideIcons.search,
                  size: 20,
                  color: AppColors.primaryText,
                ),
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<TopSpecialistCubit, TopSpecialistState>(
        builder: (context, state) {
          if (state is TopSpecialistInitial || state is TopSpecialistLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is TopSpecialistError) {
            return _ErrorState(
              message: state.message,
              onRetry: () =>
                  context.read<TopSpecialistCubit>().refresh(),
            );
          }
          if (state is TopSpecialistEmpty) {
            return _EmptyState();
          }
          if (state is TopSpecialistLoaded) {
            final list = state.filteredDoctors;
            if (list.isEmpty && state.doctors.isNotEmpty) {
              return RefreshIndicator(
                onRefresh: () => context.read<TopSpecialistCubit>().refresh(),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  children: [
                    SizedBox(height: MediaQuery.sizeOf(context).height * 0.2),
                    Icon(
                      LucideIcons.searchX,
                      size: 48,
                      color:
                          AppColors.secondaryText.withValues(alpha: 0.45),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'No specialists match your search',
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
              onRefresh: () => context.read<TopSpecialistCubit>().refresh(),
              child: GridView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.72,
                ),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final doctor = list[index];
                  return SpecialistGridCard(
                    doctor: doctor,
                    onTap: () => context.push(
                      AppPaths.doctorDetail,
                      extra: doctor,
                    ),
                    onFavoriteToggle: doctor.documentId.isEmpty
                        ? null
                        : () => context
                            .read<TopSpecialistCubit>()
                            .toggleDoctorFavorite(doctor.documentId),
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

class _EmptyState extends StatelessWidget {
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
              LucideIcons.stethoscope,
              size: 64,
              color: AppColors.secondaryText.withValues(alpha: 0.45),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No specialists found',
              textAlign: TextAlign.center,
              style: theme.titleMedium?.copyWith(
                color: AppColors.secondaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
