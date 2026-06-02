import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE8F0EF), Color(0xFF81C2B7)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: child,
    );
  }
}


/*
 colors: [Color(0xFFE8F0EF), Color(0xFF81C2B7)],
 Scaffold(
  body: AppBackground(
    child: Center(
      child: Text("Hello"),
    ),
  ),
)*/