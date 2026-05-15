import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasources/search_local_data_source.dart';
import '../../data/search_catalog.dart';
import '../../domain/entities/doctor.dart';
import '../../domain/entities/hospital.dart';
import 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit({
    SearchLocalDataSource? localDataSource,
  })  : _localDataSource = localDataSource ?? SearchLocalDataSource(),
        super(const SearchState());

  final SearchLocalDataSource _localDataSource;

  List<Doctor> _allDoctors = SearchCatalog.doctors;
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
      _allHospitals = await SearchCatalog.loadAllHospitals();
      final stored = await _localDataSource.loadKeywords();
      final keywords =
          stored.isEmpty ? SearchCatalog.defaultRecentKeywords : stored;

      emit(
        state.copyWith(
          recentKeywords: keywords,
          recentDoctors: SearchCatalog.defaultRecentDoctors,
          recentHospitals: _allHospitals.take(3).toList(),
          isLoading: false,
          isInitialized: true,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          recentKeywords: SearchCatalog.defaultRecentKeywords,
          recentDoctors: SearchCatalog.defaultRecentDoctors,
          recentHospitals: SearchCatalog.homeHospitals.take(3).toList(),
          isLoading: false,
          isInitialized: true,
        ),
      );
    }
  }

  void onQueryChanged(String query) {
    final trimmed = query.trim();
    emit(state.copyWith(query: query));

    _debounce?.cancel();

    if (trimmed.isEmpty) {
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
    final lower = query.toLowerCase();

    final doctors = _allDoctors.where((d) {
      return d.name.toLowerCase().contains(lower) ||
          d.specialty.toLowerCase().contains(lower);
    }).toList();

    final hospitals = _allHospitals.where((h) {
      return h.name.toLowerCase().contains(lower) ||
          h.tags.toLowerCase().contains(lower) ||
          h.address.toLowerCase().contains(lower);
    }).toList();

    emit(
      state.copyWith(
        isLoading: false,
        isSearching: true,
        searchedDoctors: doctors,
        searchedHospitals: hospitals,
      ),
    );
  }

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
