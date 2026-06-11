import 'dart:convert';

import 'package:chatmate/config/fcm_config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

/// Sends push notifications from the sender's device (no Cloud Functions).
///
/// Uses FCM HTTP v1 with a Firebase service account JSON file. This is fine for
/// learning projects; never ship service account credentials in production.
class FcmSenderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AutoRefreshingAuthClient? _authClient;

  Future<void> sendChatNotification({
    required String receiverId,
    required String senderId,
    required String senderName,
    required String chatId,
    required String message,
  }) async {
    if (receiverId == senderId) return;

    final receiverDoc =
        await _firestore.collection('users').doc(receiverId).get();
    final token = receiverDoc.data()?['fcmToken'] as String?;
    if (token == null || token.isEmpty) {
      debugPrint('FCM: receiver has no token ($receiverId)');
      return;
    }

    final data = {
      'type': 'chat_message',
      'chatId': chatId,
      'senderId': senderId,
      'senderName': senderName,
      'message': message,
    };

    final sent = await _sendViaHttpV1(
      token: token,
      title: senderName,
      body: message,
      data: data,
    );

    if (!sent && FcmConfig.legacyServerKey.isNotEmpty) {
      await _sendViaLegacyApi(
        token: token,
        title: senderName,
        body: message,
        data: data,
      );
    }
  }

  Future<bool> _sendViaHttpV1({
    required String token,
    required String title,
    required String body,
    required Map<String, String> data,
  }) async {
    try {
      final client = await _getAuthClient();
      if (client == null) return false;

      final response = await client.post(
        Uri.parse(
          'https://fcm.googleapis.com/v1/projects/${FcmConfig.projectId}/messages:send',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': {
            'token': token,
            'notification': {'title': title, 'body': body},
            'data': data,
            'android': {
              'priority': 'HIGH',
              'notification': {'channel_id': 'chat_messages'},
            },
          },
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      }

      debugPrint('FCM v1 error (${response.statusCode}): ${response.body}');
      return false;
    } catch (e) {
      debugPrint('FCM v1 send failed: $e');
      return false;
    }
  }

  Future<AutoRefreshingAuthClient?> _getAuthClient() async {
    if (_authClient != null) return _authClient;

    try {
      final jsonStr =
          await rootBundle.loadString(FcmConfig.serviceAccountAssetPath);
      final credentials =
          ServiceAccountCredentials.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);

      _authClient = await clientViaServiceAccount(
        credentials,
        ['https://www.googleapis.com/auth/firebase.messaging'],
      );
      return _authClient;
    } catch (e) {
      debugPrint(
        'FCM: could not load service account at '
        '${FcmConfig.serviceAccountAssetPath}. $e',
      );
      return null;
    }
  }

  Future<void> _sendViaLegacyApi({
    required String token,
    required String title,
    required String body,
    required Map<String, String> data,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=${FcmConfig.legacyServerKey}',
        },
        body: jsonEncode({
          'to': token,
          'priority': 'high',
          'notification': {
            'title': title,
            'body': body,
            'android_channel_id': 'chat_messages',
          },
          'data': data,
        }),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        debugPrint('FCM legacy error (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      debugPrint('FCM legacy send failed: $e');
    }
  }
}
