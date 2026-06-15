import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chatmate/repositories/chat_repository.dart';
import 'package:chatmate/models/chat_model.dart';

import 'chat_list_event.dart';
import 'chat_list_state.dart';

class ChatListBloc extends Bloc<ChatListEvent, ChatListState> {
  final ChatRepository chatRepository;

  ChatListBloc(this.chatRepository) : super(ChatListInitial()) {
    ///LOAD CHATS
    on<LoadUserChatsEvent>((event, emit) async {
      await emit.forEach<List<ChatModel>>(
        chatRepository.getUserChats(event.userId),
        onData: (chats) => ChatListLoaded(chats),
        onError: (_, __) => ChatListError("Failed to load chats"),
      );
    });

    on<DeleteChatForMeEvent>((event, emit) async {
      try {
        await chatRepository.deleteChatForMe(
          chatId: event.chatId,
          userId: event.userId,
        );
        // No emit needed — stream will auto update UI
      } catch (e) {
        emit(ChatListError("Failed to delete chat"));
      }
    });
  }
}
