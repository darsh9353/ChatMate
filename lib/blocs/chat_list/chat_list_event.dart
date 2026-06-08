abstract class ChatListEvent {}

class LoadUserChatsEvent extends ChatListEvent {
  final String userId;
  LoadUserChatsEvent(this.userId);
}
