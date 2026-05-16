import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../manager/get_direction_2_cubit.dart';
import '../manager/get_direction_2_state.dart';
import '../manager/get_direction_args.dart';
import '../manager/get_direction_route_helper.dart';

const double _kRouteMapZoom = 15.0;

class GetDirection2Page extends StatefulWidget {
  const GetDirection2Page({required this.args, super.key});

  final GetDirectionArgs args;

  @override
  State<GetDirection2Page> createState() => _GetDirection2PageState();
}

class _GetDirection2PageState extends State<GetDirection2Page> {
  final MapController _mapController = MapController();

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  LatLng _latLng(GeoPoint p) => LatLng(p.latitude, p.longitude);

  void _fitRoute(List<LatLng> points) {
    if (points.length < 2) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final bounds = LatLngBounds.fromPoints(points);
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.fromLTRB(48, 120, 48, 220),
        ),
      );
    });
  }

  void _centerOnUser(GeoPoint user, {double zoom = _kRouteMapZoom}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _mapController.move(_latLng(user), zoom);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return BlocConsumer<GetDirection2Cubit, GetDirection2State>(
      listenWhen: (previous, current) => current is GetDirection2Arrived,
      listener: (context, state) {
        if (state is GetDirection2Arrived) {
          context.push(AppPaths.youHaveArrived, extra: state.args);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.white,
          extendBodyBehindAppBar: true,
          appBar: const CustomAppBar(
            title: 'Navigate to Hospital',
            backgroundColor: Colors.transparent,
          ),
          body: switch (state) {
            GetDirection2Initial() ||
            GetDirection2Loading() =>
              const Center(child: CircularProgressIndicator()),
            GetDirection2Error(:final message) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.doctorMeta,
                  ),
                ),
              ),
            GetDirection2Arrived() => const Center(
                child: CircularProgressIndicator(),
              ),
            GetDirection2Loaded loaded => _LoadedBody(
                mapController: _mapController,
                loaded: loaded,
                bottomInset: bottomInset,
                onFitRoute: () => _fitRoute(loaded.routePoints),
                onCenterUser: () => _centerOnUser(loaded.userLocation),
                onStart: () =>
                    context.read<GetDirection2Cubit>().startNavigation(),
                onArrived: () =>
                    context.read<GetDirection2Cubit>().confirmArrival(),
              ),
          },
        );
      },
    );
  }
}

class _LoadedBody extends StatefulWidget {
  const _LoadedBody({
    required this.mapController,
    required this.loaded,
    required this.bottomInset,
    required this.onFitRoute,
    required this.onCenterUser,
    required this.onStart,
    required this.onArrived,
  });

  final MapController mapController;
  final GetDirection2Loaded loaded;
  final double bottomInset;
  final VoidCallback onFitRoute;
  final VoidCallback onCenterUser;
  final VoidCallback onStart;
  final VoidCallback onArrived;

  @override
  State<_LoadedBody> createState() => _LoadedBodyState();
}

class _LoadedBodyState extends State<_LoadedBody> {
  @override
  void initState() {
    super.initState();
    widget.onFitRoute();
  }

  @override
  void didUpdateWidget(covariant _LoadedBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    final userMoved = oldWidget.loaded.userLocation.latitude !=
            widget.loaded.userLocation.latitude ||
        oldWidget.loaded.userLocation.longitude !=
            widget.loaded.userLocation.longitude;

    if (widget.loaded.isNavigating &&
        (!oldWidget.loaded.isNavigating || userMoved)) {
      widget.onCenterUser();
    }
  }

