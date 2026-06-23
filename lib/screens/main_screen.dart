import 'package:chatmate/repositories/auth_repository.dart';
import 'package:chatmate/screens/contacts_screen.dart';
import 'package:chatmate/screens/home_screen.dart';
import 'package:chatmate/screens/settings_screen.dart';
import 'package:chatmate/widgets/bottom_navbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;

  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthRepository>().getCurrentUser();

    final List<Widget> pages = [
      HomeScreen(currentUserId: user!.uid),
      AllContacts(currentUserId: user.uid), //
      SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ), //routes among screens based on index and prevent state

      bottomNavigationBar: MainBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
