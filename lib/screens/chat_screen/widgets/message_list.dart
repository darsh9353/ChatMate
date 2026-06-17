import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chatmate/blocs/chat/chat_bloc.dart';
import 'package:chatmate/blocs/chat/chat_event.dart';
import 'package:chatmate/blocs/chat/chat_state.dart';
import 'package:chatmate/l10n/app_localizations.dart';
import 'package:chatmate/utils/date_formatter.dart';

class MessageList extends StatelessWidget {
  final String currentUserId;
  final String chatId;
  final ScrollController scrollController;

  const MessageList({
    super.key,
    required this.currentUserId,
    required this.chatId,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          if (state is ChatLoaded) {
            final messages = state.messages.where((msg) {
              return !msg.deletedFor.contains(currentUserId);
            }).toList();

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (scrollController.hasClients) {
                scrollController.jumpTo(0);
              }
            });

            if (messages.isEmpty) {
              return Center(
                child: Text(AppLocalizations.of(context)?.sayHi ?? "Say Hi"),
              );
            }

            return ListView.builder(
              controller: scrollController,
              reverse: true,
              padding: const EdgeInsets.all(10),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[messages.length - 1 - index];
                final isMe = msg.senderId == currentUserId;

                if (msg.deletedFor.contains(currentUserId)) {
                  return const SizedBox();
                }

                return GestureDetector(
                  onLongPress: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (_) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              title: Text(
                                AppLocalizations.of(context)?.deleteForMe ??
                                    "Delete for me",
                              ),
                              onTap: () {
                                context.read<ChatBloc>().add(
                                  DeleteForMeEvent(
                                    chatId,
                                    msg.messageId,
                                    currentUserId,
                                  ),
                                );
                                Navigator.pop(context);
                              },
                            ),
                            if (isMe)
                              ListTile(
                                title: Text(
                                  AppLocalizations.of(
                                        context,
                                      )?.deleteForEveryone ??
                                      "Delete For Everyone",
                                ),
                                onTap: () {
                                  context.read<ChatBloc>().add(
                                    DeleteForEveryoneEvent(
                                      chatId,
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

                  onDoubleTap: () {
                    showDialog(
                      context: context,
                      builder: (_) {
                        return AlertDialog(
                          content: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: ["👍", "❤️", "😂", "😮", "😢"].map((
                              emoji,
                            ) {
                              return GestureDetector(
                                onTap: () {
                                  context.read<ChatBloc>().add(
                                    AddReactionEvent(
                                      chatId,
                                      msg.messageId,
                                      currentUserId,
                                      emoji,
                                    ),
                                  );
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  emoji,
                                  style: const TextStyle(fontSize: 26),
                                ),
                              );
                            }).toList(),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                msg.message,
                                style: TextStyle(
                                  fontStyle:
                                      msg.message == "This message was deleted"
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
                                    DateFormatter.formatChatTime(msg.timestamp),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isMe
                                          ? theme.colorScheme.onPrimary
                                          : theme.colorScheme.onSecondary,
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

                          if (msg.reactions.isNotEmpty)
                            Positioned(
                              bottom: -20,
                              right: -20,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: msg.reactions.values.map((emoji) {
                                    return Text(
                                      emoji,
                                      style: const TextStyle(fontSize: 14),
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

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
