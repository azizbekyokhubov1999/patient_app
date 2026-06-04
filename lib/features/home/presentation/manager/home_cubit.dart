import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/entities/appointment_preview.dart';
import '../../domain/entities/filter_result.dart';
import '../../domain/entities/doctor.dart';
import '../../domain/entities/hospital.dart';
import '../../domain/entities/service_category.dart';
import '../../domain/repositories/home_repository.dart';
import '../utils/home_filter_utils.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required HomeRepository repository,
    FirebaseAuth? auth,
  })  : _repository = repository,
        _auth = auth ?? FirebaseAuth.instance,
        super(HomeState.initial());

  final HomeRepository _repository;
  final FirebaseAuth _auth;

  List<Doctor> _allDoctors = [];
  List<Hospital> _allHospitals = [];

  FilterResult? get currentFilter => state.activeFilter;

  Future<void> loadHomeData() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final uid = _auth.currentUser?.uid;

      final results = await Future.wait<dynamic>([
        _repository.getTopDoctors(),
        _repository.getNearbyHospitals(),
        _repository.getAllDoctors(),
        _repository.getAllHospitals(),
        uid != null
            ? _repository.getUpcomingAppointments(uid)
            : Future<List<AppointmentPreview>>.value(const []),
      ]);

      final topDoctors = results[0] as List<Doctor>;
      final nearbyHospitals = results[1] as List<Hospital>;
      _allDoctors = results[2] as List<Doctor>;
      _allHospitals = results[3] as List<Hospital>;
      final previews = results[4] as List<AppointmentPreview>;

      final filter = state.activeFilter;
      emit(
        state.copyWith(
          isLoading: false,
          appointments: previews.map(_toHomeAppointment).toList(),
          doctors: filter != null
              ? filterDoctors(_allDoctors, filter)
              : List<Doctor>.from(topDoctors),
          hospitals: filter != null
              ? filterHospitals(_allHospitals, filter)
              : List<Hospital>.from(nearbyHospitals),
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  static Appointment _toHomeAppointment(AppointmentPreview preview) {
    final dateLabel =
        DateFormat('EEEE, d MMMM').format(preview.appointmentDate);
    final start = preview.startTime.trim();
    final end = preview.endTime.trim();
    final timeLabel =
        start.isNotEmpty && end.isNotEmpty ? '$start - $end' : start;

    return Appointment(
      doctorName: preview.doctorName,
      specialty: preview.doctorSpecialty,
      rating: preview.doctorRating,
      dateLabel: dateLabel,
      timeLabel: timeLabel,
      doctorImageUrl: preview.doctorImageUrl,
    );
  }

  void applyFilters(FilterResult filter) {
    emit(
      state.copyWith(
        activeFilter: filter,
        doctors: filterDoctors(_allDoctors, filter),
        hospitals: filterHospitals(_allHospitals, filter),
      ),
    );
  }

  void filterByServiceCategory(ServiceCategory category) {
    final base = currentFilter ?? FilterResult.defaults();
    applyFilters(base.copyWith(specialist: category.name));
  }

  void selectService(int index) {
    emit(state.copyWith(selectedServiceIndex: index));
  }

  void updateCurrentAppointment(int index) {
    emit(state.copyWith(currentAppointmentIndex: index));
  }
}
