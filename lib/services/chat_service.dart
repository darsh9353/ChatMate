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
    final chatRef = _firestore.collection('chats').doc(chatId);

    final docRef = chatRef.collection('messages').doc(messageId);

    await docRef.update({
      'deletedFor': FieldValue.arrayUnion([userId]),
    });

    //  Recalculate last visible message for THIS user
    final messagesSnapshot = await chatRef
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .get();

    String newLastMessage = "No messages yet";

    for (var doc in messagesSnapshot.docs) {
      final data = doc.data();
      final deletedFor = List<String>.from(data['deletedFor'] ?? []);

      if (!deletedFor.contains(userId)) {
        newLastMessage = data['message'];
        break;
      }
    }

    await chatRef.update({'lastMessage': newLastMessage});
  }

  Future<void> deleteForEveryone({
    required String chatId,
    required String messageId,
  }) async {
    final chatRef = _firestore.collection('chats').doc(chatId);

    final docRef = chatRef.collection('messages').doc(messageId);

    // Mark message as deleted
    await docRef.update({
      'message': "This message was deleted",
      'reactions': {},
    });

    //  Check if this was LAST message
    final messagesSnapshot = await chatRef
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .get();

    if (messagesSnapshot.docs.isNotEmpty) {
      final latestMessage = messagesSnapshot.docs.first.data();

      await chatRef.update({
        'lastMessage': latestMessage['message'],
        'timestamp': latestMessage['timestamp'],
      });
    }
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

    // 1. Hide chat
    await chatRef.update({
      'hiddenFor': FieldValue.arrayUnion([userId]),
    });

    // 2. Delete all messages for this user
    await deleteEntireChatMessagesForMe(chatId: chatId, userId: userId);
  }

  Future<void> deleteEntireChatMessagesForMe({
    required String chatId,
    required String userId,
  }) async {
    final chatRef = _firestore.collection('chats').doc(chatId);

    final messagesSnapshot = await chatRef.collection('messages').get();

    final batch = _firestore.batch();

    for (var doc in messagesSnapshot.docs) {
      batch.update(doc.reference, {
        'deletedFor': FieldValue.arrayUnion([userId]),
      });
    }

    await batch.commit();
  }
}
