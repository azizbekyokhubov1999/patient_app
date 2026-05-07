import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_paths.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/datasources/booking_remote_data_source.dart';
import '../../data/repositories/booking_repository_impl.dart';
import '../../domain/entities/patient_info.dart';
import '../bloc/booking_bloc.dart';
import '../bloc/booking_event.dart';
import '../bloc/booking_state.dart';
import '../models/booking_route_args.dart';

class PatientDetailsPage extends StatelessWidget {
  const PatientDetailsPage({
    required this.args,
    super.key,
  });

  final PatientDetailsArgs args;

  @override
  Widget build(BuildContext context) {
    final doctorId = args.doctorId ?? args.doctor?.name.toLowerCase().replaceAll(' ', '_') ?? 'doctor';

    return BlocProvider(
      create: (_) => BookingBloc(
        repository: BookingRepositoryImpl(BookingRemoteDataSourceImpl()),
        doctorId: doctorId,
        initialDate: args.selectedDate,
        initialSelectedPackage: args.selectedPackage,
      ),
      child: _PatientDetailsView(args: args),
    );
  }
}

class _PatientDetailsView extends StatefulWidget {
  const _PatientDetailsView({required this.args});

  final PatientDetailsArgs args;

  @override
  State<_PatientDetailsView> createState() => _PatientDetailsViewState();
}

class _PatientDetailsViewState extends State<_PatientDetailsView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _problemController = TextEditingController();

  static const _profileName = 'Jennifer Aaker';
  static const _profileGender = 'Female';
  static const _profileAge = '24 Years';

  String? _gender;
  String? _age;
  bool _isForSelf = true;

  static const _genderOptions = ['Male', 'Female', 'Other'];
  static final _ageOptions = List<String>.generate(83, (i) => '${18 + i} Years');

  @override
  void initState() {
    super.initState();
    _applyForSelfDefaults();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _problemController.dispose();
    super.dispose();
  }

  void _applyForSelfDefaults() {
    _nameController.text = _profileName;
    _gender = _profileGender;
    _age = _profileAge;
  }

  void _toggleForSelf(bool value) {
    setState(() {
      _isForSelf = value;
      if (value) {
        _applyForSelfDefaults();
      } else {
        _nameController.clear();
        _gender = null;
        _age = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookingBloc, BookingState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.white,
          appBar: AppBar(
            backgroundColor: AppColors.white,
            surfaceTintColor: Colors.transparent,
            centerTitle: true,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () => context.pop(),
                child: Container(
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
            ),
            title: const Text('Patient Details', style: AppTextStyles.appBarTitle),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md, AppSpacing.xl, 120),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Is this for you or someone else?',
                    style: AppTextStyles.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: _PatientTypeCard(
                          title: 'For Myself',
                          icon: LucideIcons.userRound,
                          selected: _isForSelf,
                          onTap: () => _toggleForSelf(true),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _PatientTypeCard(
                          title: 'Someone else',
                          icon: LucideIcons.userRoundPlus,
                          selected: !_isForSelf,
                          onTap: () => _toggleForSelf(false),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  const Text(
                    'Is this for you or someone else?',
                    style: AppTextStyles.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const _FieldLabel('Name'),
                  TextFormField(
                    controller: _nameController,
                    validator: (value) =>
                        (value == null || value.trim().isEmpty) ? 'Enter your name' : null,
                    decoration: _inputDecoration(),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const _FieldLabel('Gender'),
                  DropdownButtonFormField<String>(
                    initialValue: _gender,
                    items: _genderOptions
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (value) => setState(() => _gender = value),
                    validator: (value) => value == null ? 'Select gender' : null,
                    decoration: _inputDecoration(),
                    icon: const Icon(LucideIcons.chevronDown, size: 18),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const _FieldLabel('Your Age'),
                  DropdownButtonFormField<String>(
                    initialValue: _age,
                    items: _ageOptions
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (value) => setState(() => _age = value),
                    validator: (value) => value == null ? 'Select age' : null,
                    decoration: _inputDecoration(),
                    icon: const Icon(LucideIcons.chevronDown, size: 18),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const _FieldLabel('Write Your Problem'),
                  TextFormField(
                    controller: _problemController,
                    maxLines: 5,
                    validator: (value) => (value == null || value.trim().isEmpty)
                        ? 'Please describe your problem'
                        : null,
                    decoration: _inputDecoration(hintText: 'Write here...'),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: SafeArea(
            top: false,
            minimum: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.lg),
            child: SizedBox(
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                onPressed: () {
                  if (!_formKey.currentState!.validate()) return;

                  final info = PatientInfo(
                    isForSelf: _isForSelf,
                    name: _nameController.text.trim(),
                    gender: _gender!,
                    age: _age!,
                    problemDescription: _problemController.text.trim(),
                  );

                  context.read<BookingBloc>().add(UpdatePatientDetailsEvent(info));

                  context.push(
                    AppPaths.paymentMethod,
                    extra: PaymentMethodArgs(
                      selectedDate: widget.args.selectedDate,
                      selectedTime: widget.args.selectedTime,
                      selectedPackage: widget.args.selectedPackage,
                      patientInfo: info,
                      selectedPaymentMethod: state.selectedPaymentMethod,
                      walletBalance: state.walletBalance,
                      savedCards: state.savedCards,
                      selectedCardId: state.selectedCardId,
                      doctor: widget.args.doctor,
                      doctorId: widget.args.doctorId,
                      hospital: widget.args.hospital,
                    ),
                  );
                },
                child: const Text(
                  'Continue',
                  style: AppTextStyles.buttonLabel,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

InputDecoration _inputDecoration({String? hintText}) {
  return InputDecoration(
    hintText: hintText,
    filled: true,
    fillColor: AppColors.neutral100,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.md,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.primary),
    ),
  );
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.primaryText,
        ),
      ),
    );
  }
}

class _PatientTypeCard extends StatelessWidget {
  const _PatientTypeCard({
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.neutral100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.outline,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.neutral200,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 22, color: AppColors.primaryText),
                ),
                const Spacer(),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? AppColors.primary : AppColors.outline,
                      width: 1.5,
                    ),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected ? AppColors.primary : Colors.transparent,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: AppTextStyles.titleMedium.copyWith(
                fontSize: 16,
                color: selected ? AppColors.primaryText : AppColors.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
