// import 'package:chatmate/models/user_model.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
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

  Future<void> deleteForMe(String chatId, String messageId, String userId) {
    return _chatService.deleteForMe(
      chatId: chatId,
      messageId: messageId,
      userId: userId,
    );
  }

  Future<void> deleteForEveryone(String chatId, String messageId) {
    return _chatService.deleteForEveryone(chatId: chatId, messageId: messageId);
  }

  Future<void> addReaction(
    String chatId,
    String messageId,
    String userId,
    String emoji,
  ) {
    return _chatService.addReaction(
      chatId: chatId,
      messageId: messageId,
      userId: userId,
      emoji: emoji,
    );
  }

  Future<void> deleteChatForMe({
    required String chatId,
    required String userId,
  }) {
    return _chatService.deleteChatForMe(chatId: chatId, userId: userId);
  }
}
