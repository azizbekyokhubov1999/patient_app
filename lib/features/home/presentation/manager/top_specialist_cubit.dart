import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/doctor.dart';
import '../../domain/entities/doctor_review.dart';
import '../../domain/entities/working_hours_entry.dart';
import 'top_specialist_state.dart';

/// Bypass Firestore for UI demos (reset to restore live data).
const bool _kPresentationMockTopSpecialists = true;

Doctor _demoDoctor({
  required String id,
  required String name,
  required String specialty,
  required double rating,
  required int reviewsCount,
}) {
  return Doctor(
    id: id,
    name: name,
    specialty: specialty,
    rating: rating,
    reviewsCount: reviewsCount,
    imageUrl: 'https://picsum.photos/200?doctor=$id',
    about:
        '${name.split(' ').last} specializes in evidence-based diagnostics and individualized treatment plans tailored to each patient.',
    patientsCount: 1200 + reviewsCount * 3,
    experienceYears: 8 + (reviewsCount % 9),
    workingHours: const [
      WorkingHoursEntry('Monday - Friday', '09:00 am - 06:00 pm'),
      WorkingHoursEntry('Saturday', '10:00 am - 02:00 pm'),
    ],
    address: '4140 Parker Rd., San Francisco',
    latitude: 37.77,
    longitude: -122.42,
    patientReviews: const <DoctorReview>[],
  );
}

List<Doctor> _presentationDoctorMocks() => [
      _demoDoctor(
        id: 'mock-dr-rossi',
        name: 'Dr. Sophia Rossi',
        specialty: 'Otology Specialist',
        rating: 4.9,
        reviewsCount: 53,
      ),
      _demoDoctor(
        id: 'mock-dr-fox',
        name: 'Dr. Robert Fox',
        specialty: 'Dentist',
        rating: 5,
        reviewsCount: 12,
      ),
      _demoDoctor(
        id: 'mock-dr-chen',
        name: 'Dr. James Chen',
        specialty: 'Radiologist',
        rating: 4.9,
        reviewsCount: 49,
      ),
      _demoDoctor(
        id: 'mock-dr-martinez',
        name: 'Dr. Robert Martinez',
        specialty: 'Rhinology',
        rating: 5,
        reviewsCount: 24,
      ),
      _demoDoctor(
        id: 'mock-dr-hart',
        name: 'Dr. Amelia Hart',
        specialty: 'Neurology',
        rating: 4.8,
        reviewsCount: 61,
      ),
      _demoDoctor(
        id: 'mock-dr-volkov',
        name: 'Dr. Elena Volkov',
        specialty: 'Dermatology',
        rating: 4.7,
        reviewsCount: 108,
      ),
    ];

class TopSpecialistCubit extends Cubit<TopSpecialistState> {
  TopSpecialistCubit({
    FirebaseFirestore? firestore,
    String? initialSpecialty,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _initialSpecialty = initialSpecialty,
        super(const TopSpecialistInitial());

  final FirebaseFirestore _firestore;
  final String? _initialSpecialty;

  Future<void> loadTopSpecialists() async {
    if (_kPresentationMockTopSpecialists) {
      var mocks = _presentationDoctorMocks();
      final spec = _initialSpecialty?.trim().toLowerCase();
      if (spec != null && spec.isNotEmpty) {
        mocks = mocks
            .where(
              (d) =>
                  d.specialty.toLowerCase().contains(spec) ||
                  d.name.toLowerCase().contains(spec),
            )
            .toList();
      }
      if (mocks.isEmpty) {
        emit(const TopSpecialistEmpty());
      } else {
        emit(
          TopSpecialistLoaded(
            doctors: mocks,
            filteredDoctors: List<Doctor>.from(mocks),
          ),
        );
      }
      return;
    }

    emit(const TopSpecialistLoading());
    try {
      Query<Map<String, dynamic>> q =
          _firestore.collection('doctors').orderBy('rating', descending: true);

      final specialty = _initialSpecialty?.trim();
      if (specialty != null && specialty.isNotEmpty) {
        q = _firestore
            .collection('doctors')
            .where('specialty', isEqualTo: specialty)
            .orderBy('rating', descending: true);
      }

      final snapshot = await q.limit(30).get();

      final doctors = snapshot.docs
          .map((doc) => Doctor.fromFirestore(doc.data(), doc.id))
          .toList();

      if (doctors.isEmpty) {
        emit(const TopSpecialistEmpty());
      } else {
        emit(
          TopSpecialistLoaded(
            doctors: doctors,
            filteredDoctors: List<Doctor>.from(doctors),
          ),
        );
      }
    } catch (e) {
      emit(TopSpecialistError(e.toString()));
    }
  }

  void filterByQuery(String query) {
    final current = state;
    if (current is! TopSpecialistLoaded) return;

    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) {
      clearFilter();
      return;
    }

    final filtered = current.doctors.where((d) {
      final name = d.name.toLowerCase();
      final spec = d.specialty.toLowerCase();
      return name.contains(trimmed) || spec.contains(trimmed);
    }).toList();

    emit(
      TopSpecialistLoaded(
        doctors: current.doctors,
        filteredDoctors: filtered,
      ),
    );
  }

  void clearFilter() {
    final current = state;
    if (current is! TopSpecialistLoaded) return;
    emit(
      TopSpecialistLoaded(
        doctors: current.doctors,
        filteredDoctors: List<Doctor>.from(current.doctors),
      ),
    );
  }

  Future<void> refresh() => loadTopSpecialists();
}
