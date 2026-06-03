import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_model.dart';

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //  Create Chat
  Future<void> createChat(ChatModel chat) async {
    await _firestore.collection('chats').doc(chat.chatId).set(chat.toMap());
  }

  // Get Chats of current user
  Stream<List<ChatModel>> getChats(String currentUserId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ChatModel.fromMap(doc.data()))
              .toList();
        });
  }
}
