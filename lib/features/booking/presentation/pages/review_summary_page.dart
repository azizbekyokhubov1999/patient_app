import 'package:flutter/scheduler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_paths.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../home/domain/entities/doctor.dart';
import '../../data/datasources/booking_remote_data_source.dart';
import '../../data/repositories/booking_repository_impl.dart';
import '../../domain/entities/package_type.dart';
import '../../domain/entities/patient_info.dart';
import '../../domain/entities/payment_method_type.dart';
import '../bloc/booking_bloc.dart';
import '../bloc/booking_event.dart';
import '../bloc/booking_state.dart';
import '../models/booking_route_args.dart';
import '../models/e_receipt_mapper.dart';
import '../utils/booking_navigation.dart';

void _popOrExitBooking(BuildContext context) {
  if (context.canPop()) {
    context.pop();
  } else {
    BookingNavigation.openAppointmentsTab(context);
  }
}

/// Merged view data from [BookingState] plus route [ReviewSummaryArgs].
/// Args always carries required booking fields; the bloc may transiently omit them.
class _OverviewSnapshot {
  const _OverviewSnapshot({
    required this.package,
    required this.selectedTimeDisplay,
    required this.dateLabel,
    required this.patient,
    required this.paymentMethod,
    required this.walletBalance,
    required this.confirmTimeOk,
  });

  final PackageType package;
  final String selectedTimeDisplay;
  final String dateLabel;
  final PatientInfo patient;
  final PaymentMethodType paymentMethod;
  final double walletBalance;

  /// Matches [BookingBloc] confirm checks (time must not be blank on merged data).
  final bool confirmTimeOk;

  bool get hasRequiredForConfirm => confirmTimeOk;
}

_OverviewSnapshot _buildSnapshot(BookingState state, ReviewSummaryArgs args) {
  final dateLabel = DateFormat('MMMM d, yyyy').format(args.selectedDate);
  final timeMerged = (state.selectedTime ?? args.selectedTime).trim();
  final timeDisplay = timeMerged.isEmpty ? 'Not selected' : timeMerged;
  final confirmTimeOk = timeMerged.isNotEmpty;

  return _OverviewSnapshot(
    package: state.selectedPackage ?? args.selectedPackage,
    selectedTimeDisplay: timeDisplay,
    dateLabel: dateLabel,
    patient: state.patientInfo ?? args.patientInfo,
    paymentMethod: state.selectedPaymentMethod ?? args.selectedPaymentMethod,
    walletBalance: state.walletBalance,
    confirmTimeOk: confirmTimeOk,
  );
}

class ReviewSummaryPage extends StatelessWidget {
  const ReviewSummaryPage({
    required this.args,
    super.key,
  });

  final ReviewSummaryArgs args;

  @override
  Widget build(BuildContext context) {
    final doctor = args.doctor;
    final doctorId =
        args.doctorId ?? doctor?.documentId ?? doctor?.id?.trim() ?? '';
    return BlocProvider(
      create: (_) => BookingBloc(
        repository: BookingRepositoryImpl(BookingRemoteDataSourceImpl()),
        doctorId: doctorId.isNotEmpty ? doctorId : 'doctor',
        doctor: doctor,
        initialDate: args.selectedDate,
        initialSelectedTime: args.selectedTime,
        initialSelectedPackage: args.selectedPackage,
        initialPatientInfo: args.patientInfo,
        initialSelectedPaymentMethod: args.selectedPaymentMethod,
        initialWalletBalance: args.walletBalance,
        initialSelectedCardId: args.selectedCardId,
      ),
      child: _AppointmentOverviewView(args: args),
    );
  }
}

class _AppointmentOverviewView extends StatefulWidget {
  const _AppointmentOverviewView({required this.args});

  final ReviewSummaryArgs args;

  @override
  State<_AppointmentOverviewView> createState() => _AppointmentOverviewViewState();
}

