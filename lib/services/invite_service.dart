import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class InviteService {
  static const String inviteMessage =
      'Hi! Join me on ChatMate to chat. Install the app and sign up with your phone number.';

  Future<bool> sendSmsInvite(String phoneNumber) async {
    final digits = phoneNumber.replaceAll(RegExp(r'\D'), '');
    final uri = Uri(
      scheme: 'sms',
      path: digits,
      queryParameters: {'body': inviteMessage},
    );

    try {
      if (await canLaunchUrl(uri)) {
        return launchUrl(uri);
      }
    } catch (e) {
      debugPrint('Invite SMS failed: $e');
    }
    return false;
  }
}
