import 'package:chatmate/models/chat_model.dart';
import 'package:chatmate/models/message_model.dart';

abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<MessageModel> messages;

  ChatLoaded(this.messages);
}

class ChatError extends ChatState {
  final String messsage;
  ChatError(this.messsage);
}

class ChatListLoaded extends ChatState {
  final List<ChatModel> chats;

  ChatListLoaded(this.chats);
}
