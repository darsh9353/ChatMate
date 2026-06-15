import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Send message
  Future<void> sendMessage({
    required String chatId,
    required Map<String, dynamic> messageMap,
  }) async {
    final chatRef = _firestore.collection('chats').doc(chatId);

    // 1. Save message
    await chatRef
        .collection('messages')
        .doc(messageMap['messageId'])
        .set(messageMap);

    // 2. Get participants
    final chatDoc = await chatRef.get();
    final participants = List<String>.from(chatDoc['participants']);

    // 3. Update chat + unhide
    await chatRef.update({
      'lastMessage': messageMap['message'],
      'timestamp': messageMap['timestamp'],
      'hiddenFor': FieldValue.arrayRemove(
        participants,
      ), //remove participants from hidden array
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
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> deleteForMe({
    required String chatId,
    required String messageId,
    required String userId,
  }) async {
    final docRef = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId);

    await docRef.update({
      'deletedFor': FieldValue.arrayUnion([userId]),
    });
  }

  Future<void> deleteForEveryone({
    required String chatId,
    required String messageId,
  }) async {
    final docRef = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId);

    await docRef.update({
      'message': "This message was deleted",
      'reactions': {},
    });
  }

  Future<void> addReaction({
    required String chatId,
    required String messageId,
    required String userId,
    required String emoji,
  }) async {
    final docRef = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId);

    await docRef.update({'reactions.$userId': emoji});
  }

  Future<void> deleteChatForMe({
    required String chatId,
    required String userId,
  }) async {
    final chatRef = _firestore.collection('chats').doc(chatId);

    await chatRef.update({
      'hiddenFor': FieldValue.arrayUnion([userId]),
    });
  }
}
