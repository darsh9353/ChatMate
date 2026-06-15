import 'package:chatmate/blocs/chat_list/chat_list_bloc.dart';
import 'package:chatmate/blocs/settings/settings_state.dart';
import 'package:chatmate/firebase_messaging_background.dart';
import 'package:chatmate/services/navigation_service.dart';
import 'package:chatmate/services/notification_service.dart';
import 'package:chatmate/widgets/app_root.dart';
import 'package:flutter/material.dart';
import 'package:chatmate/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Repositories
import 'package:chatmate/repositories/auth_repository.dart';
import 'package:chatmate/repositories/chat_repository.dart';

// Blocs
import 'package:chatmate/blocs/auth/auth_bloc.dart';
import 'package:chatmate/blocs/chat/chat_bloc.dart';
import 'package:chatmate/blocs/settings/settings_bloc.dart';

import 'package:chatmate/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await NotificationService.instance.initialize();

  runApp(const ChatMateApp());
}

class ChatMateApp extends StatelessWidget {
  const ChatMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(create: (_) => AuthRepository()),
        RepositoryProvider<ChatRepository>(create: (_) => ChatRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(context.read<AuthRepository>()),
          ),
          BlocProvider<ChatBloc>(
            create: (context) => ChatBloc(context.read<ChatRepository>()),
          ),
          BlocProvider<ChatListBloc>(
            create: (context) => ChatListBloc(context.read<ChatRepository>()),
          ),
          BlocProvider<SettingsBloc>(create: (context) => SettingsBloc()),
        ],
        child: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, settingsState) {
            return MaterialApp(
              title: 'ChatMate',
              debugShowCheckedModeBanner: false,
              navigatorKey: NavigationService.navigatorKey,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: settingsState.themeMode,
              home: const AppRoot(),
            );
          },
        ),
      ),
    );
  }
}
