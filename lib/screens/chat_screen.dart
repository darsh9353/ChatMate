import 'package:chatmate/blocs/block/block_bloc.dart';
import 'package:chatmate/blocs/block/block_event.dart';
import 'package:chatmate/blocs/block/block_state.dart';
import 'package:chatmate/blocs/chat/chat_bloc.dart';
import 'package:chatmate/blocs/chat/chat_event.dart';
import 'package:chatmate/blocs/chat/chat_state.dart';
import 'package:chatmate/services/fcm_sender_service.dart';
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
  final FcmSenderService _fcmSender = FcmSenderService();
  bool isSending = false;

  @override
  void initState() {
    super.initState();

    context.read<ChatBloc>().add(LoadMessagesEvent(widget.chatId));

    // MARK AS SEEN
    markMessagesAsSeen();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BlockBloc>().add(
        LoadBlockStatusEvent(widget.currentUserId, widget.otherUserId),
      );
    });
  }

  Future<void> markMessagesAsSeen() async {
    final messagesRef = FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages');

    final unseenMessages = await messagesRef
        .where('receiverId', isEqualTo: widget.currentUserId)
        .where('isSeen', isEqualTo: false)
        .get();

    for (var doc in unseenMessages.docs) {
      doc.reference.update({'isSeen': true});
    }

    // ADD THIS (updates HomeScreen tick)
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .update({'lastMessageSeen': true});
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
    if (isSending) return; //  Prevent multiple taps

    final text = messageController.text.trim();
    if (text.isEmpty) return;

    setState(() => isSending = true); // LOCK BUTTON

    try {
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

      await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .update({
            'lastMessage': text,
            'timestamp': Timestamp.now(),
            'lastMessageSeen': false,
            'lastMessageSenderId': widget.currentUserId,
          });

      messageController.clear();

      final currentUserDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.currentUserId)
          .get();

      final senderName = currentUserDoc.data()?['name'] as String? ?? 'Someone';

      await _fcmSender.sendChatNotification(
        receiverId: widget.otherUserId,
        senderId: widget.currentUserId,
        senderName: senderName,
        chatId: widget.chatId,
        message: text,
      );

      // scroll
      Future.delayed(const Duration(milliseconds: 100), () {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      print(e);
    }
    if (!mounted) return;
    setState(() => isSending = false); //  UNLOCK BUTTON
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

        actions: [
          BlocBuilder<BlockBloc, BlockState>(
            builder: (context, state) {
              return PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'block') {
                    context.read<BlockBloc>().add(
                      BlockUserEvent(widget.currentUserId, widget.otherUserId),
                    );
                  } else {
                    context.read<BlockBloc>().add(
                      UnblockUserEvent(
                        widget.currentUserId,
                        widget.otherUserId,
                      ),
                    );
                  }
                },
                itemBuilder: (context) {
                  return [
                    PopupMenuItem(
                      value: state.isBlockedByMe ? 'unblock' : 'block',
                      child: Text(
                        state.isBlockedByMe ? 'Unblock User' : 'Block User',
                      ),
                    ),
                  ];
                },
              );
            },
          ),
        ],
      ),
      body: AppBackground(
        child: Column(
          children: [
            Expanded(
              child: BlocBuilder<ChatBloc, ChatState>(
                builder: (context, state) {
                  if (state is ChatLoaded) {
                    final messages = state.messages;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (scrollController.hasClients) {
                        scrollController.jumpTo(0); //  bottom
                      }
                    });

                    if (messages.isEmpty) {
                      return const Center(child: Text("Say Hi 👋"));
                    }

                    return ListView.builder(
                      controller: scrollController,
                      reverse: true,
                      padding: const EdgeInsets.all(10),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg =
                            messages[messages.length -
                                1 -
                                index]; //  reverse data
                        final isMe = msg.senderId == widget.currentUserId;

                        // HIDE MESSAGE (DELETE FOR ME)
                        if (msg.deletedFor.contains(widget.currentUserId)) {
                          return const SizedBox();
                        }

                        return GestureDetector(
                          // LONG PRESS → DELETE OPTIONS
                          onLongPress: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (_) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      title: const Text("Delete for me"),
                                      onTap: () {
                                        context.read<ChatBloc>().add(
                                          DeleteForMeEvent(
                                            widget.chatId,
                                            msg.messageId,
                                            widget.currentUserId,
                                          ),
                                        );
                                        Navigator.pop(context);
                                      },
                                    ),

                                    // ONLY SENDER CAN DELETE FOR EVERYONE
                                    if (isMe)
                                      ListTile(
                                        title: const Text(
                                          "Delete for everyone",
                                        ),
                                        onTap: () {
                                          context.read<ChatBloc>().add(
                                            DeleteForEveryoneEvent(
                                              widget.chatId,
                                              msg.messageId,
                                            ),
                                          );
                                          Navigator.pop(context);
                                        },
                                      ),
                                  ],
                                );
                              },
                            );
                          },

                          // DOUBLE TAP → REACTION
                          onDoubleTap: () {
                            showDialog(
                              context: context,
                              builder: (_) {
                                return AlertDialog(
                                  content: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: ["👍", "❤️", "😂", "😮", "😢"]
                                        .map((emoji) {
                                          return GestureDetector(
                                            onTap: () {
                                              context.read<ChatBloc>().add(
                                                AddReactionEvent(
                                                  widget.chatId,
                                                  msg.messageId,
                                                  widget.currentUserId,
                                                  emoji,
                                                ),
                                              );
                                              Navigator.pop(context);
                                            },
                                            child: Text(
                                              emoji,
                                              style: const TextStyle(
                                                fontSize: 26,
                                              ),
                                            ),
                                          );
                                        })
                                        .toList(),
                                  ),
                                );
                              },
                            );
                          },

                          child: Align(
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
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // MESSAGE TEXT
                                      Text(
                                        msg.message,
                                        style: TextStyle(
                                          fontStyle:
                                              msg.message ==
                                                  "This message was deleted"
                                              ? FontStyle.italic
                                              : FontStyle.normal,
                                          color: isMe
                                              ? theme.colorScheme.onPrimary
                                              : theme.colorScheme.onSecondary,
                                        ),
                                      ),

                                      const SizedBox(height: 4),

                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            DateFormatter.formatChatTime(
                                              msg.timestamp,
                                            ),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: isMe
                                                  ? theme.colorScheme.onPrimary
                                                  : theme
                                                        .colorScheme
                                                        .onSecondary,
                                            ),
                                          ),

                                          if (isMe) ...[
                                            const SizedBox(width: 5),
                                            Icon(
                                              Icons.done_all,
                                              size: 16,
                                              color: msg.isSeen
                                                  ? const Color.fromARGB(
                                                      255,
                                                      4,
                                                      20,
                                                      255,
                                                    )
                                                  : theme.colorScheme.onPrimary,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),

                                  //  REACTION AT BOTTOM RIGHT
                                  if (msg.reactions.isNotEmpty)
                                    Positioned(
                                      bottom: -20, // push outside bubble
                                      right: -20,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: msg.reactions.values.map((
                                            emoji,
                                          ) {
                                            return Text(
                                              emoji,
                                              style: const TextStyle(
                                                fontSize: 14,
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
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
            BlocBuilder<BlockBloc, BlockState>(
              builder: (context, blockState) {
                // YOU BLOCKED THEM
                if (blockState.isBlockedByMe) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    child: const Text(
                      "You blocked this user",
                      style: TextStyle(color: Colors.red, fontSize: 17),
                    ),
                  );
                }

                // HEY BLOCKED YOU
                if (blockState.isBlockedByOther) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    child: const Text(
                      "You cannot message this user",
                      style: TextStyle(color: Colors.red, fontSize: 17),
                    ),
                  );
                }

                return Container(
                  padding: const EdgeInsets.all(10),
                  color: Theme.of(context).colorScheme.surface,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: messageController,
                          decoration: InputDecoration(
                            hintText: "Type a message",
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.secondary,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: isSending
                            ? const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : IconButton(
                                icon: const Icon(
                                  Icons.send,
                                  color: Colors.white,
                                ),
                                onPressed: sendMessage,
                              ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
