import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/complete_profile_page.dart';
import '../../features/auth/presentation/pages/create_account_page.dart';
import '../../features/auth/presentation/pages/enter_location_page.dart';
import '../../features/auth/presentation/pages/new_password_page.dart';
import '../../features/auth/presentation/pages/notification_access_page.dart';
import '../../features/auth/presentation/pages/onboarding_screen.dart';
import '../../features/auth/presentation/pages/signin_page.dart';
import '../../features/auth/presentation/pages/splash_screen.dart';
import '../../features/auth/presentation/pages/verify_code_page.dart';
import '../../features/auth/presentation/pages/welcome_screen.dart';
import '../../features/auth/presentation/pages/your_location_page.dart';
import '../../features/booking/presentation/models/booking_route_args.dart';
import '../../features/booking/presentation/pages/appointment_page.dart';
import '../../features/booking/presentation/pages/add_card_page.dart';
import '../../features/booking/presentation/manager/cancel_booking_cubit.dart';
import '../../features/booking/presentation/manager/cancelled_appointments_cubit.dart';
import '../../features/booking/presentation/manager/completed_appointments_cubit.dart';
import '../../features/booking/presentation/manager/upcoming_appointments_cubit.dart';
import '../../features/booking/presentation/pages/appointments_page.dart';
import '../../features/booking/presentation/pages/cancel_booking_page.dart';
import '../../features/booking/presentation/pages/consultation_ended_page.dart';
import '../../features/booking/presentation/models/consultation_ended_args.dart';
import '../../features/booking/presentation/pages/patient_details_page.dart';
import '../../features/booking/presentation/pages/booking_success_page.dart';
import '../../features/booking/presentation/models/e_receipt_args.dart';
import '../../features/booking/presentation/pages/e_receipt_page.dart';
import '../../features/booking/presentation/pages/payment_methods_page.dart';
import '../../features/booking/presentation/pages/review_summary_page.dart';
import '../../features/booking/presentation/pages/select_package_page.dart';
import '../../features/chat/data/models/chat_model.dart';
import '../../features/chat/presentation/manager/chat_cubit.dart';
import '../../features/chat/presentation/manager/call_cubit.dart';
import '../../features/chat/presentation/manager/chat_detail_cubit.dart';
import '../../features/chat/presentation/models/call_session_args.dart';
import '../../features/chat/presentation/pages/chat_detail_page.dart';
import '../../features/chat/presentation/pages/chat_list_page.dart';
import '../../features/chat/presentation/pages/video_call_page.dart';
import '../../features/chat/presentation/pages/voice_call_page.dart';
import '../../features/explore/presentation/pages/explore_page.dart';
import '../../features/explore/presentation/pages/hospital_details_page.dart';
import '../../features/home/presentation/manager/get_direction_args.dart';
import '../../features/home/presentation/manager/get_direction_2_cubit.dart';
import '../../features/home/presentation/manager/get_direction_cubit.dart';
import '../../features/home/presentation/manager/nearby_hospitals_cubit.dart';
import '../../features/home/presentation/models/hospital_detail_args.dart';
import '../../features/home/presentation/pages/get_direction_2_page.dart';
import '../../features/home/presentation/pages/get_direction_page.dart';
import '../../features/home/presentation/pages/you_have_arrived_page.dart';
import '../../features/home/presentation/pages/nearby_hospitals_page.dart';
import '../../features/explore/presentation/pages/leave_review_hospital_page.dart';
import '../../features/home/domain/entities/doctor.dart';
import '../../features/home/domain/entities/doctor_review.dart';
import '../../features/home/domain/entities/hospital.dart';
import '../../features/home/domain/entities/working_hours_entry.dart';
import '../../features/home/presentation/pages/doctor_details_page.dart';
import '../../features/home/presentation/pages/leave_review_doctor_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/home/presentation/pages/filter_page.dart';
import '../../features/home/presentation/pages/search_page.dart';
import '../../features/home/presentation/pages/services_page.dart';
import '../../features/home/presentation/manager/top_specialist_cubit.dart';
import '../../features/home/presentation/pages/top_specialist_page.dart';
import '../../features/home/presentation/manager/upcoming_appointment_cubit.dart';
import '../../features/home/presentation/models/appointment_detail_args.dart';
import '../../features/home/presentation/pages/appointment_detail_page.dart';
import '../../features/home/presentation/pages/upcoming_appointment_page.dart';
import '../../features/home/presentation/models/filter_args.dart';
import '../../features/home/domain/entities/filter_result.dart';
import '../../features/main_navigation/presentation/pages/main_wrapper_page.dart';
import '../../features/notification/presentation/pages/notification_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../constants/app_paths.dart';

