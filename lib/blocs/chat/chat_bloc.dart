import 'package:chatmate/models/chat_model.dart';
import 'package:chatmate/models/message_model.dart';
import 'package:chatmate/repositories/chat_repository.dart';

import 'chat_event.dart';
import 'chat_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository chatRepository;

  ChatBloc(this.chatRepository) : super(ChatInitial()) {
    //  Send message
    on<SendMessageEvent>((event, emit) async {
      try {
        await chatRepository.sendMessage(
          chatId: event.chatId,
          message: event.message,
        );
      } catch (e) {
        emit(ChatError("Failed to send message"));
      }
    });

    //  Load messages (stream)
    on<LoadMessagesEvent>((event, emit) async {
      await emit.forEach<List<MessageModel>>(
        chatRepository.getMessages(event.chatId),
        onData: (messages) => ChatLoaded(messages),
        onError: (_, __) => ChatError("Failed to load messages"),
      );
    });
  }
}
