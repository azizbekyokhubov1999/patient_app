import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class EReceiptPage extends StatelessWidget {
  const EReceiptPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.primaryText),
        ),
        centerTitle: true,
        title: const Text('E-Receipt', style: AppTextStyles.appBarTitle),
      ),
      body: Center(
        child: Text(
          'E-Receipt preview coming next.',
          style: AppTextStyles.doctorMeta.copyWith(fontSize: 16),
        ),
      ),
    );
  }
}
