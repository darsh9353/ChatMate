abstract class ChatListEvent {}

class LoadUserChatsEvent extends ChatListEvent {
  final String userId;
  LoadUserChatsEvent(this.userId);
}

class DeleteChatForMeEvent extends ChatListEvent {
  final String chatId;
  final String userId;

  DeleteChatForMeEvent(this.chatId, this.userId);
}
