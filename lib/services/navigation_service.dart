import 'package:chatmate/screens/chat_screen.dart';
import 'package:flutter/material.dart';

/// Global navigator used to open a chat from notification taps
/// (foreground, background, or cold start).
class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Future<void>? navigateToChat({
    required String currentUserId,
    required String chatId,
    required String otherUserId,
    required String otherUserName,
  }) {
    return navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          chatId: chatId,
          currentUserId: currentUserId,
          otherUserId: otherUserId,
          otherUserName: otherUserName,
        ),
      ),
    );
  }
}
