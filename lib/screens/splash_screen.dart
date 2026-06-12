import 'package:chatmate/blocs/auth/auth_bloc.dart';
import 'package:chatmate/blocs/auth/auth_event.dart';
import 'package:chatmate/blocs/auth/auth_state.dart';
import 'package:chatmate/screens/home_screen.dart';
import 'package:chatmate/screens/login_screen.dart';
import 'package:chatmate/screens/main_screen.dart';
import 'package:chatmate/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Small delay to let native splash finish smoothly
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      context.read<AuthBloc>().add(CheckAuthStatusEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),

      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (!mounted) return;

          if (state is AuthenticatedState) {
            final user = context
                .read<AuthBloc>()
                .authRepository
                .getCurrentUser();

            NotificationService.instance.saveTokenForUser(user!.uid);

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => MainScreen()),
            );
          }

          if (state is UnauthenticatedState) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          }
        },

        //  EMPTY UI (no splash design)
        child: const SizedBox(),
      ),
    );
  }
}
