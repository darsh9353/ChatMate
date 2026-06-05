import 'package:chatmate/screens/login_screen.dart';
import 'package:chatmate/widgets/app_background.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() {
    return SplashScreenState();
  }
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    //after delaying 2 seconds navigating to loginScreen
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ), //navigating to LoginScreen
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    //taking screeen height and width
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final theme = Theme.of(context);

    return Scaffold(
      body: AppBackground(
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
                  scale: 1.2, // adjust app icon until white disappears
                  child: Image.asset(
                    'assets/images/message.png',
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.02),

              SizedBox(height: screenHeight * 0.01),
              Text(
                'Effortless Connection',

                style: GoogleFonts.poppins(
                  fontSize: screenWidth * 0.03,
                  fontWeight: FontWeight.w200,
                ),
              ),

              SizedBox(height: screenHeight * 0.05),

              Center(
                child: CircularProgressIndicator(
                  color: theme.colorScheme.primary,
                ),
              ),
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
    );
  }
}
