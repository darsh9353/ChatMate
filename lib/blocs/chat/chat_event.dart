import 'package:chatmate/models/message_model.dart';

abstract class ChatEvent {}

class SendMessageEvent extends ChatEvent {
  final String chatId;
  final MessageModel message;

  SendMessageEvent({required this.chatId, required this.message});
}

class LoadMessagesEvent extends ChatEvent {
  final String chatId;

  LoadMessagesEvent(this.chatId);
}

class LoadUserChatsEvent extends ChatEvent {
  final String userId;

  LoadUserChatsEvent(this.userId);
}
