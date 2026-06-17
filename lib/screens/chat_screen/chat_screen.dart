import 'package:chatmate/screens/chat_screen/services/chat_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chatmate/blocs/chat/chat_bloc.dart';
import 'package:chatmate/blocs/chat/chat_event.dart';
import 'package:chatmate/blocs/block/block_bloc.dart';
import 'package:chatmate/blocs/block/block_event.dart';
import 'package:chatmate/widgets/app_background.dart';
import 'widgets/message_input.dart';
import 'widgets/block_status_view.dart';
import 'widgets/message_list.dart';
import 'widgets/chat_app_bar.dart';

class ChatScreen extends StatefulWidget {
  final String currentUserId;
  final String chatId;
  final String otherUserId;
  final String otherUserName;

  const ChatScreen({
    super.key,
    required this.currentUserId,
    required this.chatId,
    required this.otherUserId,
    required this.otherUserName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  bool isSending = false;

  @override
  void initState() {
    super.initState();

    context.read<ChatBloc>().add(LoadMessagesEvent(widget.chatId));

    ChatHelper.markMessagesAsSeen(widget.chatId, widget.currentUserId);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BlockBloc>().add(
        LoadBlockStatusEvent(widget.currentUserId, widget.otherUserId),
      );
    });
  }

  void sendMessage() async {
    if (isSending) return;

    final text = messageController.text.trim();
    if (text.isEmpty) return;

    setState(() => isSending = true);

    try {
      await ChatHelper.ensureChatExists(
        widget.chatId,
        widget.currentUserId,
        widget.otherUserId,
        widget.otherUserName,
        text,
      );

      final message = ChatHelper.createMessage(
        widget.currentUserId,
        widget.otherUserId,
        text,
      );

      context.read<ChatBloc>().add(
        SendMessageEvent(chatId: widget.chatId, message: message),
      );

      messageController.clear();
    } catch (e) {
      print(e);
    }

    if (!mounted) return;
    setState(() => isSending = false);
  }

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ChatAppBar(
        currentUserId: widget.currentUserId,
        otherUserId: widget.otherUserId,
        otherUserName: widget.otherUserName,
      ),
      body: AppBackground(
        child: Column(
          children: [
            MessageList(
              currentUserId: widget.currentUserId,
              chatId: widget.chatId,
              scrollController: scrollController,
            ),
            BlocBuilder<BlockBloc, dynamic>(
              builder: (context, state) {
                return Column(
                  children: [
                    BlockStatusView(state: state),
                    if (!state.isBlockedByMe && !state.isBlockedByOther)
                      MessageInput(
                        controller: messageController,
                        isSending: isSending,
                        onSend: sendMessage,
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
