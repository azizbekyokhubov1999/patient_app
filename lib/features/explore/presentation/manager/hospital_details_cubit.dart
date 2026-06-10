import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../home/data/models/review_model.dart';
import '../../../home/domain/entities/doctor.dart';
import '../../../home/domain/entities/hospital.dart';
import '../../../home/domain/entities/hospital_review.dart';
import '../../../home/domain/repositories/doctors_repository.dart';
import '../../../home/domain/repositories/home_repository.dart';
import 'hospital_details_state.dart';

class HospitalDetailsCubit extends Cubit<HospitalDetailsState> {
  static const String filterVerified = 'Verified';
  static const String filterLatest = 'Latest';
  static const String filterDetailed = 'Detailed Reviews';

  HospitalDetailsCubit({
    required Hospital initialHospital,
    required DoctorsRepository doctorsRepository,
    required HomeRepository homeRepository,
    FirebaseAuth? auth,
  })  : _doctorsRepository = doctorsRepository,
        _homeRepository = homeRepository,
        _auth = auth ?? FirebaseAuth.instance,
        super(
          HospitalDetailsState(
            hospital: initialHospital,
            selectedTabIndex: 0,
            reviewQuery: '',
            activeReviewFilters: {filterVerified, filterLatest},
          ),
        ) {
    loadHospitalDetails();
    loadSpecialists();
    _listenToReviews();
    _listenToHospitalUpdates();
  }

  final DoctorsRepository _doctorsRepository;
  final HomeRepository _homeRepository;
  final FirebaseAuth _auth;

  StreamSubscription<List<ReviewModel>>? _reviewsSubscription;
  StreamSubscription<Hospital?>? _hospitalSubscription;

  Future<void> loadHospitalDetails() async {
    try {
      final hospital = await _homeRepository.getHospitalById(state.hospital.id);
      if (hospital == null) return;

      emit(
        state.copyWith(
          hospital: hospital.copyWith(
            specialists: state.hospital.specialists,
            isFavorite: state.hospital.isFavorite,
          ),
        ),
      );
    } catch (_) {}
  }

  Future<void> loadSpecialists() async {
    emit(state.copyWith(isLoadingSpecialists: true));

    try {
      final specialists = await _doctorsRepository.getHospitalSpecialists(
        state.hospital.id,
      );
      emit(
        state.copyWith(
          hospital: state.hospital.copyWith(specialists: specialists),
          isLoadingSpecialists: false,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          hospital: state.hospital.copyWith(specialists: const []),
          isLoadingSpecialists: false,
        ),
      );
    }
  }

  void _listenToReviews() {
    final hospitalId = state.hospital.id.trim();
    if (hospitalId.isEmpty) return;

    _reviewsSubscription?.cancel();
    _reviewsSubscription = _homeRepository
        .getHospitalReviews(hospitalId)
        .listen((reviews) => emit(state.copyWith(reviews: reviews)));
  }

  void _listenToHospitalUpdates() {
    final hospitalId = state.hospital.id.trim();
    if (hospitalId.isEmpty) return;

    _hospitalSubscription?.cancel();
    _hospitalSubscription = _homeRepository.watchHospitalById(hospitalId).listen(
      (hospital) {
        if (hospital == null) return;
        emit(
          state.copyWith(
            hospital: hospital.copyWith(
              specialists: state.hospital.specialists,
              isFavorite: state.hospital.isFavorite,
            ),
          ),
        );
      },
    );
  }

  void setTab(int index) {
    if (index == state.selectedTabIndex) return;
    emit(state.copyWith(selectedTabIndex: index));
  }

  void updateHospital(Hospital hospital) {
    emit(state.copyWith(hospital: hospital));
  }

  List<Doctor> get specialists => state.hospital.specialists;

  void setReviewQuery(String value) {
    emit(state.copyWith(reviewQuery: value));
  }

  void toggleReviewFilter(String filter) {
    final updated = Set<String>.from(state.activeReviewFilters);
    if (updated.contains(filter)) {
      updated.remove(filter);
    } else {
      updated.add(filter);
    }
    emit(state.copyWith(activeReviewFilters: updated));
  }

  List<HospitalReview> get filteredReviews {
    final currentUserId = _auth.currentUser?.uid;
    var list = state.reviews
        .map((review) => _toHospitalReview(review, currentUserId))
        .toList();

    if (state.activeReviewFilters.contains(filterVerified)) {
      list = list.where((r) => r.isVerified).toList();
    }

    if (state.activeReviewFilters.contains(filterDetailed)) {
      list = list.where((r) => r.comment.length >= 80).toList();
    }

    if (state.activeReviewFilters.contains(filterLatest)) {
      list = list.reversed.toList();
    }

    final query = state.reviewQuery.trim().toLowerCase();
    if (query.isNotEmpty) {
      list = list
          .where(
            (r) =>
                r.userName.toLowerCase().contains(query) ||
                r.comment.toLowerCase().contains(query),
          )
          .toList();
    }

    return list;
  }

  HospitalReview _toHospitalReview(ReviewModel review, String? currentUserId) {
    final isCurrentUser =
        currentUserId != null && review.userId == currentUserId;

    return HospitalReview(
      userName: isCurrentUser ? 'You' : review.userName,
      userAvatar: review.userPhoto,
      rating: review.rating,
      comment: review.comment,
      createdAt: _formatReviewDate(review.createdAt),
      isVerified: isCurrentUser,
    );
  }

  String _formatReviewDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) return 'just now';
    if (difference.inHours < 24) {
      if (difference.inHours < 1) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    }
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return DateFormat('MMM d, yyyy').format(date);
  }

  @override
  Future<void> close() {
    _reviewsSubscription?.cancel();
    _hospitalSubscription?.cancel();
    return super.close();
  }
}
