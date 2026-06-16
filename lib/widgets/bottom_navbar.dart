import 'package:chatmate/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class MainBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const MainBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: theme.colorScheme.primary,
      backgroundColor: theme.colorScheme.secondary,
      onTap: onTap, // just callback
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.chat),
          label: AppLocalizations.of(context)?.chats ?? "Chats",
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.contacts),
          label: AppLocalizations.of(context)?.contacts ?? "Contacts",
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.settings),
          label: AppLocalizations.of(context)?.settings ?? "Settings",
        ),
      ],
    );
  }
}
