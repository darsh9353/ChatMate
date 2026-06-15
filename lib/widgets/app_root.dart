import 'package:chatmate/blocs/auth/auth_bloc.dart';
import 'package:chatmate/blocs/auth/auth_event.dart';
import 'package:chatmate/blocs/auth/auth_state.dart';
import 'package:chatmate/screens/login_screen.dart';
import 'package:chatmate/screens/main_screen.dart';
import 'package:chatmate/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  @override
  void initState() {
    super.initState();

    // Trigger auth check immediately
    Future.microtask(() {
      context.read<AuthBloc>().add(CheckAuthStatusEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthenticatedState) {
          final user = context.read<AuthBloc>().authRepository.getCurrentUser();

          NotificationService.instance.saveTokenForUser(user!.uid);

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => MainScreen()),
            (route) => false,
          );
        }

        if (state is UnauthenticatedState) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        }
      },

      // Temporary blank screen while deciding
      child: const Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }
}
