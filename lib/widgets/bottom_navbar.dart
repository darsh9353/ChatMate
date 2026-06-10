import 'package:flutter/material.dart';
import 'package:chatmate/screens/home_screen.dart';
import 'package:chatmate/screens/contacts_screen.dart';
import 'package:chatmate/screens/settings_screen.dart';
import 'package:chatmate/repositories/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainBottomNav extends StatelessWidget {
  final int currentIndex;

  const MainBottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.read<AuthRepository>().getCurrentUser();

    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: theme.colorScheme.primary,
      backgroundColor: theme.colorScheme.secondary,
      onTap: (index) {
        if (index == currentIndex) return;

        Widget screen;

        if (index == 0) {
          screen = HomeScreen(currentUserId: user!.uid);
        } else if (index == 1) {
          screen = ContactsScreen(currentUserId: user!.uid);
        } else {
          screen = SettingsScreen();
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => screen),
        );
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chats"),
        BottomNavigationBarItem(icon: Icon(Icons.contacts), label: "Contacts"),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
      ],
    );
  }
}
