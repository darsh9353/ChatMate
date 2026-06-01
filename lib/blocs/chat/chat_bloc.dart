import 'package:chatmate/repositories/chat_repository.dart';

import 'chat_event.dart';
import 'chat_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc(ChatRepository read) : super(ChatInitial()) {
    on<SendMessageEvent>((event, emit) async {
      emit(ChatLoading());
      await Future.delayed(Duration(seconds: 1));
      emit(ChatLoaded());
    });
  }
}
