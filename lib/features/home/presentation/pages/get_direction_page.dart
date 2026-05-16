import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/constants/app_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../manager/get_direction_args.dart';
import '../manager/get_direction_cubit.dart';
import '../manager/get_direction_state.dart';

const double _kDirectionMapZoom = 15.5;

class GetDirectionPage extends StatefulWidget {
  const GetDirectionPage({required this.args, super.key});

  final GetDirectionArgs args;

  @override
  State<GetDirectionPage> createState() => _GetDirectionPageState();
}

class _GetDirectionPageState extends State<GetDirectionPage> {
  final MapController _mapController = MapController();

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  LatLng _toLatLng(GeoPoint point) => LatLng(point.latitude, point.longitude);

  void _centerOnDestination(GeoPoint destination) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _mapController.move(_toLatLng(destination), _kDirectionMapZoom);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.white,
      extendBodyBehindAppBar: true,
      appBar: const CustomAppBar(
        title: 'Navigate to Hospital',
        backgroundColor: Colors.transparent,
      ),
      body: BlocConsumer<GetDirectionCubit, GetDirectionState>(
        listener: (context, state) {
          if (state is GetDirectionLoaded) {
            _centerOnDestination(state.destination);
          }
        },
        builder: (context, state) {
          return switch (state) {
            GetDirectionInitial() ||
            GetDirectionLoading() =>
              const Center(child: CircularProgressIndicator()),
            GetDirectionError(:final message) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.doctorMeta,
                  ),
                ),
              ),
            GetDirectionLoaded(:final destination, :final userLocation) =>
              Stack(
                fit: StackFit.expand,
                children: [
                  _DirectionMap(
                    mapController: _mapController,
                    destination: destination,
                    userLocation: userLocation,
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: _BottomActionPanel(
                      bottomInset: bottomInset,
                      onGetDirection: () {
                        context.read<GetDirectionCubit>().startNavigation();
                        context.push(AppPaths.getDirection2, extra: widget.args);
                      },
                    ),
                  ),
                ],
              ),
          };
        },
      ),
    );
  }
}

class _DirectionMap extends StatelessWidget {
  const _DirectionMap({
    required this.mapController,
    required this.destination,
    this.userLocation,
  });

  final MapController mapController;
  final GeoPoint destination;
  final GeoPoint? userLocation;

  static const _lightMapMatrix = <double>[
    1.05, 0, 0, 0, 8,
    0, 1.05, 0, 0, 8,
    0, 0, 1.05, 0, 8,
    0, 0, 0, 1, 0,
  ];

  LatLng _point(GeoPoint p) => LatLng(p.latitude, p.longitude);

  @override
  Widget build(BuildContext context) {
    final dest = _point(destination);
    final user = userLocation != null ? _point(userLocation!) : null;

    return ColorFiltered(
      colorFilter: const ColorFilter.matrix(_lightMapMatrix),
      child: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialCenter: dest,
          initialZoom: _kDirectionMapZoom,
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
          if (user != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: user,
                  width: 16,
                  height: 16,
                  alignment: Alignment.center,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          MarkerLayer(
            markers: [
              Marker(
                point: dest,
                width: 48,
                height: 56,
                alignment: Alignment.bottomCenter,
                child: const _HospitalMapPin(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HospitalMapPin extends StatelessWidget {
  const _HospitalMapPin();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.location_on_rounded,
              size: 22,
              color: AppColors.white,
            ),
          ),
        ),
        CustomPaint(
          size: const Size(14, 10),
          painter: _PinTailPainter(),
        ),
      ],
    );
  }
}

class _PinTailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = ui.Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = AppColors.primary);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BottomActionPanel extends StatelessWidget {
  const _BottomActionPanel({
    required this.bottomInset,
    required this.onGetDirection,
  });

  final double bottomInset;
  final VoidCallback onGetDirection;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(20, 20, 20, 16 + bottomInset),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: onGetDirection,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: const Text('Get Direction', style: AppTextStyles.buttonLabel),
          ),
        ),
      ),
    );
  }
}
