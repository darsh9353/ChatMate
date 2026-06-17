import 'package:flutter/material.dart';
import 'package:chatmate/theme/app_theme.dart';

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    //  Detect theme mode
    final isDark = theme.brightness == Brightness.dark;

    //  Pick gradient based on theme
    final gradientColors = isDark
        ? AppTheme.darkGradient
        : AppTheme.lightGradient;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: child,
    );
  }
}
