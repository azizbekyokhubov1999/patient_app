import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_paths.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../models/e_receipt_args.dart';
import '../models/queue_status_args.dart';
import '../widgets/dashed_divider.dart';
import '../widgets/qr_section.dart';
import '../widgets/receipt_info_row.dart';

/// Page background per Figma e-receipt design.
const Color _kReceiptPageBackground = Color(0xFFF5F5F5);

class EReceiptPage extends StatefulWidget {
  const EReceiptPage({
    required this.args,
    super.key,
  });

  final EReceiptArgs args;

  @override
  State<EReceiptPage> createState() => _EReceiptPageState();
}

class _EReceiptPageState extends State<EReceiptPage> {
  bool _isDownloading = false;
  bool _scanSimulated = false;

  @override
  void initState() {
    super.initState();
    if (widget.args.hospitalKioskFlow) {
      _scheduleHospitalScanSimulation();
    }
  }

  void _scheduleHospitalScanSimulation() {
    Future<void>.delayed(const Duration(seconds: 2), () {
      if (!mounted || _scanSimulated) return;
      _onHospitalScanSuccess();
    });
  }

  void _onHospitalScanSuccess() {
    if (_scanSimulated) return;
    _scanSimulated = true;
    final queue = widget.args.queueStatusAfterScan ??
        QueueStatusArgs(appointmentId: widget.args.appointmentId);
    context.push(AppPaths.appointmentQueueStatus, extra: queue);
  }

  Future<void> _onDownloadPressed() async {
    if (_isDownloading) return;
    setState(() => _isDownloading = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _isDownloading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Receipt downloaded to gallery')),
    );
  }

  void _goToAppointments() {
    if (widget.args.hospitalKioskFlow) {
      _onHospitalScanSuccess();
      return;
    }
    context.go(AppPaths.booking);
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: r'$', decimalDigits: 2);
    final dateLabel = DateFormat('MMMM d, yyyy').format(widget.args.bookingDate);
    final args = widget.args;

    return Scaffold(
      backgroundColor: _kReceiptPageBackground,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: _CircleIconButton(
          icon: LucideIcons.arrowLeft,
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppPaths.booking);
            }
          },
        ),
        title: const Text('E-Receipt', style: AppTextStyles.appBarTitle),
        actions: [
          _CircleIconButton(
            icon: LucideIcons.download,
            onPressed: _isDownloading ? null : _onDownloadPressed,
            child: _isDownloading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.md,
                AppSpacing.xl,
                AppSpacing.lg,
              ),
              child: Container(
                clipBehavior: Clip.none,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 16,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                      child: QrSection(appointmentId: args.appointmentId),
                    ),
                    const SizedBox(height: 20),
                    const DashedDivider(showNotches: true),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: _ReceiptInfoGrid(
                        children: [
                          ReceiptInfoRow(label: 'Appointment ID', value: args.appointmentId),
                          ReceiptInfoRow(label: 'Patient', value: args.patientName),
                          ReceiptInfoRow(label: 'Phone', value: args.patientPhone),
                          ReceiptInfoRow(label: 'Specialist', value: args.doctorName),
                          ReceiptInfoRow(label: 'Package', value: args.packageType),
                          ReceiptInfoRow(label: 'Duration', value: args.packageDuration),
                          ReceiptInfoRow(label: 'Booking Date', value: dateLabel),
                          ReceiptInfoRow(label: 'Booking Time', value: args.bookingTime),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: DashedDivider(showNotches: false),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      child: Column(
                        children: [
                          _PaymentRow(
                            label: 'Sub Total',
                            value: currency.format(args.subTotal),
                          ),
                          const SizedBox(height: 12),
                          _PaymentRow(
                            label: 'Discount',
                            value: currency.format(args.discount),
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: DashedDivider(showNotches: false),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                      child: Row(
                        children: [
                          Text(
                            'Total Amount',
                            style: AppTextStyles.titleMedium.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            currency.format(args.totalAmount),
                            style: AppTextStyles.titleMedium.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (widget.args.hospitalKioskFlow)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.sm,
                AppSpacing.xl,
                0,
              ),
              child: Text(
                'Show this QR code to the hospital scanner. Scan will be detected automatically.',
                textAlign: TextAlign.center,
                style: AppTextStyles.doctorMeta.copyWith(
                  fontSize: 13,
                  color: AppColors.secondaryText,
                ),
              ),
            ),
          SafeArea(
            top: false,
            minimum: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.sm,
              AppSpacing.xl,
              AppSpacing.lg,
            ),
            child: SizedBox(
              height: 56,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _goToAppointments,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: Text(
                  widget.args.hospitalKioskFlow
                      ? 'Simulate Hospital Scan'
                      : 'Go to Appointments',
                  style: AppTextStyles.buttonLabel,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.onPressed,
    this.child,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Material(
        color: AppColors.white,
        shape: CircleBorder(side: BorderSide(color: AppColors.stroke)),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Center(
              child: child ??
                  Icon(
                    icon,
                    size: 20,
                    color: AppColors.primaryText,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReceiptInfoGrid extends StatelessWidget {
  const _ReceiptInfoGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 16.0;
        const runSpacing = 20.0;
        final itemWidth = (constraints.maxWidth - spacing) / 2;

        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          children: children
              .map(
                (child) => SizedBox(
                  width: itemWidth,
                  child: child,
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: AppTextStyles.doctorMeta.copyWith(
            fontSize: 16,
            color: AppColors.secondaryText,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: AppTextStyles.titleMedium.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
