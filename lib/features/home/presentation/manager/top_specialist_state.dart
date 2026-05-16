import '../../domain/entities/doctor.dart';

sealed class TopSpecialistState {
  const TopSpecialistState();
}

final class TopSpecialistInitial extends TopSpecialistState {
  const TopSpecialistInitial();
}

final class TopSpecialistLoading extends TopSpecialistState {
  const TopSpecialistLoading();
}

final class TopSpecialistLoaded extends TopSpecialistState {
  const TopSpecialistLoaded({
    required this.doctors,
    required this.filteredDoctors,
  });

  final List<Doctor> doctors;
  final List<Doctor> filteredDoctors;
}

final class TopSpecialistEmpty extends TopSpecialistState {
  const TopSpecialistEmpty();
}

final class TopSpecialistError extends TopSpecialistState {
  const TopSpecialistError(this.message);

  final String message;
}
