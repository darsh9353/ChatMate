import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Send message (Firestore only)
  Future<void> sendMessage({
    required String chatId,
    required Map<String, dynamic> messageMap,
  }) async {
    final chatRef = _firestore.collection('chats').doc(chatId);

    await chatRef
        .collection('messages')
        .doc(messageMap['messageId'])
        .set(messageMap);
    await chatRef.update({
      'lastMessage': messageMap['message'],
      'timestamp': messageMap['timestamp'],
    });
  }

  // Get messages stream
  Stream<QuerySnapshot> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots();
  }

  // Get user chats stream
  Stream<QuerySnapshot> getUserChats(String currentUserId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .orderBy('timestamp', descending: true) // ADD HERE
        .snapshots();
  }
}
