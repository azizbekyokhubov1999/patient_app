import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_paths.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../models/e_receipt_args.dart';

class BookingSuccessPage extends StatefulWidget {
  const BookingSuccessPage({
    required this.doctorName,
    required this.receipt,
    super.key,
  });

  final String doctorName;
  final EReceiptArgs receipt;

  @override
  State<BookingSuccessPage> createState() => _BookingSuccessPageState();
}

class _BookingSuccessPageState extends State<BookingSuccessPage> {
  bool _showIcon = false;
  bool _showText = false;

  @override
  void initState() {
    super.initState();
    HapticFeedback.mediumImpact();
    Future<void>.delayed(const Duration(milliseconds: 80), () {
      if (!mounted) return;
      setState(() => _showIcon = true);
    });
    Future<void>.delayed(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      setState(() => _showText = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md, AppSpacing.xl, 0),
              child: Row(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () => context.pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.stroke),
                      ),
                      child: const Icon(
                        LucideIcons.arrowLeft,
                        color: AppColors.primaryText,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedOpacity(
                        opacity: _showIcon ? 1 : 0,
                        duration: const Duration(milliseconds: 320),
                        child: AnimatedSlide(
                          offset: _showIcon ? Offset.zero : const Offset(0, 0.08),
                          duration: const Duration(milliseconds: 320),
                          child: const Icon(
                            LucideIcons.badgeCheck,
                            color: AppColors.primary,
                            size: 120,
                            fill: 1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      AnimatedOpacity(
                        opacity: _showText ? 1 : 0,
                        duration: const Duration(milliseconds: 320),
                        child: Text(
                          'Payment Successful!',
                          style: AppTextStyles.sectionTitle.copyWith(fontSize: 42 / 2),
                        ),
                      ),
                      const SizedBox(height: 10),
                      AnimatedOpacity(
                        opacity: _showText ? 1 : 0,
                        duration: const Duration(milliseconds: 320),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            text: 'You have successfully booked appointment with\n',
                            style: AppTextStyles.doctorMeta.copyWith(fontSize: 16),
                            children: [
                              TextSpan(
                                text: widget.doctorName,
                                style: AppTextStyles.titleMedium.copyWith(
                                  color: AppColors.warning,
                                  fontSize: 32 / 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 14,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.md),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: () => context.push(AppPaths.eReceipt, extra: widget.receipt),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(27),
                            ),
                          ),
                          child: const Text('View E-Receipt', style: AppTextStyles.buttonLabel),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => context.go(AppPaths.booking),
                        child: Text(
                          'View Appointments',
                          style: AppTextStyles.titleMedium.copyWith(
                            fontSize: 18,
                            color: AppColors.warning,
                          ),
                        ),
                      ),
                    ],
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
