import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/app_dependencies.dart';
import 'doctor_details_page.dart';

/// Loads a doctor document by Firestore id, then shows [DoctorDetailsPage].
class DoctorDetailsLoaderPage extends StatefulWidget {
  const DoctorDetailsLoaderPage({required this.doctorId, super.key});

  final String doctorId;

  @override
  State<DoctorDetailsLoaderPage> createState() => _DoctorDetailsLoaderPageState();
}

class _DoctorDetailsLoaderPageState extends State<DoctorDetailsLoaderPage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AppDependencies.instance.doctorsRepository
          .getDoctorById(widget.doctorId),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final doctor = snapshot.data;
        if (doctor == null) {
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

        return DoctorDetailsPage(doctor: doctor);
      },
    );
  }
}
