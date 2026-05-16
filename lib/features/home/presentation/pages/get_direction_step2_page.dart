import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../manager/get_direction_args.dart';

/// Placeholder for turn-by-turn / route preview (step 2).
class GetDirectionStep2Page extends StatelessWidget {
  const GetDirectionStep2Page({this.args, super.key});

  final GetDirectionArgs? args;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const CustomAppBar(
        title: 'Directions',
        backgroundColor: AppColors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            args != null
                ? 'Route to ${args!.hospitalName} — coming in the next step.'
                : 'Route preview — coming soon.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
