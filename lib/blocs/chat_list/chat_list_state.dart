import '../../models/chat_model.dart';

abstract class ChatListState {}

class ChatListInitial extends ChatListState {}

class ChatListLoaded extends ChatListState {
  final List<ChatModel> chats;
  ChatListLoaded(this.chats);
}

class ChatListError extends ChatListState {
  final String message;
  ChatListError(this.message);
}
