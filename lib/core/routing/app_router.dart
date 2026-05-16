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
import '../../features/booking/presentation/pages/appointments_page.dart';
import '../../features/booking/presentation/pages/patient_details_page.dart';
import '../../features/booking/presentation/pages/booking_success_page.dart';
import '../../features/booking/presentation/models/e_receipt_args.dart';
import '../../features/booking/presentation/pages/e_receipt_page.dart';
import '../../features/booking/presentation/pages/payment_methods_page.dart';
import '../../features/booking/presentation/pages/review_summary_page.dart';
import '../../features/booking/presentation/pages/select_package_page.dart';
import '../../features/chat/presentation/pages/chat_page.dart';
import '../../features/explore/presentation/pages/explore_page.dart';
import '../../features/explore/presentation/pages/hospital_details_page.dart';
import '../../features/home/domain/entities/get_direction_args.dart';
import '../../features/home/presentation/manager/nearby_hospitals_cubit.dart';
import '../../features/home/presentation/models/hospital_detail_args.dart';
import '../../features/home/presentation/pages/get_direction_page.dart';
import '../../features/home/presentation/pages/nearby_hospitals_page.dart';
import '../../features/explore/presentation/pages/leave_review_hospital_page.dart';
import '../../features/home/domain/entities/doctor.dart';
import '../../features/home/domain/entities/hospital.dart';
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
          return GetDirectionPage(args: extra);
        },
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
          return LeaveReviewDoctorPage(doctor: extra);
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
                path: AppPaths.booking,
                builder: (context, state) => const AppointmentsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppPaths.chat,
                builder: (context, state) => const ChatPage(),
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
