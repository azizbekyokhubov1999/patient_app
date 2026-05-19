import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../data/models/doctor_model.dart';
import '../../data/models/hospital_model.dart';
import '../manager/favourites_cubit.dart';
import '../manager/favourites_state.dart';
import '../widgets/favourite_doctors_view.dart';
import '../widgets/favourite_hospitals_view.dart';

class MyFavouritesPage extends StatefulWidget {
  const MyFavouritesPage({super.key});

  @override
  State<MyFavouritesPage> createState() => _MyFavouritesPageState();
}

class _MyFavouritesPageState extends State<MyFavouritesPage> {
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      if (_isSearching) {
        _isSearching = false;
        _searchController.clear();
      } else {
        _isSearching = true;
      }
    });
  }

  List<DoctorModel> _filterDoctors(List<DoctorModel> doctors, String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return doctors;
    return doctors
        .where(
          (d) =>
              d.name.toLowerCase().contains(q) ||
              d.specialty.toLowerCase().contains(q),
        )
        .toList();
  }

  List<HospitalModel> _filterHospitals(
    List<HospitalModel> hospitals,
    String query,
  ) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return hospitals;
    return hospitals
        .where(
          (h) =>
              h.name.toLowerCase().contains(q) ||
              h.tags.toLowerCase().contains(q) ||
              h.specialties.any((s) => s.toLowerCase().contains(q)),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _isSearching
            ? AppBar(
                backgroundColor: AppColors.white,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: _toggleSearch,
                ),
                title: TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Search favourites...',
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                actions: [
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                    ),
                ],
              )
            : CustomAppBar(
                title: 'My Favourites',
                backgroundColor: AppColors.white,
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: CustomAppBarSearchButton(onTap: _toggleSearch),
                  ),
                ],
              ),
        body: BlocBuilder<FavouritesCubit, FavouritesState>(
          builder: (context, state) {
            return switch (state) {
              FavouritesInitial() || FavouritesLoading() => const Center(
                  child: CircularProgressIndicator(),
                ),
              FavouritesError(:final message) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xxl),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(message, textAlign: TextAlign.center),
                        const SizedBox(height: AppSpacing.lg),
                        FilledButton(
                          onPressed: () =>
                              context.read<FavouritesCubit>().loadFavourites(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              FavouritesLoaded(
                :final favoriteDoctors,
                :final favoriteHospitals,
              ) =>
                Column(
                  children: [
                    Material(
                      color: AppColors.white,
                      child: TabBar(
                        labelColor: AppColors.primary,
                        unselectedLabelColor: AppColors.secondaryText,
                        indicatorColor: AppColors.primary,
                        indicatorWeight: 3,
                        labelStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                        unselectedLabelStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                        tabs: const [
                          Tab(text: 'Doctors'),
                          Tab(text: 'Hospitals'),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          FavouriteDoctorsView(
                            doctors: _filterDoctors(
                              favoriteDoctors,
                              _searchController.text,
                            ),
                          ),
                          FavouriteHospitalsView(
                            hospitals: _filterHospitals(
                              favoriteHospitals,
                              _searchController.text,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            };
          },
        ),
      ),
    );
  }
}
