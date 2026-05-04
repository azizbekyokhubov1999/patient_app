import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/explore_repository.dart';
import 'explore_state.dart';

class ExploreCubit extends Cubit<ExploreState> {
  ExploreCubit(this._repository)
    : super(
        const ExploreState(
          hospitals: [],
          userLatitude: ExploreState.kDefaultUserLat,
          userLongitude: ExploreState.kDefaultUserLng,
          selectedHospitalIndex: 0,
        ),
      );

  final ExploreRepository _repository;

  Future<void> load() async {
    final hospitals = await _repository.getNearbyHospitals();
    emit(state.copyWith(hospitals: hospitals, selectedHospitalIndex: 0));
  }

  void selectHospital(int index) {
    if (state.hospitals.isEmpty) return;
    if (index < 0 || index >= state.hospitals.length) return;
    if (index == state.selectedHospitalIndex) return;
    emit(state.copyWith(selectedHospitalIndex: index));
  }
}
