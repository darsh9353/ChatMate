import 'dart:convert';

import 'package:chatmate/services/navigation_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'chat_messages';
  static const String _channelName = 'Chat Messages';

  Map<String, String>? _pendingNotificationData;

  Future<void> initialize() async {
    await _setupLocalNotifications();
    await _requestPermissions();
    _setupForegroundListener();
    _setupNotificationTapListener();
    await _captureInitialMessage();
    _listenForTokenRefresh();
  }

  Future<void> _setupLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initSettings = InitializationSettings(android: androidSettings);

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onLocalNotificationTapped,
    );

    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: 'Notifications for new chat messages',
      importance: Importance.high,
    );

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.createNotificationChannel(channel);
  }

  Future<void> _requestPermissions() async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.requestNotificationsPermission();
  }

  void _setupForegroundListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final data = message.data;

      if (data['type'] != 'chat_message') return;

      final title =
          message.notification?.title ??
          data['senderName']?.toString() ??
          'New message';

      final body =
          message.notification?.body ??
          data['message']?.toString() ??
          'New message';

      _showLocalNotification(title: title, body: body, data: data);
    });
  }

  void _setupNotificationTapListener() {
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleNotificationData(message.data);
    });
  }

  Future<void> _captureInitialMessage() async {
    final message = await _messaging.getInitialMessage();

    if (message != null) {
      final normalized = _normalizeData(message.data);
      if (normalized != null) {
        _pendingNotificationData = normalized;
      }
    }
  }

  void _listenForTokenRefresh() {
    _messaging.onTokenRefresh.listen((token) async {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await saveTokenForUser(uid, token);
      }
    });
  }

  Future<void> saveTokenForUser(String uid, [String? token]) async {
    final fcmToken = token ?? await _messaging.getToken();
    if (fcmToken == null || fcmToken.isEmpty) return;

    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'fcmToken': fcmToken,
    }, SetOptions(merge: true));
  }

  Future<void> handlePendingNavigation(String currentUserId) async {
    final data = _pendingNotificationData;
    if (data == null) return;

    _pendingNotificationData = null;
    _navigateFromData(data, currentUserId);
  }

  void _onLocalNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;

    final decoded = jsonDecode(payload);

    if (decoded is! Map) return;

    final data = _normalizeData(Map<String, dynamic>.from(decoded));
    if (data == null) return;

    _handleNotificationData(data);
  }

  void _handleNotificationData(Map<String, dynamic> rawData) {
    final data = _normalizeData(rawData);
    if (data == null) return;

    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId == null) {
      _pendingNotificationData = data;
      return;
    }

    _navigateFromData(data, currentUserId);
  }

  Map<String, String>? _normalizeData(Map<String, dynamic> rawData) {
    if (rawData['type'] != 'chat_message') return null;

    final chatId = rawData['chatId']?.toString();
    final senderId = rawData['senderId']?.toString();
    final senderName = rawData['senderName']?.toString();

    if (chatId == null || senderId == null || senderName == null) {
      return null;
    }

    return {
      'type': 'chat_message',
      'chatId': chatId,
      'senderId': senderId,
      'senderName': senderName,
    };
  }

  void _navigateFromData(Map<String, String> data, String currentUserId) {
    if (data['senderId'] == currentUserId) return;

    NavigationService.navigateToChat(
      currentUserId: currentUserId,
      chatId: data['chatId']!,
      otherUserId: data['senderId']!,
      otherUserName: data['senderName']!,
    );
  }

  Future<void> _showLocalNotification({
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Notifications for new chat messages',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      const NotificationDetails(android: androidDetails),
      payload: jsonEncode(data),
    );
  }
}
