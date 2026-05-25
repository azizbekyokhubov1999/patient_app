import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/app_dependencies.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/manager/auth_cubit.dart';
import 'features/notification/data/datasources/notification_remote_data_source.dart';
import 'features/notification/data/repositories/notification_repository_impl.dart';
import 'features/notification/presentation/manager/notification_cubit.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  AppDependencies.instance.init();

  runApp(const PatientApp());
}

class PatientApp extends StatelessWidget {
  const PatientApp({super.key});

  @override
  Widget build(BuildContext context) {
    final deps = AppDependencies.instance;

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(
          value: deps.authCubit,
        ),
        BlocProvider<NotificationCubit>(
          create: (context) => NotificationCubit(
            NotificationRepositoryImpl(NotificationRemoteDataSourceImpl()),
          )..loadNotifications(),
        ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Patient App',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
