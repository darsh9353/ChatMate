import 'package:chatmate/firebase_options.dart';
import 'package:chatmate/screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:chatmate/screens/splash_screen.dart';

// Repositories
import 'package:chatmate/repositories/auth_repository.dart';
import 'package:chatmate/repositories/chat_repository.dart';

// Blocs
import 'package:chatmate/blocs/auth/auth_bloc.dart';
import 'package:chatmate/blocs/chat/chat_bloc.dart';
import 'package:chatmate/blocs/settings/settings_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const ChatMateApp());
}

class ChatMateApp extends StatelessWidget {
  const ChatMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        // 🔹 Repositories
        RepositoryProvider<AuthRepository>(create: (_) => AuthRepository()),
        RepositoryProvider<ChatRepository>(create: (_) => ChatRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          // 🔹 Auth Bloc
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(context.read<AuthRepository>()),
          ),

          // 🔹 Chat Bloc
          BlocProvider<ChatBloc>(
            create: (context) => ChatBloc(context.read<ChatRepository>()),
          ),

          // 🔹 Settings Bloc (no repo needed if simple)
          BlocProvider<SettingsBloc>(create: (context) => SettingsBloc()),
        ],
        child: MaterialApp(
          title: 'ChatMate',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: const ColorScheme(
              brightness: Brightness.light,
              primary: Colors.blue,
              onPrimary: Colors.white,

              secondary: Color.fromARGB(255, 236, 233, 233),
              onSecondary: Colors.white,

              background: Color(0xd5f6ed),
              onBackground: Color.fromARGB(255, 255, 255, 255),

              surface: Colors.white,
              onSurface: Colors.black,

              error: Colors.red,
              onError: Colors.white,
            ),
          ),
          home: const SplashScreen(),
        ),
      ),
    );
  }
}
