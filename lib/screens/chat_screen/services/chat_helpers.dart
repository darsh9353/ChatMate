// file: services/chat_helper.dart

import 'package:chatmate/models/message_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
// import '../models/message_model.dart';

class ChatHelper {
  static Future<void> markMessagesAsSeen(String chatId, String userId) async {
    final messagesRef = FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages');

    final unseenMessages = await messagesRef
        .where('receiverId', isEqualTo: userId)
        .where('isSeen', isEqualTo: false)
        .get();

    for (var doc in unseenMessages.docs) {
      doc.reference.update({'isSeen': true});
    }

    await FirebaseFirestore.instance.collection('chats').doc(chatId).update({
      'lastMessageSeen': true,
    });
  }

  static Future<void> ensureChatExists(
    String chatId,
    String currentUserId,
    String otherUserId,
    String otherUserName,
    String lastMessage,
  ) async {
    final chatRef = FirebaseFirestore.instance.collection('chats').doc(chatId);

    final doc = await chatRef.get();

    if (!doc.exists) {
      final currentUserDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .get();

      final currentUserName = currentUserDoc['name'];

      await chatRef.set({
        'chatId': chatId,
        'participants': [currentUserId, otherUserId],
        'participantNames': {
          currentUserId: currentUserName,
          otherUserId: otherUserName,
        },
        'lastMessage': lastMessage,
        'timestamp': Timestamp.now(),
      });
    }
  }

  static MessageModel createMessage(
    String senderId,
    String receiverId,
    String text,
  ) {
    return MessageModel(
      messageId: const Uuid().v4(),
      senderId: senderId,
      receiverId: receiverId,
      message: text,
      timestamp: DateTime.now(),
      isSeen: false,
    );
  }
}
