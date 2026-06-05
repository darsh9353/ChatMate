import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../services/chat_service.dart';

class ChatRepository {
  final ChatService _chatService = ChatService();

  // Send message
  Future<void> sendMessage({
    required String chatId,
    required MessageModel message,
  }) async {
    await _chatService.sendMessage(chatId: chatId, messageMap: message.toMap());
  }

  // Get messages (convert to model)
  Stream<List<MessageModel>> getMessages(String chatId) {
    return _chatService.getMessages(chatId).map((snapshot) {
      return snapshot.docs.map((doc) {
        return MessageModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // Get user chats (convert to model)
  Stream<List<ChatModel>> getUserChats(String currentUserId) {
    return _chatService.getUserChats(currentUserId).map((snapshot) {
      return snapshot.docs.map((doc) {
        return ChatModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
}
