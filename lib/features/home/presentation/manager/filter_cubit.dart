import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/filter_result.dart';
import 'filter_state.dart';

class FilterCubit extends Cubit<FilterState> {
  FilterCubit({FilterResult? initialFilter})
      : super(_stateFromResult(initialFilter ?? FilterResult.defaults()));

  static const List<String> specialistOptions = [
    'All',
    'Dentist',
    'Cardiology',
    'Neurology',
    'Orthopedic',
    'Pediatric',
  ];

  static const List<String> consultationTypeOptions = [
    'All',
    'Messaging',
    'Voice Call',
    'Video Call',
    'In Person',
  ];

  static const List<String> ratingOptions = [
    '4.5 and above',
    '4.0 - 4.5',
    '3.5 - 4.0',
    '3.0 - 3.5',
    '2.5 - 3.0',
  ];

  static FilterState _stateFromResult(FilterResult result) {
    return FilterState(
      selectedSpecialist: result.specialist,
      selectedConsultationType: result.consultationType,
      selectedRating: _ratingLabelFromRange(result.minRating, result.maxRating),
      distanceRange: RangeValues(result.minDistance, result.maxDistance),
      feeRange: RangeValues(result.minFee, result.maxFee),
    );
  }

  static String _ratingLabelFromRange(double min, double max) {
    for (final option in ratingOptions) {
      final range = _ratingBounds(option);
      if ((range.$1 - min).abs() < 0.01 && (range.$2 - max).abs() < 0.01) {
        return option;
      }
    }
    return ratingOptions.first;
  }

  static (double, double) _ratingBounds(String label) {
    switch (label) {
      case '4.0 - 4.5':
        return (4.0, 4.5);
      case '3.5 - 4.0':
        return (3.5, 4.0);
      case '3.0 - 3.5':
        return (3.0, 3.5);
      case '2.5 - 3.0':
        return (2.5, 3.0);
      case '4.5 and above':
      default:
        return (4.5, 5.0);
    }
  }

  void updateSpecialist(String value) {
    emit(state.copyWith(selectedSpecialist: value));
  }

  void updateConsultationType(String value) {
    emit(state.copyWith(selectedConsultationType: value));
  }

  void updateRating(String value) {
    emit(state.copyWith(selectedRating: value));
  }

  void updateDistance(RangeValues values) {
    emit(state.copyWith(distanceRange: values));
  }

  void updateFee(RangeValues values) {
    emit(state.copyWith(feeRange: values));
  }

  void resetFilters() {
    emit(FilterState());
  }

  FilterResult buildResult() {
    final rating = _ratingBounds(state.selectedRating);
    return FilterResult(
      specialist: state.selectedSpecialist,
      consultationType: state.selectedConsultationType,
      minRating: rating.$1,
      maxRating: rating.$2,
      minDistance: state.distanceRange.start,
      maxDistance: state.distanceRange.end,
      minFee: state.feeRange.start,
      maxFee: state.feeRange.end,
    );
  }
}
