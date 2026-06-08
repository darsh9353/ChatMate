import 'package:chatmate/blocs/auth/auth_bloc.dart';
import 'package:chatmate/blocs/auth/auth_event.dart';
import 'package:chatmate/blocs/auth/auth_state.dart';
import 'package:chatmate/screens/home_screen.dart';
import 'package:chatmate/screens/login_screen.dart';
import 'package:chatmate/widgets/app_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    //  Trigger auth check
    Future.microtask(() {
      context.read<AuthBloc>().add(CheckAuthStatusEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);

    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthenticatedState) {
            final user = context
                .read<AuthBloc>()
                .authRepository
                .getCurrentUser();

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => HomeScreen(
                  currentUserId: user!.uid, //  pass userId
                ),
              ),
            );
          }

          if (state is UnauthenticatedState) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          }
        },
        child: AppBackground(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: screenHeight * 0.18,
                  width: screenWidth * 0.4,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Transform.scale(
                    scale: 1.2,
                    child: Image.asset(
                      'assets/images/message.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                SizedBox(height: screenHeight * 0.02),

                Text(
                  'Effortless Connection',
                  style: GoogleFonts.poppins(
                    fontSize: screenWidth * 0.03,
                    fontWeight: FontWeight.w200,
                  ),
                ),

                SizedBox(height: screenHeight * 0.05),

                CircularProgressIndicator(color: theme.colorScheme.primary),

                SizedBox(height: screenHeight * 0.05),

                Text(
                  'Preparing your WorkSpace',
                  style: GoogleFonts.poppins(
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.w200,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
