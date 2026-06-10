import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/datasources/explore_remote_data_source.dart';
import '../../data/repositories/explore_repository_impl.dart';
import '../../../home/domain/entities/hospital.dart';
import '../manager/explore_cubit.dart';
import '../manager/explore_state.dart';

const double _kExploreMapZoom = 13.8;

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ExploreCubit(ExploreRepositoryImpl(ExploreRemoteDataSourceImpl()))
            ..load(),
      child: const _ExploreScaffold(),
    );
  }
}

class _ExploreScaffold extends StatefulWidget {
  const _ExploreScaffold();

  @override
  State<_ExploreScaffold> createState() => _ExploreScaffoldState();
}

class _ExploreScaffoldState extends State<_ExploreScaffold> {
  final MapController _mapController = MapController();
  late final PageController _pageController;
  bool _didInitialFit = false;
  bool _mapReady = false;
  Hospital? _pendingHospitalMove;
  ExploreState? _pendingFitState;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.86, initialPage: 0);
  }

  @override
  void dispose() {
    _mapController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _fitMapToAll(ExploreState state) {
    if (state.hospitals.isEmpty) return;
    if (!_mapReady) {
      _pendingFitState = state;
      return;
    }
    final points = <LatLng>[
      LatLng(state.userLatitude, state.userLongitude),
      ...state.hospitals.map((h) => LatLng(h.latitude, h.longitude)),
    ];
    final bounds = LatLngBounds.fromPoints(points);
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.only(
          left: 36,
          right: 36,
          top: 100,
          bottom: 200,
        ),
        maxZoom: 15,
      ),
    );
  }

  void _onMapReady() {
    if (!mounted) return;
    setState(() => _mapReady = true);

    if (_pendingFitState != null) {
      final state = _pendingFitState!;
      _pendingFitState = null;
      if (!_didInitialFit && state.hospitals.isNotEmpty) {
        _didInitialFit = true;
        _fitMapToAll(state);
      }
    }

    if (_pendingHospitalMove != null) {
      final hospital = _pendingHospitalMove!;
      _pendingHospitalMove = null;
      _animateMapToHospital(hospital);
    }
  }

  void _animateMapToHospital(Hospital h) {
    if (!_mapReady) {
      _pendingHospitalMove = h;
      return;
    }
    _mapController.move(
      LatLng(h.latitude, h.longitude),
      _mapController.camera.zoom.clamp(12.0, 16.0),
    );
  }

  void _recenterOnUser(ExploreState state) {
    if (!_mapReady) return;
    _mapController.move(
      LatLng(state.userLatitude, state.userLongitude),
      _kExploreMapZoom,
    );
  }

  void _onHospitalMarkerTap(int index) {
    final cubit = context.read<ExploreCubit>();
    final s = cubit.state;
    if (index < 0 || index >= s.hospitals.length) return;

    cubit.selectHospital(index);
    if (!_pageController.hasClients) {
      _animateMapToHospital(s.hospitals[index]);
      return;
    }
    final current = _pageController.page?.round() ?? 0;
    if (current == index) {
      _animateMapToHospital(s.hospitals[index]);
    } else {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.paddingOf(context).top;

    return BlocConsumer<ExploreCubit, ExploreState>(
      listenWhen: (prev, curr) =>
          prev.hospitals.length != curr.hospitals.length ||
          prev.searchQuery != curr.searchQuery,
      listener: (context, state) {
        if (state.hospitals.isNotEmpty && !_didInitialFit) {
          _fitMapToAll(state);
          if (_mapReady) {
            _didInitialFit = true;
          }
        }
        if (_pageController.hasClients && state.hospitals.isNotEmpty) {
          final index = state.selectedHospitalIndex.clamp(
            0,
            state.hospitals.length - 1,
          );
          if ((_pageController.page?.round() ?? 0) != index) {
            _pageController.jumpToPage(index);
          }
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.lightScaffoldBackground,
          body: Stack(
            fit: StackFit.expand,
            children: [
              _ExploreMap(
                mapController: _mapController,
                state: state,
                onHospitalMarkerTap: _onHospitalMarkerTap,
                onMapReady: _onMapReady,
              ),
              Positioned(
                left: 20,
                right: 20,
                top: topPad + 12,
                child: _ExploreSearchBar(
                  onQueryChanged:
                      context.read<ExploreCubit>().filterByQuery,
                ),
              ),
              Positioned(
                right: 20,
                bottom: 186,
                child: _LocateFab(onPressed: () => _recenterOnUser(state)),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _HospitalCarousel(
                      pageController: _pageController,
                      hospitals: state.hospitals,
                      onPageChanged: (i) {
                        context.read<ExploreCubit>().selectHospital(i);
                        _animateMapToHospital(state.hospitals[i]);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ExploreMap extends StatelessWidget {
  const _ExploreMap({
    required this.mapController,
    required this.state,
    required this.onHospitalMarkerTap,
    required this.onMapReady,
  });

  final MapController mapController;
  final ExploreState state;
  final ValueChanged<int> onHospitalMarkerTap;
  final VoidCallback onMapReady;

  @override
  Widget build(BuildContext context) {
    final userPoint = LatLng(state.userLatitude, state.userLongitude);

    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: userPoint,
        initialZoom: _kExploreMapZoom,
        minZoom: 3,
        maxZoom: 18,
        onMapReady: onMapReady,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'patient_app',
        ),
        MarkerLayer(
          markers: [
            for (var i = 0; i < state.hospitals.length; i++)
              Marker(
                key: ValueKey(state.hospitals[i].id),
                point: LatLng(
                  state.hospitals[i].latitude,
                  state.hospitals[i].longitude,
                ),
                width: 42,
                height: 42,
                alignment: Alignment.center,
                child: _HospitalMapMarker(
                  selected: i == state.selectedHospitalIndex,
                  onTap: () => onHospitalMarkerTap(i),
                ),
              ),
            Marker(
              point: userPoint,
              width: 20,
              height: 20,
              alignment: Alignment.center,
              rotate: true,
              child: const _UserLocationMarker(),
            ),
          ],
        ),
      ],
    );
  }
}

class _HospitalMapMarker extends StatelessWidget {
  const _HospitalMapMarker({
    required this.selected,
    required this.onTap,
  });

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.neutral200,
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.primary,
            width: selected ? 2.5 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryText.withValues(alpha: 0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserLocationMarker extends StatelessWidget {
  const _UserLocationMarker();

  static const double _radius = 8.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _radius * 2,
      height: _radius * 2,
      decoration: BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );
  }
}

class _ExploreSearchBar extends StatelessWidget {
  const _ExploreSearchBar({required this.onQueryChanged});

  final ValueChanged<String> onQueryChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 6,
      shadowColor: AppColors.primaryText.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(14),
      color: AppColors.white,
      child: TextField(
        onChanged: onQueryChanged,
        decoration: InputDecoration(
          hintText: 'Search Doctor or Hospital',
          hintStyle: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.secondaryText),
          prefixIcon: const Icon(
            LucideIcons.search,
            color: AppColors.secondaryText,
            size: 22,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

class _LocateFab extends StatelessWidget {
  const _LocateFab({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 5,
      shadowColor: AppColors.primaryText.withValues(alpha: 0.1),
      shape: const CircleBorder(),
      color: AppColors.white,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: const Padding(
          padding: EdgeInsets.all(12),
          child: Icon(
            LucideIcons.locateFixed,
            color: AppColors.primary,
            size: 22,
          ),
        ),
      ),
    );
  }
}

class _HospitalCarousel extends StatelessWidget {
  const _HospitalCarousel({
    required this.pageController,
    required this.hospitals,
    required this.onPageChanged,
  });

  final PageController pageController;
  final List<Hospital> hospitals;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    if (hospitals.isEmpty) {
      return const SizedBox(height: 168);
    }

    return SizedBox(
      height: 168,
      child: PageView.builder(
        controller: pageController,
        itemCount: hospitals.length,
        onPageChanged: onPageChanged,
        padEnds: false,
        itemBuilder: (context, index) {
          final h = hospitals[index];
          return Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 20 : 8,
              right: index == hospitals.length - 1 ? 20 : 8,
            ),
            child: _HospitalExploreCard(hospital: h),
          );
        },
      ),
    );
  }
}

class _HospitalExploreCard extends StatefulWidget {
  const _HospitalExploreCard({required this.hospital});

  final Hospital hospital;

  @override
  State<_HospitalExploreCard> createState() => _HospitalExploreCardState();
}

class _HospitalExploreCardState extends State<_HospitalExploreCard> {
  bool _favorite = false;

  @override
  Widget build(BuildContext context) {
    final h = widget.hospital;
    return Material(
      elevation: 8,
      shadowColor: AppColors.primaryText.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(16),
      color: AppColors.white,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(AppPaths.hospitalDetails, extra: h),
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 88,
                  child: Image.network(
                    h.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, _) =>
                        const ColoredBox(color: AppColors.neutral200),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                h.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(
                                      color: AppColors.primaryText,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  LucideIcons.star,
                                  size: 16,
                                  color: Colors.amber,
                                  fill: 1,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  h.rating.toStringAsFixed(1),
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primaryText,
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          h.tags,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.secondaryText),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              LucideIcons.mapPin,
                              size: 14,
                              color: AppColors.secondaryText,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                h.address,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: AppColors.secondaryText,
                                      height: 1.25,
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
            Positioned(
              top: 8,
              right: 8,
              child: Material(
                color: AppColors.white,
                shape: const CircleBorder(),
                elevation: 2,
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
            ),
          ],
        ),
      ),
    );
  }
}
