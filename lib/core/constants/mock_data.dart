import '../../features/home/domain/entities/doctor.dart';
import '../../features/home/domain/entities/doctor_review.dart';
import '../../features/home/domain/entities/hospital.dart';
import '../../features/home/domain/entities/hospital_contact_person.dart';
import '../../features/home/domain/entities/hospital_review.dart';
import '../../features/home/domain/entities/working_hours_entry.dart';
import '../../features/profile/data/models/coupon_model.dart';
import '../../features/profile/data/models/doctor_model.dart';
import '../../features/profile/data/models/hospital_model.dart';
import '../../features/payment/data/models/saved_payment_card.dart';
import '../../features/payment/data/models/transaction_model.dart';
import '../../features/profile/data/models/user_model.dart';

/// Master switch for profile-section UI demos (coupons, favourites, settings, profile, wallet, payment).
const bool kUseProfileMockData = true;

/// Simulated wallet balance for coupon unlock rules during mock mode.
const double mockWalletBalance = 180;

/// Default notification preference while Firebase is bypassed.
const bool mockNotificationsEnabled = true;

const String mockUserUid = 'mock-user-uid';

final UserModel mockProfileUser = UserModel(
  uid: mockUserUid,
  displayName: 'Jennifer Aaker',
  email: 'example@gmail.com',
  photoUrl: 'https://picsum.photos/200?profile-jennifer',
  phone: '(208) 555-0112',
  countryCode: '+1',
  dateOfBirth: '15/02/2002',
  gender: 'Female',
);

const List<CouponModel> mockCoupons = [
  CouponModel(
    id: 'c1',
    code: 'FIRSTCARE',
    title: 'Get 50% OFF',
    unlockCondition: 'Unlocked — ready to use',
    unlockThreshold: 100,
    isLocked: false,
    isVerified: true,
  ),
  CouponModel(
    id: 'c2',
    code: 'WELCOME24',
    title: 'Up to \$50.00 cashback',
    unlockCondition: 'Just \$200 more to go',
    unlockThreshold: 200,
    isLocked: true,
    isVerified: false,
  ),
  CouponModel(
    id: 'c3',
    code: 'NEWPATIENT',
    title: 'Get 25% OFF',
    unlockCondition: 'Unlock this offer by adding \$100 more',
    unlockThreshold: 250,
    isLocked: true,
    isVerified: false,
  ),
  CouponModel(
    id: 'c4',
    code: 'HEALTHFIRST',
    title: 'Get 20% OFF',
    unlockCondition: 'Unlocked — ready to use',
    unlockThreshold: 100,
    isLocked: false,
    isVerified: true,
  ),
];

final List<DoctorModel> mockFavoriteDoctors = [
  _mockDoctor(
    id: 'mock-dr-rossi',
    name: 'Dr. Sophia Rossi',
    specialty: 'Otology Specialist',
    rating: 4.9,
    reviewsCount: 53,
  ),
  _mockDoctor(
    id: 'mock-dr-fox',
    name: 'Dr. Robert Fox',
    specialty: 'Dentist',
    rating: 5,
    reviewsCount: 12,
  ),
  _mockDoctor(
    id: 'mock-dr-chen',
    name: 'Dr. James Chen',
    specialty: 'Radiologist',
    rating: 4.9,
    reviewsCount: 49,
  ),
  _mockDoctor(
    id: 'mock-dr-martinez',
    name: 'Dr. Robert Martinez',
    specialty: 'Rhinology',
    rating: 5,
    reviewsCount: 24,
  ),
];

final List<HospitalModel> mockFavoriteHospitals = [
  _mockHospital(
    id: 'mock-h1',
    name: 'Unity Health Hospital',
    specialties: ['Dentist', 'Ophthalmologist', 'Otology'],
    address: '6391 Elgin St. Celina, Delaware',
    miles: 3.5,
    minutes: 15,
    rating: 4.8,
    imageUrl: 'https://picsum.photos/400/200?random=1',
  ),
  _mockHospital(
    id: 'mock-h2',
    name: 'EliteCare Hospital',
    specialties: ['Ophthalmologist', 'Orthopaedics'],
    address: '8502 Preston Rd. Inglewood, Maine',
    miles: 4.3,
    minutes: 20,
    rating: 4.9,
    imageUrl: 'https://picsum.photos/400/200?random=2',
  ),
  _mockHospital(
    id: 'mock-h3',
    name: 'City Medical Center',
    specialties: ['Cardiology', 'Neurology'],
    address: '1901 Thornridge Cir. Shiloh, Hawaii',
    miles: 5.1,
    minutes: 25,
    rating: 4.6,
    imageUrl: 'https://picsum.photos/400/200?random=3',
  ),
];

/// My Wallet screen demo balance.
const double mockWalletBalanceAmount = 2400;

const String mockWalletId = 'W-854568';

List<TransactionModel> mockWalletTransactions() {
  return [
    TransactionModel(
      id: 'tx-1',
      title: 'Money Added to Wallet',
      timestamp: DateTime(2026, 1, 11, 11, 30),
      amount: 250,
      type: 'income',
      postBalance: 2400,
    ),
    TransactionModel(
      id: 'tx-2',
      title: 'Booking ID #SL562542',
      timestamp: DateTime(2026, 1, 10, 9, 15),
      amount: 50,
      type: 'expense',
      postBalance: 2100,
    ),
    TransactionModel(
      id: 'tx-3',
      title: 'Money Added to Wallet',
      timestamp: DateTime(2026, 1, 7, 14, 20),
      amount: 500,
      type: 'income',
      postBalance: 2150,
    ),
  ];
}

const List<SavedPaymentCard> mockSavedPaymentCards = [
  SavedPaymentCard(
    id: 'card-1',
    cardHolderName: 'Jennifer Aaker',
    maskedNumber: '**** **** **** 8047',
    lastFour: '8047',
  ),
];

/// Applies [mockWalletBalance] unlock rules to [mockCoupons].
List<CouponModel> mockCouponsWithWalletBalance() {
  return mockCoupons
      .map((c) => c.withWalletBalance(mockWalletBalance))
      .toList();
}

Doctor _mockDoctor({
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
    about: '$name provides compassionate, patient-first care.',
    patientsCount: 900 + reviewsCount * 4,
    experienceYears: 10,
    workingHours: const [
      WorkingHoursEntry('Monday - Friday', '09:00 am - 06:00 pm'),
    ],
    address: '4140 Parker Rd., San Francisco',
    latitude: 37.77,
    longitude: -122.42,
    patientReviews: const <DoctorReview>[],
  );
}

Hospital _mockHospital({
  required String id,
  required String name,
  required List<String> specialties,
  required String address,
  required double miles,
  required int minutes,
  required double rating,
  required String imageUrl,
}) {
  return Hospital(
    id: id,
    name: name,
    rating: rating,
    tags: specialties.join(', '),
    specialties: specialties,
    address: address,
    distance: '${miles.toStringAsFixed(1)} Miles',
    eta: '$minutes Min',
    imageUrl: imageUrl,
    description: 'Trusted care with modern facilities.',
    treatments: List<String>.from(specialties),
    specialists: const [],
    timings: const {'Monday': '08:00 - 20:00'},
    contactPerson: const HospitalContactPerson(
      name: 'Reception',
      role: 'Coordinator',
      avatarUrl: '',
    ),
    images: [imageUrl],
    galleryImages: [imageUrl],
    reviews: const <HospitalReview>[],
    latitude: 37.78,
    longitude: -122.41,
    distanceInMiles: miles,
    durationInMinutes: minutes,
    isFavorite: true,
  );
}
