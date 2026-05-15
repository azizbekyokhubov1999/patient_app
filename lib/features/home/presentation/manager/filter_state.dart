import 'package:flutter/material.dart';

class FilterState {
  const FilterState({
    this.selectedSpecialist = 'All',
    this.selectedConsultationType = 'All',
    this.selectedRating = '4.5 and above',
    this.distanceRange = const RangeValues(6, 15),
    this.feeRange = const RangeValues(15, 40),
  });

  final String selectedSpecialist;
  final String selectedConsultationType;
  final String selectedRating;
  final RangeValues distanceRange;
  final RangeValues feeRange;

  FilterState copyWith({
    String? selectedSpecialist,
    String? selectedConsultationType,
    String? selectedRating,
    RangeValues? distanceRange,
    RangeValues? feeRange,
  }) {
    return FilterState(
      selectedSpecialist: selectedSpecialist ?? this.selectedSpecialist,
      selectedConsultationType: selectedConsultationType ?? this.selectedConsultationType,
      selectedRating: selectedRating ?? this.selectedRating,
      distanceRange: distanceRange ?? this.distanceRange,
      feeRange: feeRange ?? this.feeRange,
    );
  }
}
