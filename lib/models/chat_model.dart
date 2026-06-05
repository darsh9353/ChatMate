import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String chatId;
  final List<String> participants;
  final Map<String, String> participantNames; //  NEW
  final String lastMessage;
  final DateTime timestamp;

  ChatModel({
    required this.chatId,
    required this.participants,
    required this.participantNames,
    required this.lastMessage,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'chatId': chatId,
      'participants': participants,
      'participantNames': participantNames, // NEW
      'lastMessage': lastMessage,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory ChatModel.fromMap(Map<String, dynamic> map) {
    return ChatModel(
      chatId: map['chatId'] ?? '',
      participants: List<String>.from(map['participants'] ?? []),
      participantNames: Map<String, String>.from(
        map['participantNames'] ?? {},
      ), //  NEW
      lastMessage: map['lastMessage'] ?? '',
      timestamp: map['timestamp'] != null
          ? (map['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}
