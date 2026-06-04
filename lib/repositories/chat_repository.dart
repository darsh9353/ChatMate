import 'package:chatmate/models/chat_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message_model.dart';

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //  Send Message
  Future<void> sendMessage({
    required String chatId,
    required MessageModel message,
  }) async {
    final chatRef = _firestore.collection('chats').doc(chatId);

    // Add message to subcollection
    await chatRef
        .collection('messages')
        .doc(message.messageId)
        .set(message.toMap());

    // Update last message in chat
    await chatRef.update({
      'lastMessage': message.message,
      'timestamp': Timestamp.fromDate(message.timestamp),
    });
  }

  //  Get Messages (Real-time)
  Stream<List<MessageModel>> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => MessageModel.fromMap(doc.data()))
              .toList();
        });
  }

  Stream<List<ChatModel>> getUserChats(String currentUserId) {
    return FirebaseFirestore.instance
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return ChatModel.fromMap(doc.data());
          }).toList();
        });
  }
}
