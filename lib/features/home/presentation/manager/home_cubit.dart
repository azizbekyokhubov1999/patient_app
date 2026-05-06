import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../domain/entities/appointment.dart';
import '../../domain/entities/doctor.dart';
import '../../domain/entities/doctor_review.dart';
import '../../domain/entities/hospital.dart';
import '../../domain/entities/hospital_contact_person.dart';
import '../../domain/entities/hospital_review.dart';
import '../../domain/entities/service.dart';
import '../../domain/entities/working_hours_entry.dart';
import 'home_state.dart';

const String _kLoremAbout =
    'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.';

const String _kMapPlaceholder =
    'https://images.unsplash.com/photo-1524661135-423995f22d0b?auto=format&fit=crop&w=1200&q=80';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit()
    : super(
        HomeState(
          appointments: const [
            Appointment(
              doctorName: 'Dr. Jenny William',
              specialty: 'Dentist',
              rating: 4.9,
              dateLabel: 'Tuesday, 20 January',
              timeLabel: '09:00 - 10:00',
            ),
            Appointment(
              doctorName: 'Dr. Amelia Collins',
              specialty: 'Cardiologist',
              rating: 4.8,
              dateLabel: 'Wednesday, 21 January',
              timeLabel: '11:00 - 12:00',
            ),
            Appointment(
              doctorName: 'Dr. James Miller',
              specialty: 'Neurologist',
              rating: 5.0,
              dateLabel: 'Thursday, 22 January',
              timeLabel: '14:00 - 15:00',
            ),
          ],
          services: const [
            Service(title: 'Dentist', icon: LucideIcons.stethoscope),
            Service(title: 'Cardiology', icon: LucideIcons.heartPulse),
            Service(title: 'Neurology', icon: LucideIcons.brain),
            Service(title: 'Orthopedic', icon: LucideIcons.bone),
          ],
          hospitals: const [
            Hospital(
              id: 'hospital-unity-health',
              name: 'Unity Health Hospital',
              rating: 4.8,
              tags: 'Dentist, Ophthalmologist, Otology',
              address: '6391 Elgin St. Celina, Delaware 10299',
              distance: '3.5 Miles',
              eta: '15 Min',
              imageUrl:
                  'https://images.unsplash.com/photo-1579684385127-1ef15d508118?auto=format&fit=crop&w=1200&q=80',
              description: _kLoremAbout,
              treatments: [
                'Dental Treatments',
                'Eye Treatments',
                'Ear Treatments',
              ],
              specialists: <Doctor>[],
              timings: {
                'Monday': '09:00 - 18:00',
                'Tuesday': '09:00 - 18:00',
                'Wednesday': '09:00 - 18:00',
                'Thursday': '09:00 - 18:00',
                'Friday': '09:00 - 18:00',
                'Saturday': '09:00 - 14:00',
                'Sunday': 'Closed',
              },
              contactPerson: HospitalContactPerson(
                name: 'Amelia Clarke',
                role: 'Receptionist',
                avatarUrl:
                    'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=300&q=80',
              ),
              images: [
                'https://images.unsplash.com/photo-1579684385127-1ef15d508118?auto=format&fit=crop&w=1200&q=80',
                'https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?auto=format&fit=crop&w=1200&q=80',
                'https://images.unsplash.com/photo-1631815588090-d4bfec5b1ccb?auto=format&fit=crop&w=1200&q=80',
                'https://images.unsplash.com/photo-1631248055158-edec7a3c072b?auto=format&fit=crop&w=1200&q=80',
                'https://images.unsplash.com/photo-1584982751601-97dcc096659c?auto=format&fit=crop&w=1200&q=80',
              ],
              galleryImages: [
                'https://images.unsplash.com/photo-1579684385127-1ef15d508118?auto=format&fit=crop&w=1200&q=80',
                'https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?auto=format&fit=crop&w=1200&q=80',
                'https://images.unsplash.com/photo-1631815588090-d4bfec5b1ccb?auto=format&fit=crop&w=1200&q=80',
                'https://images.unsplash.com/photo-1631248055158-edec7a3c072b?auto=format&fit=crop&w=1200&q=80',
                'https://images.unsplash.com/photo-1584982751601-97dcc096659c?auto=format&fit=crop&w=1200&q=80',
                'https://images.unsplash.com/photo-1505751172876-fa1923c5c528?auto=format&fit=crop&w=1200&q=80',
                'https://images.unsplash.com/photo-1486825586573-7131f7991bdd?auto=format&fit=crop&w=1200&q=80',
                'https://images.unsplash.com/photo-1516549655169-df83a0774514?auto=format&fit=crop&w=1200&q=80',
              ],
              reviews: [
                HospitalReview(
                  userName: 'Leslie Alexander',
                  userAvatar:
                      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=200&q=80',
                  rating: 5.0,
                  comment:
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt.',
                  createdAt: '1 months ago',
                  isVerified: true,
                ),
                HospitalReview(
                  userName: 'Jenny Wilson',
                  userAvatar:
                      'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&w=200&q=80',
                  rating: 5.0,
                  comment:
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt.',
                  createdAt: '2 months ago',
                  isVerified: true,
                  reviewImages: [
                    'https://images.unsplash.com/photo-1606811971618-4486d14f3f99?auto=format&fit=crop&w=400&q=80',
                    'https://plus.unsplash.com/premium_photo-1664475450083-5c9eef17a191?w=500&q=80',
                  ],
                ),
              ],
              latitude: 39.7459,
              longitude: -75.0291,
              mapImageUrl: _kMapPlaceholder,
            ),
            Hospital(
              id: 'hospital-elite-care',
              name: 'Elite Care Center',
              rating: 4.7,
              tags: 'Cardiology, Pediatric',
              address: '8502 Preston Rd. Inglewood, Maine',
              distance: '2.1 Miles',
              eta: '9 Min',
              imageUrl:
                  'https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?auto=format&fit=crop&w=1200&q=80',
              description: _kLoremAbout,
              treatments: [
                'Cardiology Treatments',
                'General Checkups',
                'Pediatric Care',
              ],
              specialists: <Doctor>[],
              timings: {
                'Monday': '08:30 - 17:30',
                'Tuesday': '08:30 - 17:30',
                'Wednesday': '08:30 - 17:30',
                'Thursday': '08:30 - 17:30',
                'Friday': '08:30 - 17:30',
                'Saturday': '10:00 - 14:00',
                'Sunday': 'Closed',
              },
              contactPerson: HospitalContactPerson(
                name: 'Daniel Foster',
                role: 'Front Desk',
                avatarUrl:
                    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=300&q=80',
              ),
              images: [
                'https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?auto=format&fit=crop&w=1200&q=80',
                'https://images.unsplash.com/photo-1516549655169-df83a0774514?auto=format&fit=crop&w=1200&q=80',
                'https://images.unsplash.com/photo-1486825586573-7131f7991bdd?auto=format&fit=crop&w=1200&q=80',
                'https://images.unsplash.com/photo-1576091160550-2173dba999ef?auto=format&fit=crop&w=1200&q=80',
                'https://images.unsplash.com/photo-1538108149393-fbbd81895907?auto=format&fit=crop&w=1200&q=80',
              ],
              galleryImages: [
                'https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?auto=format&fit=crop&w=1200&q=80',
                'https://images.unsplash.com/photo-1516549655169-df83a0774514?auto=format&fit=crop&w=1200&q=80',
                'https://images.unsplash.com/photo-1486825586573-7131f7991bdd?auto=format&fit=crop&w=1200&q=80',
                'https://images.unsplash.com/photo-1576091160550-2173dba999ef?auto=format&fit=crop&w=1200&q=80',
                'https://images.unsplash.com/photo-1538108149393-fbbd81895907?auto=format&fit=crop&w=1200&q=80',
                'https://images.unsplash.com/photo-1505751172876-fa1923c5c528?auto=format&fit=crop&w=1200&q=80',
              ],
              reviews: <HospitalReview>[],
              latitude: 43.6572,
              longitude: -70.2568,
              mapImageUrl: _kMapPlaceholder,
            ),
          ],
          doctors: const [
            Doctor(
              name: 'Dr. Jenny William',
              specialty: 'Dentist',
              rating: 4.9,
              reviewsCount: 5000,
              imageUrl:
                  'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?auto=format&fit=crop&w=800&q=80',
              about: _kLoremAbout,
              patientsCount: 3500,
              experienceYears: 6,
              workingHours: [
                WorkingHoursEntry('Monday - Friday', '09:00 am - 09:30 pm'),
                WorkingHoursEntry('Saturday - Sunday', '09:00 am - 01:00 pm'),
              ],
              address: '6391 Elgin St. Celina, Delaware 10299',
              latitude: 39.7459,
              longitude: -75.0291,
              mapImageUrl: _kMapPlaceholder,
              patientReviews: [
                DoctorReview(
                  authorName: 'Leslie Alexander',
                  avatarUrl:
                      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=200&q=80',
                  verified: true,
                  timeAgo: '1 months ago',
                  text:
                      'Dr. William is very professional and caring. The clinic is clean and the staff is friendly. Highly recommend for anyone looking for quality dental care.',
                  rating: 5.0,
                ),
                DoctorReview(
                  authorName: 'Jenny Wilson',
                  avatarUrl:
                      'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&w=200&q=80',
                  verified: true,
                  timeAgo: '2 months ago',
                  text:
                      'Excellent experience from start to finish. Clear explanations and painless treatment. Will definitely come back.',
                  rating: 5.0,
                  imageUrls: [
                    'https://images.unsplash.com/photo-1606811971618-4486d14f3f99?auto=format&fit=crop&w=400&q=80',
                    'https://plus.unsplash.com/premium_photo-1664475450083-5c9eef17a191?w=500&q=80',
                  ],
                ),
              ],
            ),
            Doctor(
              name: 'Dr. Sophia Rossi',
              specialty: 'Otology Specialist',
              rating: 4.9,
              reviewsCount: 53,
              imageUrl:
                  'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?auto=format&fit=crop&w=800&q=80',
              about: _kLoremAbout,
              patientsCount: 1200,
              experienceYears: 8,
              workingHours: [
                WorkingHoursEntry('Monday - Friday', '10:00 am - 06:00 pm'),
                WorkingHoursEntry('Saturday', '10:00 am - 02:00 pm'),
              ],
              address: '8502 Preston Rd. Inglewood, Maine',
              latitude: 40.7128,
              longitude: -74.0060,
              mapImageUrl: _kMapPlaceholder,
              patientReviews: [
                DoctorReview(
                  authorName: 'Courtney Henry',
                  avatarUrl:
                      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
                  verified: true,
                  timeAgo: '3 weeks ago',
                  text: 'Very knowledgeable specialist. Great follow-up care.',
                  rating: 4.8,
                ),
              ],
            ),
            Doctor(
              name: 'Dr. Robert Fox',
              specialty: 'Dentist',
              rating: 5.0,
              reviewsCount: 12,
              imageUrl:
                  'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?auto=format&fit=crop&w=800&q=80',
              about: _kLoremAbout,
              patientsCount: 890,
              experienceYears: 4,
              workingHours: [
                WorkingHoursEntry('Monday - Saturday', '08:00 am - 08:00 pm'),
              ],
              address: '4517 Washington Ave. Manchester, Kentucky 39495',
              latitude: 37.1282,
              longitude: -84.0833,
              mapImageUrl: _kMapPlaceholder,
              patientReviews: <DoctorReview>[],
            ),
            Doctor(
              name: 'Dr. James Chen',
              specialty: 'Radiologist Specialist',
              rating: 4.9,
              reviewsCount: 49,
              imageUrl:
                  'https://images.unsplash.com/photo-1622253692010-333f2da6031d?auto=format&fit=crop&w=800&q=80',
              about: _kLoremAbout,
              patientsCount: 2100,
              experienceYears: 10,
              workingHours: [
                WorkingHoursEntry('Monday - Friday', '08:30 am - 05:30 pm'),
              ],
              address: '2972 Westheimer Rd. Santa Ana, Illinois 85486',
              latitude: 33.7455,
              longitude: -117.8677,
              mapImageUrl: _kMapPlaceholder,
              patientReviews: <DoctorReview>[],
            ),
            Doctor(
              name: 'Dr. Robert Martinez',
              specialty: 'Rhinologist',
              rating: 5.0,
              reviewsCount: 24,
              imageUrl:
                  'https://images.unsplash.com/photo-1537368910025-700350fe46c7?auto=format&fit=crop&w=800&q=80',
              about: _kLoremAbout,
              patientsCount: 600,
              experienceYears: 5,
              workingHours: [
                WorkingHoursEntry('Monday - Friday', '09:00 am - 05:00 pm'),
              ],
              address: '2464 Royal Ln. Mesa, New Jersey 45463',
              latitude: 33.4152,
              longitude: -111.8315,
              mapImageUrl: _kMapPlaceholder,
              patientReviews: <DoctorReview>[],
            ),
          ],
          selectedServiceIndex: 0,
          currentAppointmentIndex: 0,
        ),
      );

  void selectService(int index) {
    emit(state.copyWith(selectedServiceIndex: index));
  }

  void updateCurrentAppointment(int index) {
    emit(state.copyWith(currentAppointmentIndex: index));
  }
}
