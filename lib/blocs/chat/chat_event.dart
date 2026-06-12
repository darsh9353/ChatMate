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

class DeleteForMeEvent extends ChatEvent {
  final String chatId;
  final String messageId;
  final String userId;

  DeleteForMeEvent(this.chatId, this.messageId, this.userId);
}

class DeleteForEveryoneEvent extends ChatEvent {
  final String chatId;
  final String messageId;

  DeleteForEveryoneEvent(this.chatId, this.messageId);
}

class AddReactionEvent extends ChatEvent {
  final String chatId;
  final String messageId;
  final String userId;
  final String emoji;

  AddReactionEvent(this.chatId, this.messageId, this.userId, this.emoji);
}
