import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String messageId;
  final String senderId;
  final String receiverId;
  final String message;
  final DateTime timestamp;
  final bool isSeen;

  // NEW FIELDS
  final List<String> deletedFor; // userIds
  final Map<String, String> reactions; // userId : emoji

  MessageModel({
    required this.messageId,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.timestamp,
    required this.isSeen,
    this.deletedFor = const [],
    this.reactions = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
      'isSeen': isSeen,
      'deletedFor': deletedFor,
      'reactions': reactions,
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      messageId: map['messageId'] ?? '',
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      message: map['message'] ?? '',
      isSeen: map['isSeen'] ?? false,
      timestamp: map['timestamp'] != null
          ? (map['timestamp'] as Timestamp).toDate()
          : DateTime.now(),

      deletedFor: List<String>.from(map['deletedFor'] ?? []),
      reactions: Map<String, String>.from(map['reactions'] ?? {}),
    );
  }
}
