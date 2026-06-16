import 'package:chatmate/blocs/auth/auth_bloc.dart';
import 'package:chatmate/blocs/auth/auth_event.dart';
import 'package:chatmate/blocs/auth/auth_state.dart';
import 'package:chatmate/blocs/language/langauge_bloc.dart';
import 'package:chatmate/blocs/language/language_event.dart';
import 'package:chatmate/blocs/language/language_state.dart';
import 'package:chatmate/blocs/settings/settings_bloc.dart';
import 'package:chatmate/blocs/settings/settings_event.dart';
import 'package:chatmate/blocs/settings/settings_state.dart';
import 'package:chatmate/l10n/app_localizations.dart';
import 'package:chatmate/repositories/auth_repository.dart';
import 'package:chatmate/screens/login_screen.dart';
import 'package:chatmate/screens/profile_setup_screen.dart';
import 'package:chatmate/widgets/app_background.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Stream<DocumentSnapshot> getUserData(String uid) {
    return FirebaseFirestore.instance.collection('users').doc(uid).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final user = context.read<AuthRepository>().getCurrentUser();

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is UnauthenticatedState) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        }

        if (state is AuthErrorState) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: theme.colorScheme.secondary,
          systemOverlayStyle: theme.brightness == Brightness.dark
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle.dark,
          elevation: 0,
          title: Text(
            AppLocalizations.of(context)?.appTitle ?? "ChatMate",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),

        body: AppBackground(
          child: Column(
            children: [
              const SizedBox(height: 20),

              StreamBuilder<DocumentSnapshot>(
                stream: getUserData(user!.uid),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }

                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  final name = data['name'] ?? "User";
                  final imagePath = data['profileImage'] ?? "";

                  return Container(
                    width: width * 0.5,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 55,
                          backgroundColor: theme.colorScheme.secondary,
                          backgroundImage: imagePath.isNotEmpty
                              ? NetworkImage(imagePath)
                              : null,
                          child: imagePath.isEmpty
                              ? const Icon(Icons.person, size: 40)
                              : null,
                        ),
                        const SizedBox(height: 15),
                        Text(
                          name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // THEME TOGGLE (NEW)
              BlocBuilder<SettingsBloc, SettingsState>(
                builder: (context, state) {
                  final isDark = state.themeMode == ThemeMode.dark;

                  return Container(
                    width: width * 0.7,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SwitchListTile(
                      title: Text(
                        AppLocalizations.of(context)?.darkMode ?? "Dark Mode",
                      ),
                      value: isDark,
                      onChanged: (value) {
                        context.read<SettingsBloc>().add(
                          ToggleThemeEvent(value),
                        );
                      },
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              BlocBuilder<LanguageBloc, LanguageState>(
                builder: (context, state) {
                  final isKannada = state.locale.languageCode == 'kn';

                  return Container(
                    width: width * 0.7,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SwitchListTile(
                      title: Text(
                        AppLocalizations.of(context)?.language ?? "Language",
                      ),
                      subtitle: Text(
                        isKannada ? "ಕನ್ನಡ ↔ English" : "English ↔ ಕನ್ನಡ",
                      ),
                      secondary: const Icon(Icons.language),
                      value: isKannada,
                      onChanged: (value) {
                        context.read<LanguageBloc>().add(
                          ChangeLanguageEvent(
                            value ? const Locale('kn') : const Locale('en'),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 15),

              //  EDIT PROFILE
              SizedBox(
                width: width * 0.7,
                height: 45,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.surface,
                  ),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ProfileSetupScreen(isEdit: true),
                      ),
                    );
                  },
                  child: Text(
                    AppLocalizations.of(context)?.editProfile ?? "Edit Profile",
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // LOGOUT
              SizedBox(
                width: width * 0.7,
                height: 45,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.surface,
                  ),
                  onPressed: () {
                    context.read<AuthBloc>().add(LogoutEvent());
                  },
                  child: Text(AppLocalizations.of(context)?.logout ?? "Logout"),
                ),
              ),
            ],
          ),
        ),

        //  BOTTOM NAV
      ),
    );
  }
}
