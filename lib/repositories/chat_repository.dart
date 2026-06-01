import 'package:chatmate/services/chat_service.dart';

class ChatRepository {
  final ChatService _chatService = ChatService();

  Future<void> sendMessage() async {
    await _chatService.sendMessage();
  }

  Stream<List> getMessages() {
    return _chatService.getMessages();
  }
}
