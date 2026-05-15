import '../../domain/entities/doctor.dart';
import '../../domain/entities/hospital.dart';

class SearchState {
  const SearchState({
    this.query = '',
    this.recentKeywords = const [],
    this.recentDoctors = const [],
    this.recentHospitals = const [],
    this.searchedDoctors = const [],
    this.searchedHospitals = const [],
    this.isLoading = false,
    this.isSearching = false,
    this.isInitialized = false,
  });

  final String query;
  final List<String> recentKeywords;
  final List<Doctor> recentDoctors;
  final List<Hospital> recentHospitals;
  final List<Doctor> searchedDoctors;
  final List<Hospital> searchedHospitals;
  final bool isLoading;
  final bool isSearching;
  final bool isInitialized;

  bool get hasNoSearchResults =>
      isSearching &&
      !isLoading &&
      isInitialized &&
      searchedDoctors.isEmpty &&
      searchedHospitals.isEmpty;

  SearchState copyWith({
    String? query,
    List<String>? recentKeywords,
    List<Doctor>? recentDoctors,
    List<Hospital>? recentHospitals,
    List<Doctor>? searchedDoctors,
    List<Hospital>? searchedHospitals,
    bool? isLoading,
    bool? isSearching,
    bool? isInitialized,
  }) {
    return SearchState(
      query: query ?? this.query,
      recentKeywords: recentKeywords ?? this.recentKeywords,
      recentDoctors: recentDoctors ?? this.recentDoctors,
      recentHospitals: recentHospitals ?? this.recentHospitals,
      searchedDoctors: searchedDoctors ?? this.searchedDoctors,
      searchedHospitals: searchedHospitals ?? this.searchedHospitals,
      isLoading: isLoading ?? this.isLoading,
      isSearching: isSearching ?? this.isSearching,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}
