import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_paths.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../home/domain/entities/doctor.dart';
import '../../../home/domain/entities/hospital.dart';
import '../../data/datasources/booking_remote_data_source.dart';
import '../../data/repositories/booking_repository_impl.dart';
import '../../domain/entities/time_slot.dart';
import '../bloc/booking_bloc.dart';
import '../bloc/booking_event.dart';
import '../bloc/booking_state.dart';
import '../models/booking_route_args.dart';

class AppointmentPage extends StatelessWidget {
  const AppointmentPage({
    this.doctor,
    this.doctorId,
    this.hospital,
    this.selectedSpecialist,
    super.key,
  });

  final Doctor? doctor;
  final String? doctorId;
  final Hospital? hospital;
  final Doctor? selectedSpecialist;

  static const Doctor _mockDoctor = Doctor(
    name: 'Dr. Jenny William',
    specialty: 'Dentist',
    rating: 4.9,
    reviewsCount: 128,
    imageUrl:
        'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?auto=format&fit=crop&w=500&q=80',
    about: '',
    patientsCount: 3500,
    experienceYears: 15,
    workingHours: [],
    address: '',
    latitude: 0,
    longitude: 0,
    patientReviews: [],
  );

  @override
  Widget build(BuildContext context) {
    final initialDoctor =
        selectedSpecialist ??
        doctor ??
        (hospital?.specialists.isNotEmpty == true ? hospital!.specialists.first : _mockDoctor);
    final resolvedDoctorId = doctorId ?? _doctorIdFromDoctor(initialDoctor);

    return BlocProvider(
      create: (_) {
        final bloc = BookingBloc(
          repository: BookingRepositoryImpl(BookingRemoteDataSourceImpl()),
          doctorId: resolvedDoctorId,
          initialDate: DateTime(2026, 1, 15),
        );
        bloc.add(FetchAvailableSlots(DateTime(2026, 1, 15), resolvedDoctorId));
        return bloc;
      },
      child: _AppointmentView(
        doctor: initialDoctor,
        doctorId: resolvedDoctorId,
        hospital: hospital,
        selectedSpecialist: selectedSpecialist,
      ),
    );
  }

  static String _doctorIdFromDoctor(Doctor doctor) {
    return doctor.name.toLowerCase().replaceAll(' ', '_');
  }
}

class _AppointmentView extends StatefulWidget {
  const _AppointmentView({
    required this.doctor,
    required this.doctorId,
    this.hospital,
    this.selectedSpecialist,
  });

  final Doctor doctor;
  final String doctorId;
  final Hospital? hospital;
  final Doctor? selectedSpecialist;

  @override
  State<_AppointmentView> createState() => _AppointmentViewState();
}

class _AppointmentViewState extends State<_AppointmentView> {
  DateTime _displayMonth = DateTime(2026, 1);
  Doctor? _activeSpecialist;