abstract final class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppPaths.splash,
    routes: [
      GoRoute(
        path: AppPaths.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppPaths.welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: AppPaths.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppPaths.signUp,
        builder: (context, state) => const CreateAccountPage(),
      ),
      GoRoute(
        path: AppPaths.signIn,
        builder: (context, state) => const SignInPage(),
      ),
      GoRoute(
        path: AppPaths.createAccount,
        builder: (context, state) => const CreateAccountPage(),
      ),
      GoRoute(
        path: AppPaths.verifyCode,
        builder: (context, state) => const VerifyCodePage(),
      ),
      GoRoute(
        path: AppPaths.newPassword,
        builder: (context, state) => const NewPasswordPage(),
      ),
      GoRoute(
        path: AppPaths.completeProfile,
        builder: (context, state) => const CompleteProfilePage(),
      ),
      GoRoute(
        path: AppPaths.yourLocation,
        builder: (context, state) => const YourLocationPage(),
      ),
      GoRoute(
        path: AppPaths.enterLocation,
        builder: (context, state) => const EnterLocationPage(),
      ),
      GoRoute(
        path: AppPaths.notificationAccess,
        builder: (context, state) => const NotificationAccessPage(),
      ),
      GoRoute(
        path: AppPaths.auth,
        builder: (context, state) => const SignInPage(),
      ),
      GoRoute(
        path: AppPaths.search,
        builder: (context, state) => const SearchPage(),
      ),
      GoRoute(
        path: AppPaths.services,
        builder: (context, state) => const ServicesPage(),
      ),
      GoRoute(
        path: AppPaths.topSpecialist,
        builder: (context, state) {
          final specialty = state.extra as String?;
          return BlocProvider(
            create: (_) => TopSpecialistCubit(initialSpecialty: specialty)
              ..loadTopSpecialists(),
            child: TopSpecialistPage(initialSpecialty: specialty),
          );
        },
      ),
      GoRoute(
        path: AppPaths.upcomingAppointments,
        builder: (context, state) => BlocProvider(
          create: (_) => UpcomingAppointmentCubit()..loadUpcomingAppointments(),
          child: const UpcomingAppointmentPage(),
        ),
      ),
      GoRoute(
        path: AppPaths.appointmentDetail,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is! AppointmentDetailArgs) {
            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => context.pop(),
                ),
              ),
              body: const Center(child: Text('Appointment not found')),
            );
          }
          return AppointmentDetailPage(args: extra);
        },
      ),
      GoRoute(
        path: AppPaths.nearbyHospitals,
        builder: (context, state) => BlocProvider(
          create: (_) => NearbyHospitalsCubit()..loadNearbyHospitals(),
          child: const NearbyHospitalsPage(),
        ),
      ),
      GoRoute(
        path: AppPaths.getDirection,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is! GetDirectionArgs) {
            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => context.pop(),
                ),
              ),
              body: const Center(child: Text('Directions not available')),
            );
          }
          return BlocProvider(
            create: (_) => GetDirectionCubit()..loadMapData(extra.geoPoint),
            child: GetDirectionPage(args: extra),
          );
        },
      ),
      GoRoute(
        path: AppPaths.getDirection2,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is! GetDirectionArgs) {
            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => context.pop(),
                ),
              ),
              body: const Center(child: Text('Route not available')),
            );
          }
          return BlocProvider(
            create: (_) => GetDirection2Cubit(extra)..initialize(),
            child: GetDirection2Page(args: extra),
          );
        },
      ),
      GoRoute(
        path: AppPaths.youHaveArrived,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const YouHaveArrivedPage(),
        ),
      ),
      GoRoute(
        path: AppPaths.hospitalDetail,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is! HospitalDetailArgs) {
            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => context.pop(),
                ),
              ),
              body: const Center(child: Text('Hospital not found')),
            );
          }
          final hospital = extra.hospital ??
              HospitalDetailsPage.fallbackById(extra.hospitalId);
          return HospitalDetailsPage(hospital: hospital);
        },
      ),
      GoRoute(
        path: AppPaths.notifications,
        builder: (context, state) => const NotificationPage(),
      ),
      GoRoute(
        path: AppPaths.filter,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is FilterArgs) {
            return FilterPage(args: extra);
          }
          if (extra is FilterResult) {
            return FilterPage(args: FilterArgs(initialFilter: extra));
          }
          return const FilterPage();
        },
      ),
      GoRoute(
        path: AppPaths.doctorDetails,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is! Doctor) {
            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => context.pop(),
                ),
              ),
              body: const Center(child: Text('Doctor not found')),
            );
          }
          return DoctorDetailsPage(doctor: extra);
        },
      ),
      GoRoute(
        path: AppPaths.hospitalDetails,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is Hospital) {
            return HospitalDetailsPage(hospital: extra);
          }
          if (extra is String) {
            return HospitalDetailsPage(
              hospital: HospitalDetailsPage.fallbackById(extra),
            );
          }
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => context.pop(),
              ),
            ),
            body: const Center(child: Text('Hospital not found')),
          );
        },
      ),
      GoRoute(
        path: AppPaths.leaveReviewHospital,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is! Hospital) {
            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => context.pop(),
                ),
              ),
              body: const Center(child: Text('Hospital not found')),
            );
          }
          return LeaveReviewHospitalPage(hospital: extra);
        },
      ),
      GoRoute(
        name: 'leave-review-doctor',
        path: AppPaths.leaveReviewDoctor,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is Doctor) {
            return LeaveReviewDoctorPage(doctor: extra);
          }
          if (extra is Map<String, dynamic>) {
            final doctor = extra['doctor'];
            if (doctor is Doctor) {
              return LeaveReviewDoctorPage(doctor: doctor);
            }
            return LeaveReviewDoctorPage(
              doctor: _doctorFromLeaveReviewArgs(extra),
            );
          }
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => context.pop(),
              ),
            ),
            body: const Center(child: Text('Doctor not found')),
          );
        },
      ),
      GoRoute(
        name: 'book-appointment',
        path: AppPaths.bookAppointment,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is Doctor) {
            return AppointmentPage(doctor: extra);
          }
          if (extra is Hospital) {
            return AppointmentPage(hospital: extra);
          }
          if (extra is String) {
            return AppointmentPage(doctorId: extra);
          }
          if (extra is BookingRouteArgs) {
            return AppointmentPage(
              doctor: extra.doctor,
              doctorId: extra.doctorId,
              hospital: extra.hospital,
              selectedSpecialist: extra.selectedSpecialist,
            );
          }
          return const AppointmentPage();
        },
      ),
      GoRoute(
        path: AppPaths.selectPackage,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is! SelectPackageArgs) {
            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => context.pop(),
                ),
              ),
              body: const Center(child: Text('Booking data not found')),
            );
          }
          return SelectPackagePage(args: extra);
        },
      ),
      GoRoute(
        path: AppPaths.patientDetails,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is! PatientDetailsArgs) {
            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => context.pop(),
                ),
              ),
              body: const Center(child: Text('Patient details not found')),
            );
          }
          return PatientDetailsPage(args: extra);
        },
      ),
      GoRoute(
        path: AppPaths.paymentMethod,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is! PaymentMethodArgs) {
            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => context.pop(),
                ),
              ),
              body: const Center(child: Text('Payment data not found')),
            );
          }
          return PaymentMethodsPage(args: extra);
        },
      ),
      GoRoute(
        path: AppPaths.addCard,
        builder: (context, state) => const AddCardPage(),
      ),
      GoRoute(
        path: AppPaths.reviewSummary,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is! ReviewSummaryArgs) {
            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => context.pop(),
                ),
              ),
              body: const Center(child: Text('Review summary data not found')),
            );
          }
          return ReviewSummaryPage(args: extra);
        },
      ),
      GoRoute(
        path: AppPaths.bookingSuccess,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is! BookingSuccessArgs) {
            return BookingSuccessPage(
              doctorName: 'Dr. Jenny William',
              receipt: EReceiptArgs(
                appointmentId: '#DC000000',
                patientName: 'Patient',
                patientPhone: '+1 (208) 555-0112',
                doctorName: 'Dr. Jenny William',
                packageType: 'Messaging',
                packageDuration: '30 minutes',
                bookingDate: DateTime.now(),
                bookingTime: '11:00',
                subTotal: 20,
                discount: 0,
                totalAmount: 20,
              ),
            );
          }
          return BookingSuccessPage(
            doctorName: extra.doctorName,
            receipt: extra.receipt,
          );
        },
      ),
      GoRoute(
        path: AppPaths.eReceipt,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is! EReceiptArgs) {
            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => context.pop(),
                ),
              ),
              body: const Center(child: Text('Receipt data not found')),
            );
          }
          return EReceiptPage(args: extra);
        },
      ),
      GoRoute(
        path: AppPaths.cancelBooking,
        builder: (context, state) {
          final appointmentId = state.extra as String? ?? '';
          return BlocProvider(
            create: (_) => CancelBookingCubit(),
            child: CancelBookingPage(appointmentId: appointmentId),
          );
        },
      ),
      GoRoute(
        path: AppPaths.consultationEnded,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is! ConsultationEndedArgs) {
            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => context.go(AppPaths.home),
                ),
              ),
              body: const Center(child: Text('Consultation data not found')),
            );
          }
          return ConsultationEndedPage(args: extra);
        },
      ),
      GoRoute(
        path: AppPaths.chatDetail,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is! ChatModel) {
            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => context.pop(),
                ),
              ),
              body: const Center(child: Text('Chat not found')),
            );
          }
          final uid =
              FirebaseAuth.instance.currentUser?.uid ?? 'patient-demo';
          return BlocProvider(
            create: (_) => ChatDetailCubit(
              currentUserId: uid,
              currentUserName: 'Jennifer Aaker',
              peerId: extra.doctorId,
              peerName: extra.doctorName,
            )..listenToMessages(extra.chatId),
            child: ChatDetailPage(chat: extra),
          );
        },
      ),
      GoRoute(
        path: AppPaths.videoCall,
        builder: (context, state) {
          final args = _resolveCallSessionArgs(
            state.extra,
            defaultVideo: true,
          );
          return BlocProvider(
            create: (_) => CallCubit(
              initialVideoOn: args.initialVideoOn,
              initialDurationSeconds: args.initialDurationSeconds,
              initialMuted: args.initialMuted,
              initialSpeakerOn: args.initialSpeakerOn,
            ),
            child: VideoCallPage(args: args),
          );
        },
      ),
      GoRoute(
        path: AppPaths.voiceCall,
        builder: (context, state) {
          final args = _resolveCallSessionArgs(
            state.extra,
            defaultVideo: false,
          );
          return BlocProvider(
            create: (_) => CallCubit(
              initialVideoOn: args.initialVideoOn,
              initialDurationSeconds: args.initialDurationSeconds,
              initialMuted: args.initialMuted,
              initialSpeakerOn: args.initialSpeakerOn,
            ),
            child: VoiceCallPage(args: args),
          );
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainWrapperPage(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppPaths.home,
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppPaths.explore,
                builder: (context, state) => const ExplorePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppPaths.appointments,
                builder: (context, state) {
                  final tabIndex = state.extra is int ? state.extra as int : 0;
                  return MultiBlocProvider(
                    providers: [
                      BlocProvider(
                        create: (_) => UpcomingAppointmentsCubit()
                          ..fetchUpcomingAppointments(),
                      ),
                      BlocProvider(
                        create: (_) => CompletedAppointmentsCubit()
                          ..fetchCompletedAppointments(),
                      ),
                      BlocProvider(
                        create: (_) => CancelledAppointmentsCubit()
                          ..fetchCancelledAppointments(),
                      ),
                    ],
                    child: AppointmentsPage(initialTabIndex: tabIndex),
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppPaths.chat,
                builder: (context, state) => BlocProvider(
                  create: (_) => ChatCubit()..streamChats(),
                  child: const ChatListPage(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppPaths.profile,
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

CallSessionArgs _resolveCallSessionArgs(
  Object? extra, {
  required bool defaultVideo,
}) {
  if (extra is CallSessionArgs) return extra;
  if (extra is ChatModel) {
    return CallSessionArgs.fromChat(extra, video: defaultVideo);
  }
  return CallSessionArgs(
    appointmentId: 'call-demo',
    doctorId: 'doc-sheila',
    doctorName: 'Dr. Sheila Lemke',
    doctorSpecialty: 'Dentist',
    doctorAvatar: 'https://picsum.photos/200?sheila',
    initialVideoOn: defaultVideo,
  );
}

Doctor _doctorFromLeaveReviewArgs(Map<String, dynamic> args) {
  final doctor = args['doctor'];
  if (doctor is Doctor) return doctor;

  return Doctor(
    id: args['doctorId'] as String?,
    name: args['doctorName'] as String? ?? 'Doctor',
    specialty: args['doctorSpecialty'] as String? ?? '',
    rating: (args['doctorRating'] as num?)?.toDouble() ?? 0,
    reviewsCount: 0,
    imageUrl: args['doctorImageUrl'] as String? ?? '',
    about: '',
    patientsCount: 0,
    experienceYears: 0,
    workingHours: const [
      WorkingHoursEntry('Monday - Friday', '09:00 am - 06:00 pm'),
    ],
    address: '',
    latitude: 0,
    longitude: 0,
    patientReviews: const <DoctorReview>[],
  );
}
