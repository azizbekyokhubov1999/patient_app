import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/complete_profile_usecase.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/send_password_reset_usecase.dart';
import '../../features/auth/domain/usecases/sign_in_usecase.dart';
import '../../features/auth/domain/usecases/sign_out_usecase.dart';
import '../../features/auth/domain/usecases/sign_up_usecase.dart';
import '../../features/auth/presentation/manager/auth_cubit.dart';
import '../../features/home/data/datasources/doctor_remote_data_source.dart';
import '../../features/home/data/repositories/doctors_repository_impl.dart';
import '../../features/home/domain/repositories/doctors_repository.dart';
import '../../features/home/presentation/manager/top_specialist_cubit.dart';
import '../../features/profile/data/datasources/coupons_remote_data_source.dart';
import '../../features/profile/data/datasources/profile_remote_data_source.dart';
import '../../features/profile/data/repositories/coupons_repository_impl.dart';
import '../../features/profile/data/repositories/favourites_repository_impl.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/coupons_repository.dart';
import '../../features/profile/domain/repositories/favourites_repository.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/presentation/manager/coupons_cubit.dart';
import '../../features/profile/presentation/manager/favourites_cubit.dart';
import '../../features/profile/domain/usecases/get_user_profile_usecase.dart';
import '../../features/profile/domain/usecases/profile_sign_out_usecase.dart';
import '../../features/profile/domain/usecases/save_user_profile_usecase.dart';
import '../../features/profile/presentation/manager/profile_cubit.dart';

/// Application-wide dependency container (manual DI).
final class AppDependencies {
  AppDependencies._();

  static final AppDependencies instance = AppDependencies._();

  late final AuthRepository authRepository;
  late final ProfileRepository profileRepository;
  late final CouponsRepository couponsRepository;
  late final DoctorsRepository doctorsRepository;
  late final FavouritesRepository favouritesRepository;

  late final AuthCubit authCubit;
  late final ProfileCubit profileCubit;

  late final FirebaseAuth _firebaseAuth;

  bool _initialized = false;

  void init({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  }) {
    if (_initialized) return;

    _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;
    final db = firestore ?? FirebaseFirestore.instance;

    final authRemote = AuthRemoteDataSourceImpl(
      firebaseAuth: _firebaseAuth,
      firestore: db,
    );
    authRepository = AuthRepositoryImpl(authRemote);

    final profileRemote = ProfileRemoteDataSourceImpl(
      auth: _firebaseAuth,
      firestore: db,
    );
    profileRepository = ProfileRepositoryImpl(profileRemote);

    final couponsRemote = CouponsRemoteDataSourceImpl(firestore: db);
    couponsRepository = CouponsRepositoryImpl(couponsRemote);

    final doctorRemote = DoctorRemoteDataSourceImpl(firestore: db);
    doctorsRepository = DoctorsRepositoryImpl(doctorRemote);
    favouritesRepository = FavouritesRepositoryImpl(doctorsRepository);

    authCubit = AuthCubit(
      signInUseCase: SignInUseCase(authRepository),
      signUpUseCase: SignUpUseCase(authRepository),
      completeProfileUseCase: CompleteProfileUseCase(authRepository),
      sendPasswordResetUseCase: SendPasswordResetUseCase(authRepository),
      getCurrentUserUseCase: GetCurrentUserUseCase(authRepository),
      signOutUseCase: SignOutUseCase(authRepository),
      authRepository: authRepository,
    );

    profileCubit = ProfileCubit(
      getUserProfileUseCase: GetUserProfileUseCase(profileRepository),
      saveUserProfileUseCase: SaveUserProfileUseCase(profileRepository),
      profileSignOutUseCase: ProfileSignOutUseCase(profileRepository),
      auth: _firebaseAuth,
    );

    _initialized = true;
  }

  ProfileCubit createProfileCubit() {
    return ProfileCubit(
      getUserProfileUseCase: GetUserProfileUseCase(profileRepository),
      saveUserProfileUseCase: SaveUserProfileUseCase(profileRepository),
      profileSignOutUseCase: ProfileSignOutUseCase(profileRepository),
    );
  }

  CouponsCubit createCouponsCubit() {
    return CouponsCubit(
      couponsRepository: couponsRepository,
      auth: _firebaseAuth,
    );
  }

  FavouritesCubit createFavouritesCubit() {
    return FavouritesCubit(
      favouritesRepository: favouritesRepository,
      doctorsRepository: doctorsRepository,
    );
  }

  TopSpecialistCubit createTopSpecialistCubit({String? specialty}) {
    return TopSpecialistCubit(
      doctorsRepository: doctorsRepository,
      initialSpecialty: specialty,
    );
  }
}
