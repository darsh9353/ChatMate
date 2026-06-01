abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {}

class ChatError extends ChatState {
  final String messsage;
  ChatError(this.messsage);
}