  @override
  Widget build(BuildContext context) {
    final loaded = widget.loaded;

    return Stack(
      fit: StackFit.expand,
      children: [
        _RouteMap(
          mapController: widget.mapController,
          loaded: loaded,
        ),
        Positioned(
          right: 16,
          bottom: 200 + widget.bottomInset,
          child: Material(
            color: AppColors.white,
            shape: const CircleBorder(),
            elevation: 3,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: widget.onCenterUser,
              child: const SizedBox(
                width: 44,
                height: 44,
                child: Icon(
                  Icons.my_location_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 108 + widget.bottomInset,
          child: _HospitalInfoCard(loaded: loaded),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _BottomActions(
            bottomInset: widget.bottomInset,
            isNavigating: loaded.isNavigating,
            onStart: widget.onStart,
            onArrived: widget.onArrived,
          ),
        ),
      ],
    );
  }
}

class _RouteMap extends StatelessWidget {
  const _RouteMap({
    required this.mapController,
    required this.loaded,
  });

  final MapController mapController;
  final GetDirection2Loaded loaded;

  static const _lightMapMatrix = <double>[
    1.05, 0, 0, 0, 8,
    0, 1.05, 0, 0, 8,
    0, 0, 1.05, 0, 8,
    0, 0, 0, 1, 0,
  ];

  @override
  Widget build(BuildContext context) {
    final dest = geoToLatLng(loaded.destination);
    final user = geoToLatLng(loaded.userLocation);
    final headingRadians = (loaded.userHeadingDegrees ?? 0) * math.pi / 180;

    return ColorFiltered(
      colorFilter: const ColorFilter.matrix(_lightMapMatrix),
      child: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialCenter: user,
          initialZoom: _kRouteMapZoom,
          minZoom: 3,
          maxZoom: 18,
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.all,
          ),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'patient_app',
          ),
          PolylineLayer(
            polylines: [
              Polyline(
                points: loaded.routePoints,
                color: AppColors.primary,
                strokeWidth: 5,
                borderColor: AppColors.white,
                borderStrokeWidth: 1.5,
              ),
            ],
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: user,
                width: 56,
                height: 56,
                alignment: Alignment.center,
                child: _UserNavigationMarker(
                  headingRadians: headingRadians,
                  isNavigating: loaded.isNavigating,
                ),
              ),
              Marker(
                point: dest,
                width: 48,
                height: 56,
                alignment: Alignment.bottomCenter,
                child: const _HospitalDestinationPin(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UserNavigationMarker extends StatelessWidget {
  const _UserNavigationMarker({
    required this.headingRadians,
    required this.isNavigating,
  });

  final double headingRadians;
  final bool isNavigating;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withValues(alpha: 0.18),
          ),
        ),
        Transform.rotate(
          angle: isNavigating ? headingRadians : 0,
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.navigation_rounded,
              color: AppColors.white,
              size: 18,
            ),
          ),
        ),
      ],
    );
  }
}

class _HospitalDestinationPin extends StatelessWidget {
  const _HospitalDestinationPin();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.neutral200,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.white, width: 3),
          ),
          child: Center(
            child: Container(
              width: 14,
              height: 14,
              decoration: const BoxDecoration(
                color: AppColors.neutral500,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        CustomPaint(
          size: const Size(12, 8),
          painter: _PinTailPainter(color: AppColors.neutral400),
        ),
      ],
    );
  }
}

class _PinTailPainter extends CustomPainter {
  const _PinTailPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = ui.Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _PinTailPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _HospitalInfoCard extends StatelessWidget {
  const _HospitalInfoCard({required this.loaded});

  final GetDirection2Loaded loaded;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 6,
      shadowColor: Colors.black.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(16),
      color: AppColors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppColors.neutral200,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.mapPin,
                size: 20,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loaded.args.hospitalName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.titleMedium.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    loaded.hospitalAddress,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.doctorMeta.copyWith(fontSize: 13),
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

class _BottomActions extends StatelessWidget {
  const _BottomActions({
    required this.bottomInset,
    required this.isNavigating,
    required this.onStart,
    required this.onArrived,
  });

  final double bottomInset;
  final bool isNavigating;
  final VoidCallback onStart;
  final VoidCallback onArrived;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, 12 + bottomInset),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: isNavigating ? null : onStart,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor:
                      AppColors.primary.withValues(alpha: 0.55),
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  isNavigating ? 'Navigating…' : 'Start',
                  style: AppTextStyles.buttonLabel,
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onArrived,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'I have arrived',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontSize: 16,
                    color: AppColors.primary,
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
