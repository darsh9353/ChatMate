import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String chatId;
  final List<String> participants;
  final Map<String, String> participantNames;
  final String lastMessage;
  final DateTime timestamp;

  //ADD THESE
  final bool lastMessageSeen;
  final String lastMessageSenderId;
  final List<String> hiddenFor;

  ChatModel({
    required this.chatId,
    required this.participants,
    required this.participantNames,
    required this.lastMessage,
    required this.timestamp,
    required this.hiddenFor,

    // NEW
    required this.lastMessageSeen,
    required this.lastMessageSenderId,
  });

  DateTime get lastMessageTime => timestamp;

  Map<String, dynamic> toMap() {
    return {
      'chatId': chatId,
      'participants': participants,
      'participantNames': participantNames,
      'lastMessage': lastMessage,
      'timestamp': Timestamp.fromDate(timestamp),

      // ADD THIS
      'lastMessageSeen': lastMessageSeen,
      'lastMessageSenderId': lastMessageSenderId,
      'hiddenFor': hiddenFor,
    };
  }

  factory ChatModel.fromMap(Map<String, dynamic> map) {
    return ChatModel(
      chatId: map['chatId'] ?? '',
      participants: List<String>.from(map['participants'] ?? []),
      participantNames: Map<String, String>.from(map['participantNames'] ?? {}),
      lastMessage: map['lastMessage'] ?? '',
      timestamp: map['timestamp'] != null
          ? (map['timestamp'] as Timestamp).toDate()
          : DateTime.now(),

      // ADD THIS
      lastMessageSeen: map['lastMessageSeen'] ?? false,
      lastMessageSenderId: map['lastMessageSenderId'] ?? '',
      hiddenFor: List<String>.from(map['hiddenFor'] ?? []),
    );
  }
}
