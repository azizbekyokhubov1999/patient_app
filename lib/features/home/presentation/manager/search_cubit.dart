import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasources/search_local_data_source.dart';
import '../../domain/entities/doctor.dart';
import '../../domain/entities/filter_result.dart';
import '../../domain/entities/hospital.dart';
import '../../domain/repositories/search_repository.dart';
import '../utils/home_filter_utils.dart';
import 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit({
    required SearchRepository repository,
    SearchLocalDataSource? localDataSource,
    FilterResult? initialFilter,
  })  : _repository = repository,
        _localDataSource = localDataSource ?? SearchLocalDataSource(),
        _pendingFilter = initialFilter,
        super(const SearchState());

  final SearchRepository _repository;
  final SearchLocalDataSource _localDataSource;
  FilterResult? _pendingFilter;
  FilterResult? _activeFilter;

  List<Doctor> _allDoctors = [];
  List<Hospital> _allHospitals = [];

  Timer? _debounce;

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }

  Future<void> loadRecentData() async {
    emit(state.copyWith(isLoading: true));

    try {
      final results = await Future.wait([
        _repository.getAllDoctors(),
        _repository.getAllHospitals(),
        _localDataSource.loadKeywords(),
      ]);

      _allDoctors = results[0] as List<Doctor>;
      _allHospitals = results[1] as List<Hospital>;
      final stored = results[2] as List<String>;

      final keywords = stored.isEmpty
          ? const ['Dental Care', 'Eye Care', 'Dentist']
          : stored;

      emit(
        state.copyWith(
          recentKeywords: keywords,
          recentDoctors: _allDoctors.take(3).toList(),
          recentHospitals: _allHospitals.take(3).toList(),
          isLoading: false,
          isInitialized: true,
        ),
      );

      final filter = _pendingFilter;
      _pendingFilter = null;
      if (filter != null) {
        applyFilters(filter);
      }
    } catch (_) {
      emit(
        state.copyWith(
          recentKeywords: const ['Dental Care', 'Eye Care', 'Dentist'],
          recentDoctors: const [],
          recentHospitals: const [],
          isLoading: false,
          isInitialized: true,
          searchedDoctors: const [],
          searchedHospitals: const [],
        ),
      );
    }
  }

  void applyFilters(FilterResult filter) {
    if (!_hasCatalog) return;

    _activeFilter = filter;
    final doctors = filterDoctors(_allDoctors, filter);
    final hospitals = filterHospitals(_allHospitals, filter);

    final query = state.query.trim();
    if (query.isEmpty) {
      emit(
        state.copyWith(
          isSearching: true,
          isLoading: false,
          searchedDoctors: doctors,
          searchedHospitals: hospitals,
        ),
      );
      return;
    }

    _emitSearchResults(query, doctors, hospitals);
  }

  void onQueryChanged(String query) {
    final trimmed = query.trim();
    emit(state.copyWith(query: query));

    _debounce?.cancel();

    if (trimmed.isEmpty) {
      if (_activeFilter != null) {
        applyFilters(_activeFilter!);
        return;
      }
      emit(
        state.copyWith(
          isSearching: false,
          isLoading: false,
          searchedDoctors: const [],
          searchedHospitals: const [],
        ),
      );
      return;
    }

    emit(state.copyWith(isSearching: true, isLoading: true));

    _debounce = Timer(const Duration(milliseconds: 300), () {
      _runSearch(trimmed);
    });
  }

  void _runSearch(String query) {
    if (!_hasCatalog) {
      emit(
        state.copyWith(
          isLoading: false,
          isSearching: true,
          searchedDoctors: const [],
          searchedHospitals: const [],
        ),
      );
      return;
    }

    var doctors = _allDoctors;
    var hospitals = _allHospitals;
    if (_activeFilter != null) {
      doctors = filterDoctors(_allDoctors, _activeFilter!);
      hospitals = filterHospitals(_allHospitals, _activeFilter!);
    }

    _emitSearchResults(query, doctors, hospitals);
  }

  void _emitSearchResults(
    String query,
    List<Doctor> doctors,
    List<Hospital> hospitals,
  ) {
    final lower = query.toLowerCase();

    final matchedDoctors = doctors.where((d) {
      return d.name.toLowerCase().contains(lower) ||
          d.specialty.toLowerCase().contains(lower);
    }).toList();

    final matchedHospitals = hospitals.where((h) {
      return h.name.toLowerCase().contains(lower) ||
          h.tags.toLowerCase().contains(lower) ||
          h.address.toLowerCase().contains(lower);
    }).toList();

    emit(
      state.copyWith(
        isLoading: false,
        isSearching: true,
        searchedDoctors: matchedDoctors,
        searchedHospitals: matchedHospitals,
      ),
    );
  }

  bool get _hasCatalog =>
      _allDoctors.isNotEmpty || _allHospitals.isNotEmpty;

  Future<void> addKeyword(String keyword) async {
    final value = keyword.trim();
    if (value.isEmpty) return;

    final updated = [
      value,
      ...state.recentKeywords.where((k) => k.toLowerCase() != value.toLowerCase()),
    ].take(SearchLocalDataSource.maxKeywords).toList();

    await _localDataSource.saveKeywords(updated);
    emit(state.copyWith(recentKeywords: updated));
  }

  Future<void> removeKeyword(String keyword) async {
    final updated =
        state.recentKeywords.where((k) => k != keyword).toList(growable: true);
    await _localDataSource.saveKeywords(updated);
    emit(state.copyWith(recentKeywords: updated));
  }

  Future<void> clearAllKeywords() async {
    await _localDataSource.clearKeywords();
    emit(state.copyWith(recentKeywords: const []));
  }

  void clearQuery() {
    onQueryChanged('');
  }

  Future<void> onKeywordTapped(String keyword) async {
    await addKeyword(keyword);
    onQueryChanged(keyword);
  }

  Future<void> onDoctorTapped(Doctor doctor) async {
    await addKeyword(doctor.specialty);
  }

  Future<void> onHospitalTapped(Hospital hospital) async {
    await addKeyword(hospital.name);
  }
}
