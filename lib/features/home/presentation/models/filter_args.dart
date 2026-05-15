import '../../domain/entities/filter_result.dart';

/// Route extra for [FilterPage] to restore previous filter selections.
class FilterArgs {
  const FilterArgs({this.initialFilter});

  final FilterResult? initialFilter;
}
