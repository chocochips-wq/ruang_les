import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// Firebase
import 'firebase_options.dart';

// Core
import 'core/utils/routes.dart';
import 'core/utils/colors.dart';
import 'core/services/firestore_service.dart';

// Repositories
import 'data/repositories/user_repository.dart';
import 'data/repositories/student_repository.dart';
import 'data/repositories/parent_repository.dart';
import 'data/repositories/teacher_repository.dart';
import 'data/repositories/class_repository.dart';
import 'data/repositories/payment_repository.dart';
import 'data/repositories/session_repository.dart';
import 'data/repositories/forum_repository.dart';
import 'data/repositories/progress_repository.dart';
import 'data/repositories/quiz_repository.dart';

// Providers
import 'features/auth/providers/auth_provider.dart';
import 'features/student/providers/student_provider.dart';
import 'features/parent/providers/parent_provider.dart';
import 'features/teacher/providers/teacher_provider.dart';

import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Date Formatting for Indonesian locale
  await initializeDateFormatting('id_ID', null);

  // Optional: Initialize Firestore collections dengan data sample
  // await FirestoreService().initializeCollections();

  runApp(
    MultiProvider(
      providers: [
        // Repositories
        Provider<UserRepository>(
          create: (_) => UserRepository(),
        ),
        Provider<StudentRepository>(
          create: (_) => StudentRepository(),
        ),
        Provider<ParentRepository>(
          create: (_) => ParentRepository(),
        ),
        Provider<TeacherRepository>(
          create: (_) => TeacherRepository(),
        ),
        Provider<ClassRepository>(
          create: (_) => ClassRepository(),
        ),
        Provider<PaymentRepository>(
          create: (_) => PaymentRepository(),
        ),
        Provider<SessionRepository>(
          create: (_) => SessionRepository(),
        ),
        Provider<ForumRepository>(
          create: (_) => ForumRepository(),
        ),
        Provider<ProgressRepository>(
          create: (_) => ProgressRepository(),
        ),
        Provider<QuizRepository>(
          create: (_) => QuizRepository(),
        ),

        // Providers/State Management
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(
            context.read<UserRepository>(),
          ),
        ),

        // Student Provider
        ChangeNotifierProxyProvider<AuthProvider, StudentProvider>(
          create: (context) => StudentProvider(
            context.read<StudentRepository>(),
            context.read<ClassRepository>(),
            context.read<SessionRepository>(),
            context.read<ProgressRepository>(),
          ),
          update: (context, auth, studentProvider) {
            if (auth.isAuthenticated && auth.user?.role == 'student') {
              studentProvider?.loadStudentByUserId(auth.user!.userId!);
            } else {
              studentProvider?.clearStudent();
            }
            return studentProvider!;
          },
        ),

        // Parent Provider
        ChangeNotifierProxyProvider<AuthProvider, ParentProvider>(
          create: (context) => ParentProvider(
            context.read<ParentRepository>(),
            context.read<StudentRepository>(),
            context.read<PaymentRepository>(),
            context.read<ClassRepository>(),
            context.read<UserRepository>(),
          ),
          update: (context, auth, parentProvider) {
            if (auth.isAuthenticated && auth.user?.role == 'parent') {
              parentProvider?.loadParentData(auth.user!.userId!);
            } else {
              parentProvider?.clearParentData();
            }
            return parentProvider!;
          },
        ),

        // Teacher Provider
        ChangeNotifierProxyProvider<AuthProvider, TeacherProvider>(
          create: (context) => TeacherProvider(
            context.read<TeacherRepository>(),
            context.read<ClassRepository>(),
            context.read<StudentRepository>(),
            context.read<SessionRepository>(),
            context.read<PaymentRepository>(),
          ),
          update: (context, auth, teacherProvider) {
            if (auth.isAuthenticated && auth.user?.role == 'teacher') {
              teacherProvider?.loadTeacherData(auth.user!.userId!);
            } else {
              teacherProvider?.clearTeacherData();
            }
            return teacherProvider!;
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ruang Les by Ismaturrohmah',
      debugShowCheckedModeBanner: false,

      // DevicePreview dihapus untuk produksi
      useInheritedMediaQuery: true,
      // ...existing code...

      theme: ThemeData(
        primaryColor: AppColors.primary,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Poppins',
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          centerTitle: true,
        ),
        textTheme: const TextTheme(
          headlineSmall: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      ),

      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