  @override
  void initState() {
    super.initState();
    _activeSpecialist = widget.selectedSpecialist ??
        (widget.hospital?.specialists.isNotEmpty == true ? widget.hospital!.specialists.first : null);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookingBloc, BookingState>(
      builder: (context, state) {
        final selectedDate = state.selectedDate;
        final slots = state is SlotsLoaded ? state.slots : <TimeSlot>[];

        return Scaffold(
          backgroundColor: AppColors.white,
          appBar: _BookingAppBar(
            title: 'Book Appointment',
            onBack: () => context.pop(),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.sm, AppSpacing.xl, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.hospital != null) ...[
                  _SpecialistSelector(
                    specialists: widget.hospital!.specialists,
                    selected: _activeSpecialist,
                    onChanged: (doctor) {
                      setState(() => _activeSpecialist = doctor);
                      final doctorId = AppointmentPage._doctorIdFromDoctor(doctor);
                      context.read<BookingBloc>().add(
                            FetchAvailableSlots(state.selectedDate, doctorId),
                          );
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
                DoctorInfoCard(doctor: _activeSpecialist ?? widget.doctor),
                const SizedBox(height: AppSpacing.xxl),
                const Text(
                  'Select Date',
                  style: AppTextStyles.sectionTitle,
                ),
                const SizedBox(height: 14),
                _CalendarHeader(
                  month: _displayMonth,
                  onPrev: () => setState(() {
                    _displayMonth = DateTime(_displayMonth.year, _displayMonth.month - 1);
                  }),
                  onNext: () => setState(() {
                    _displayMonth = DateTime(_displayMonth.year, _displayMonth.month + 1);
                  }),
                ),
                const SizedBox(height: 10),
                _CustomCalendarGrid(
                  month: _displayMonth,
                  selectedDate: selectedDate,
                  onSelect: (date) {
                    context.read<BookingBloc>().add(SelectDate(date));
                  },
                ),
                const SizedBox(height: AppSpacing.xxl),
                Row(
                  children: const [
                    Text(
                      'Select Time',
                      style: AppTextStyles.sectionTitle,
                    ),
                    Spacer(),
                    _LegendDot(color: AppColors.stroke, label: 'Available'),
                    SizedBox(width: 12),
                    _LegendDot(color: AppColors.error, label: 'Not-Available'),
                  ],
                ),
                const SizedBox(height: 14),
                _TimeSlotGrid(
                  slots: slots,
                  selectedTime: state.selectedTime,
                  onTapSlot: (slot) {
                    if (slot.status == TimeSlotStatus.reserved) return;
                    context.read<BookingBloc>().add(SelectTimeSlot(slot.time));
                  },
                ),
              ],
            ),
          ),
          bottomNavigationBar: SafeArea(
            minimum: const EdgeInsets.fromLTRB(20, 10, 20, 16),
            child: SizedBox(
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                onPressed: (state.selectedTime == null || (widget.hospital != null && _activeSpecialist == null))
                    ? null
                    : () {
                        final selectedDoctor = _activeSpecialist ?? widget.doctor;
                        context.push(
                          AppPaths.selectPackage,
                          extra: SelectPackageArgs(
                            selectedDate: state.selectedDate,
                            selectedTime: state.selectedTime!,
                            selectedPackage: state.selectedPackage,
                            doctor: selectedDoctor,
                            doctorId: AppointmentPage._doctorIdFromDoctor(selectedDoctor),
                            hospital: widget.hospital,
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

class _BookingAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _BookingAppBar({
    required this.title,
    required this.onBack,
  });

  final String title;
  final VoidCallback onBack;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onBack,
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
      title: Text(
        title,
        style: AppTextStyles.appBarTitle,
      ),
    );
  }
}

class _SpecialistSelector extends StatelessWidget {
  const _SpecialistSelector({
    required this.specialists,
    required this.selected,
    required this.onChanged,
  });

  final List<Doctor> specialists;
  final Doctor? selected;
  final ValueChanged<Doctor> onChanged;

  @override
  Widget build(BuildContext context) {
    if (specialists.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Specialist',
          style: TextStyle(
            color: AppColors.secondaryText,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.stroke),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Doctor>(
              value: selected ?? specialists.first,
              icon: const Icon(
                LucideIcons.chevronDown,
                size: 18,
                color: AppColors.secondaryText,
              ),
              isExpanded: true,
              borderRadius: BorderRadius.circular(12),
              style: const TextStyle(
                color: AppColors.primaryText,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              items: specialists
                  .map(
                    (doctor) => DropdownMenuItem<Doctor>(
                      value: doctor,
                      child: Text(
                        '${doctor.name} - ${doctor.specialty}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) onChanged(value);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class DoctorInfoCard extends StatelessWidget {
  const DoctorInfoCard({required this.doctor, super.key});

  final Doctor doctor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipOval(
                child: Image.network(
                  doctor.imageUrl,
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, _) => Container(
                    width: 72,
                    height: 72,
                    color: AppColors.neutral100,
                  ),
                ),
              ),
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    LucideIcons.badgeCheck,
                    size: 13,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.doctorName,
                ),
                const SizedBox(height: 2),
                Text(
                  doctor.specialty,
                  style: AppTextStyles.doctorMeta,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      LucideIcons.star,
                      size: 14,
                      color: AppColors.yellow,
                      fill: 1,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      doctor.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryText,
                      ),
                    ),
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

class _CalendarHeader extends StatelessWidget {
  const _CalendarHeader({
    required this.month,
    required this.onPrev,
    required this.onNext,
  });

  final DateTime month;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final monthLabel = _monthName(month.month);
    return Row(
      children: [
        _RoundIconButton(icon: LucideIcons.chevronLeft, onTap: onPrev),
        Expanded(
          child: Center(
            child: Text(
              '$monthLabel ${month.year}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText,
              ),
            ),
          ),
        ),
        _RoundIconButton(icon: LucideIcons.chevronRight, onTap: onNext),
      ],
    );
  }
}

class _CustomCalendarGrid extends StatelessWidget {
  const _CustomCalendarGrid({
    required this.month,
    required this.selectedDate,
    required this.onSelect,
  });

  final DateTime month;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelect;

  static const List<String> _weekDays = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];

  @override
  Widget build(BuildContext context) {
    final days = _buildCalendarCells(month);
    return Column(
      children: [
        Row(
          children: _weekDays
              .map(
                (day) => Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.neutral100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      day,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryText,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: days.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final day = days[index];
            final isSelected = _isSameDate(day.date, selectedDate);
            return InkWell(
              borderRadius: BorderRadius.circular(26),
              onTap: day.isCurrentMonth ? () => onSelect(day.date) : null,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.neutral100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '${day.date.day}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? AppColors.white
                          : (day.isCurrentMonth
                              ? AppColors.primaryText
                              : AppColors.secondaryText.withValues(alpha: 0.5)),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.primaryText,
          ),
        ),
      ],
    );
  }
}

class _TimeSlotGrid extends StatelessWidget {
  const _TimeSlotGrid({
    required this.slots,
    required this.selectedTime,
    required this.onTapSlot,
  });

  final List<TimeSlot> slots;
  final String? selectedTime;
  final ValueChanged<TimeSlot> onTapSlot;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: slots.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.45,
      ),
      itemBuilder: (context, index) {
        final slot = slots[index];
        final isSelected = selectedTime == slot.time || slot.status == TimeSlotStatus.selected;
        final isReserved = slot.status == TimeSlotStatus.reserved;

        final bgColor = isSelected
            ? AppColors.primary
            : (isReserved ? AppColors.error : AppColors.white);
        final textColor = isSelected || isReserved ? AppColors.white : AppColors.primaryText;
        final borderColor = isSelected || isReserved ? Colors.transparent : AppColors.stroke;

        return InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: isReserved ? null : () => onTapSlot(slot),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderColor),
            ),
            child: Text(
              slot.time,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.neutral100,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 18,
          color: AppColors.primaryText,
        ),
      ),
    );
  }
}

class _CalendarCell {
  const _CalendarCell({
    required this.date,
    required this.isCurrentMonth,
  });

  final DateTime date;
  final bool isCurrentMonth;
}

List<_CalendarCell> _buildCalendarCells(DateTime month) {
  final firstDayOfMonth = DateTime(month.year, month.month, 1);
  final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
  final firstWeekday = firstDayOfMonth.weekday % 7;
  final previousMonth = DateTime(month.year, month.month, 0);

  final cells = <_CalendarCell>[];

  for (var i = firstWeekday - 1; i >= 0; i--) {
    final day = previousMonth.day - i;
    cells.add(
      _CalendarCell(
        date: DateTime(previousMonth.year, previousMonth.month, day),
        isCurrentMonth: false,
      ),
    );
  }

  for (var day = 1; day <= daysInMonth; day++) {
    cells.add(
      _CalendarCell(
        date: DateTime(month.year, month.month, day),
        isCurrentMonth: true,
      ),
    );
  }

  while (cells.length % 7 != 0) {
    final nextDay = cells.length - (firstWeekday + daysInMonth) + 1;
    cells.add(
      _CalendarCell(
        date: DateTime(month.year, month.month + 1, nextDay),
        isCurrentMonth: false,
      ),
    );
  }

  return cells;
}

bool _isSameDate(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

String _monthName(int month) {
  const monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return monthNames[month - 1];
}