class _AppointmentOverviewViewState extends State<_AppointmentOverviewView> {
  final _promoController = TextEditingController();
  double _discount = 4;

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  PreferredSizeWidget _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      leading: IconButton(
        padding: const EdgeInsets.all(8),
        style: IconButton.styleFrom(
          shape: const CircleBorder(),
          side: const BorderSide(color: AppColors.stroke),
        ),
        onPressed: () => _popOrExitBooking(context),
        icon: const Icon(
          LucideIcons.arrowLeft,
          color: AppColors.primaryText,
          size: 20,
        ),
      ),
      title: const Text('Appointment Overview', style: AppTextStyles.appBarTitle),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: r'$', decimalDigits: 2);

    return BlocListener<BookingBloc, BookingState>(
      listenWhen: (previous, current) => current is BookingConfirmed || current is BookingConfirmFailure,
      listener: (context, state) {
        if (state is BookingConfirmFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
          return;
        }
        if (state is BookingConfirmed) {
          final doctorName = widget.args.doctor?.name ?? 'Dr. Jenny William';
          final receipt = buildEReceiptArgsFromReviewSummary(
            widget.args,
            discount: _discount,
          );
          SchedulerBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;
            context.go(
              AppPaths.bookingSuccess,
              extra: BookingSuccessArgs(
                doctorName: doctorName,
                receipt: receipt,
              ),
            );
          });
        }
      },
      child: BlocBuilder<BookingBloc, BookingState>(
        builder: (context, state) {
          if (state is BookingError) {
            return Scaffold(
              backgroundColor: AppColors.white,
              appBar: _appBar(context),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.doctorMeta,
                  ),
                ),
              ),
            );
          }

          if (state is BookingLoading || state is CardAddingLoading) {
            return Scaffold(
              backgroundColor: AppColors.white,
              appBar: _appBar(context),
              body: const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            );
          }

          final snapshot = _buildSnapshot(state, widget.args);

          final pkg = snapshot.package;
          final patient = snapshot.patient;
          final paymentMethod = snapshot.paymentMethod;

          final isSubmitting = state is BookingConfirming;
          final subtotal = _packagePrice(pkg);
          final total = (subtotal - _discount).clamp(0.0, double.infinity);

          final canConfirm = snapshot.hasRequiredForConfirm && !isSubmitting;

          String patientHeading() {
            final n = patient.name.trim();
            return n.isEmpty ? 'Not selected' : n;
          }

          String patientSubtext() {
            return '${patient.isForSelf ? 'Self' : 'Someone else'} | ${patient.gender} | ${patient.age}';
          }

          String routeTimeSlot() =>
              snapshot.selectedTimeDisplay == 'Not selected'
                  ? widget.args.selectedTime
                  : snapshot.selectedTimeDisplay;

          Future<void> startEditSelectPackage(BuildContext ctx) async {
            ctx.push(
              AppPaths.selectPackage,
              extra: SelectPackageArgs(
                selectedDate: widget.args.selectedDate,
                selectedTime: routeTimeSlot(),
                selectedPackage: pkg,
                doctor: widget.args.doctor,
                doctorId: widget.args.doctorId,
                hospital: widget.args.hospital,
              ),
            );
          }

          Future<void> startEditPatient(BuildContext ctx) async {
            ctx.push(
              AppPaths.patientDetails,
              extra: PatientDetailsArgs(
                selectedDate: widget.args.selectedDate,
                selectedTime: routeTimeSlot(),
                selectedPackage: pkg,
                doctor: widget.args.doctor,
                doctorId: widget.args.doctorId,
                hospital: widget.args.hospital,
              ),
            );
          }

          Future<void> startEditPayment(BuildContext ctx) async {
            ctx.push(
              AppPaths.paymentMethod,
              extra: PaymentMethodArgs(
                selectedDate: widget.args.selectedDate,
                selectedTime: routeTimeSlot(),
                selectedPackage: pkg,
                patientInfo: patient,
                selectedPaymentMethod: paymentMethod,
                walletBalance: snapshot.walletBalance,
                selectedCardId: widget.args.selectedCardId,
                doctor: widget.args.doctor,
                doctorId: widget.args.doctorId,
                hospital: widget.args.hospital,
              ),
            );
          }

          final doctorDisplay = widget.args.doctor;

          return Scaffold(
            backgroundColor: AppColors.white,
            appBar: _appBar(context),
            resizeToAvoidBottomInset: true,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl,
                      AppSpacing.md,
                      AppSpacing.xl,
                      AppSpacing.lg,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Specialist', style: AppTextStyles.titleMedium),
                        const SizedBox(height: AppSpacing.sm),
                        _SpecialistCard(
                          doctor: doctorDisplay,
                          nameFallback: doctorDisplay?.name ?? 'Specialist',
                          specialtyFallback: doctorDisplay?.specialty ?? 'Healthcare',
                          ratingFallback: doctorDisplay?.rating ?? 4.9,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _SummarySection(
                          title: 'Booking Details',
                          editLabel: 'Edit Details',
                          onEdit: () => BookingNavigation.startBooking(
                            context,
                            doctor: widget.args.doctor,
                            hospital: widget.args.hospital,
                            doctorId: widget.args.doctorId,
                          ),
                          icon: LucideIcons.calendarDays,
                          heading: 'Date and Time',
                          subtext: '${snapshot.dateLabel} | ${snapshot.selectedTimeDisplay}',
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _SummarySection(
                          title: 'Package Details',
                          editLabel: 'Edit Details',
                          onEdit: () => startEditSelectPackage(context),
                          icon: LucideIcons.heartPulse,
                          heading: 'Package',
                          subtext: '${_packageLabel(pkg)} | 30 minutes',
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _SummarySection(
                          title: 'Patient Details',
                          editLabel: 'Edit Details',
                          onEdit: () => startEditPatient(context),
                          icon: LucideIcons.userRound,
                          heading: patientHeading(),
                          subtext: patientSubtext(),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _SummarySection(
                          title: 'Payment Method',
                          editLabel: 'Change',
                          onEdit: () => startEditPayment(context),
                          icon: _paymentIcon(paymentMethod),
                          heading: _paymentLabel(paymentMethod),
                          subtext: paymentMethod == PaymentMethodType.wallet
                              ? 'Balance : ${currency.format(snapshot.walletBalance)}'
                              : 'Selected payment method',
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        const Text('Promo Code', style: AppTextStyles.titleMedium),
                        const SizedBox(height: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.outline),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _promoController,
                                  decoration: const InputDecoration(
                                    hintText: 'Promo Code',
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 90,
                                height: 38,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: AppColors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 18),
                                  ),
                                  onPressed: () => setState(
                                    () =>
                                        _discount = _promoController.text.trim().isNotEmpty ? 4 : 0,
                                  ),
                                  child: const Text('Apply'),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        const Text('Payment Summary', style: AppTextStyles.titleMedium),
                        const SizedBox(height: AppSpacing.sm),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.outline),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _SummaryPriceRow(
                                  label: 'Sub-Total', value: currency.format(subtotal)),
                              const SizedBox(height: AppSpacing.sm),
                              _SummaryPriceRow(label: 'Discount', value: currency.format(_discount)),
                              const Divider(height: 24, color: AppColors.outline),
                              _SummaryPriceRow(
                                label: 'Total Amount',
                                value: currency.format(total),
                                emphasize: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SafeArea(
                  top: false,
                  minimum: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.md,
                    AppSpacing.xl,
                    AppSpacing.lg,
                  ),
                  child: SizedBox(
                    height: 56,
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      onPressed: !canConfirm
                          ? null
                          : () {
                              FocusScope.of(context).unfocus();
                              context.read<BookingBloc>().add(const ConfirmBookingEvent());
                            },
                      child: Text(
                        isSubmitting
                            ? 'Processing...'
                            : (!snapshot.hasRequiredForConfirm
                                ? 'Complete details to confirm'
                                : 'Confirm Payment'),
                        style: AppTextStyles.buttonLabel,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SpecialistCard extends StatelessWidget {
  const _SpecialistCard({
    required this.doctor,
    required this.nameFallback,
    required this.specialtyFallback,
    required this.ratingFallback,
  });

  final Doctor? doctor;
  final String nameFallback;
  final String specialtyFallback;
  final double ratingFallback;

  @override
  Widget build(BuildContext context) {
    final url = doctor?.imageUrl.trim();
    final showNetwork = url != null && url.isNotEmpty;

    final d = doctor;
    final displayName =
        (d != null && d.name.trim().isNotEmpty) ? d.name.trim() : nameFallback;
    final displaySpecialty =
        (d != null && d.specialty.trim().isNotEmpty) ? d.specialty.trim() : specialtyFallback;

    final avatar = SizedBox(
      width: 54,
      height: 54,
      child: ClipOval(
        child: showNetwork
            ? Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (context, error, _) => Container(
                  color: AppColors.neutral200,
                  alignment: Alignment.center,
                  child: const Icon(Icons.person_rounded, color: AppColors.secondaryText, size: 28),
                ),
              )
            : Container(
                color: AppColors.neutral200,
                alignment: Alignment.center,
                child: const Icon(Icons.person_rounded, color: AppColors.secondaryText, size: 28),
              ),
      ),
    );

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: [
          avatar,
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: AppTextStyles.titleMedium.copyWith(fontSize: 18),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  displaySpecialty,
                  style: AppTextStyles.doctorMeta.copyWith(fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      LucideIcons.badgeCheck,
                      color: AppColors.primary,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      LucideIcons.star,
                      color: AppColors.warning,
                      fill: 1,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text((doctor?.rating ?? ratingFallback).toStringAsFixed(1)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummarySection extends StatelessWidget {
  const _SummarySection({
    required this.title,
    required this.editLabel,
    required this.onEdit,
    required this.icon,
    required this.heading,
    required this.subtext,
  });

  final String title;
  final String editLabel;
  final VoidCallback onEdit;
  final IconData icon;
  final String heading;
  final String subtext;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.titleMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            TextButton(
              onPressed: onEdit,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.warning,
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(editLabel, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.outline),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.neutral100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: AppColors.primaryText),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      heading,
                      style: AppTextStyles.titleMedium.copyWith(fontSize: 18),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      subtext,
                      style: AppTextStyles.doctorMeta.copyWith(fontSize: 14),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SummaryPriceRow extends StatelessWidget {
  const _SummaryPriceRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final style = emphasize
        ? AppTextStyles.titleMedium.copyWith(fontSize: 18)
        : AppTextStyles.doctorMeta.copyWith(
            color: AppColors.primaryText,
            fontSize: 16,
          );
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: style,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          flex: 2,
          child: Text(
            value,
            style: style,
            textAlign: TextAlign.end,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

double _packagePrice(PackageType package) {
  switch (package) {
    case PackageType.messaging:
      return 20;
    case PackageType.voiceCall:
      return 40;
    case PackageType.videoCall:
      return 60;
    case PackageType.inPerson:
      return 100;
  }
}

String _packageLabel(PackageType package) {
  switch (package) {
    case PackageType.messaging:
      return 'Messaging';
    case PackageType.voiceCall:
      return 'Voice Call';
    case PackageType.videoCall:
      return 'Video Call';
    case PackageType.inPerson:
      return 'In Person';
  }
}

IconData _paymentIcon(PaymentMethodType method) {
  switch (method) {
    case PaymentMethodType.wallet:
      return LucideIcons.walletMinimal;
    case PaymentMethodType.creditCard:
      return LucideIcons.creditCard;
    case PaymentMethodType.payme:
      return LucideIcons.walletCards;
    case PaymentMethodType.click:
      return LucideIcons.circleDollarSign;
    case PaymentMethodType.googlePay:
      return LucideIcons.badgeDollarSign;
  }
}

String _paymentLabel(PaymentMethodType method) {
  switch (method) {
    case PaymentMethodType.wallet:
      return 'Wallet';
    case PaymentMethodType.creditCard:
      return 'Card';
    case PaymentMethodType.payme:
      return 'Payme';
    case PaymentMethodType.click:
      return 'Click';
    case PaymentMethodType.googlePay:
      return 'Google Pay';
  }
}
