import 'package:chatmate/blocs/chat/chat_bloc.dart';
import 'package:chatmate/blocs/chat/chat_event.dart';
import 'package:chatmate/blocs/chat/chat_state.dart';
import 'package:chatmate/widgets/app_background.dart';
import 'package:chatmate/widgets/user_avathar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message_model.dart';
import 'package:chatmate/utils/date_formatter.dart';

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

  @override
  void initState() {
    super.initState();

    context.read<ChatBloc>().add(LoadMessagesEvent(widget.chatId));
  }

  Future<void> ensureChatExists(String lastMessage) async {
    final chatRef = FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId);

    final doc = await chatRef.get();

    if (!doc.exists) {
      final currentUserDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.currentUserId)
          .get();

      final currentUserName = currentUserDoc['name'];

      await chatRef.set({
        'chatId': widget.chatId,
        'participants': [widget.currentUserId, widget.otherUserId],
        'participantNames': {
          widget.currentUserId: currentUserName,
          widget.otherUserId: widget.otherUserName,
        },
        'lastMessage': lastMessage,
        'timestamp': Timestamp.now(),
      });
    }
  }

  void sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    final bloc = context.read<ChatBloc>();

    await ensureChatExists(text);

    final message = MessageModel(
      messageId: const Uuid().v4(),
      senderId: widget.currentUserId,
      receiverId: widget.otherUserId,
      message: text,
      timestamp: DateTime.now(),
      isSeen: false,
    );

    bloc.add(SendMessageEvent(chatId: widget.chatId, message: message));

    messageController.clear();

    // smooth auto scroll
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.secondary,
        systemOverlayStyle: theme.brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        title: Row(
          children: [
            UserAvatar(userId: widget.otherUserId, radius: 16),
            const SizedBox(width: 10),
            Text(widget.otherUserName),
          ],
        ),
      ),
      body: AppBackground(
        child: Column(
          children: [
            Expanded(
              child: BlocBuilder<ChatBloc, ChatState>(
                builder: (context, state) {
                  if (state is ChatLoaded) {
                    final messages = state.messages;

                    if (messages.isEmpty) {
                      return const Center(child: Text("Say Hi 👋"));
                    }

                    return ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(10),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        final isMe = msg.senderId == widget.currentUserId;

                        return Align(
                          alignment: isMe
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            constraints: const BoxConstraints(maxWidth: 250),
                            decoration: BoxDecoration(
                              color: isMe
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.secondary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  msg.message,
                                  style: TextStyle(
                                    color: isMe
                                        ? theme.colorScheme.onPrimary
                                        : theme.colorScheme.onSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormatter.formatChatTime(msg.timestamp),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isMe
                                        ? theme.colorScheme.onPrimary
                                        : theme.colorScheme.onSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }

                  if (state is ChatError) {
                    return Center(child: Text(state.messsage));
                  }

                  // ONLY first load
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),

            Container(
              padding: const EdgeInsets.all(10),
              color: theme.colorScheme.surface,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      textAlign: TextAlign.center,
                      style: TextStyle(color: theme.colorScheme.onSecondary),
                      controller: messageController,
                      decoration: InputDecoration(
                        hintText: "Type a message",
                        filled: true,
                        fillColor: theme.colorScheme.secondary,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: theme.colorScheme.primary,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
