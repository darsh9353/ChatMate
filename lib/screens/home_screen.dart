import 'package:chatmate/repositories/chat_repository.dart';
import 'package:chatmate/screens/chat_screen.dart';
import 'package:chatmate/screens/settings_screen.dart';
import 'package:chatmate/widgets/app_background.dart';
import 'package:chatmate/widgets/bottom_navbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chatmate/models/chat_model.dart';
import 'contacts_screen.dart';
import 'package:chatmate/widgets/user_avathar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:chatmate/blocs/chat_list/chat_list_bloc.dart';
import 'package:chatmate/blocs/chat_list/chat_list_event.dart';
import 'package:chatmate/services/notification_service.dart';
import 'package:chatmate/utils/date_formatter.dart';
import 'package:chatmate/blocs/chat_list/chat_list_state.dart';

class HomeScreen extends StatefulWidget {
  final String currentUserId;

  const HomeScreen({super.key, required this.currentUserId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    context.read<ChatListBloc>().add(LoadUserChatsEvent(widget.currentUserId));
    NotificationService.instance.saveTokenForUser(widget.currentUserId);
    NotificationService.instance.handlePendingNavigation(widget.currentUserId);
  }

  Stream<DocumentSnapshot> getUserData(String uid) {
    return FirebaseFirestore.instance.collection('users').doc(uid).snapshots();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("ChatMate"),
          backgroundColor: theme.colorScheme.secondary,
          systemOverlayStyle: theme.brightness == Brightness.dark
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle.dark,
          actions: [
            StreamBuilder<DocumentSnapshot>(
              stream: getUserData(widget.currentUserId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: CircleAvatar(radius: 18),
                  );
                }

                final data = snapshot.data!.data() as Map<String, dynamic>;
                final imagePath = data['profileImage'] ?? '';

                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundImage:
                            (imagePath.isNotEmpty &&
                                imagePath.startsWith('http'))
                            ? NetworkImage(imagePath)
                            : null,
                        child: imagePath.isEmpty
                            ? const Icon(Icons.person)
                            : null,
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),

        body: Column(
          children: [
            ///  SEARCH BAR
            Material(
              //for elevation purpose
              elevation: 2,
              child: TextField(
                controller: _searchController,

                onChanged: (value) {
                  setState(() {
                    searchQuery = value.toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  fillColor: theme.colorScheme.surface,
                  hintText: "Search chats...",
                  prefixIcon: const Icon(Icons.search),

                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              searchQuery = "";
                            });
                          },
                        )
                      : null,

                  filled: true,

                  contentPadding: const EdgeInsets.symmetric(vertical: 14),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            ///  CHAT LIST
            Expanded(
              child: BlocBuilder<ChatListBloc, ChatListState>(
                builder: (context, state) {
                  if (state is ChatListLoaded) {
                    final chats = state.chats.where((chat) {
                      final hiddenFor = (chat as dynamic).hiddenFor ?? [];
                      return !hiddenFor.contains(widget.currentUserId);
                    }).toList();

                    ///  FILTER LOGIC
                    final filteredChats = chats.where((chat) {
                      final otherUserId = chat.participants.firstWhere(
                        (id) => id != widget.currentUserId,
                      );

                      final name = chat.participantNames[otherUserId] ?? "User";

                      return name.toLowerCase().contains(searchQuery);
                    }).toList();

                    if (filteredChats.isEmpty) {
                      return const Center(child: Text("No matching chats"));
                    }

                    return ListView.builder(
                      itemCount: filteredChats.length,
                      itemBuilder: (context, index) {
                        final chat = filteredChats[index];

                        final otherUserId = chat.participants.firstWhere(
                          (id) => id != widget.currentUserId,
                        );

                        final otherUserName =
                            chat.participantNames[otherUserId] ?? "User";

                        return Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 0,
                            vertical: 0,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondary,
                          ),
                          child: ListTile(
                            leading: UserAvatar(userId: otherUserId),
                            title: Text(
                              otherUserName,
                              style: TextStyle(
                                color: theme.colorScheme.onSecondary,
                              ),
                            ),
                            subtitle: Row(
                              children: [
                                //  SHOW TICK ONLY IF CURRENT USER SENT LAST MESSAGE
                                if (chat.lastMessageSenderId ==
                                    widget.currentUserId) ...[
                                  Icon(
                                    Icons.done_all,
                                    size: 16,
                                    color: chat.lastMessageSeen
                                        ? const Color.fromARGB(
                                            255,
                                            8,
                                            26,
                                            187,
                                          ) //  SEEN
                                        : theme
                                              .colorScheme
                                              .onSecondary, // NOT SEEN
                                  ),
                                  const SizedBox(width: 5),
                                ],

                                Expanded(
                                  child: Text(
                                    chat.lastMessage,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: theme.colorScheme.onSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            trailing: Text(
                              DateFormatter.formatChatTime(chat.timestamp),
                              style: TextStyle(
                                color: theme.colorScheme.onSecondary,
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatScreen(
                                    chatId: chat.chatId,
                                    currentUserId: widget.currentUserId,
                                    otherUserId: otherUserId,
                                    otherUserName: otherUserName,
                                  ),
                                ),
                              );
                            },
                            onLongPress: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text("Delete Chat"),
                                    content: const Text(
                                      "Do you want to delete this chat?",
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context); // CANCEL
                                        },
                                        child: const Text("Cancel"),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          Navigator.pop(context);

                                          context.read<ChatListBloc>().add(
                                            DeleteChatForMeEvent(
                                              chat.chatId,
                                              widget.currentUserId,
                                            ),
                                          );
                                        },
                                        child: const Text("Delete"),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        );
                      },
                    );
                  }

                  if (state is ChatListError) {
                    return Center(child: Text(state.message));
                  }

                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ],
        ),

        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    ContactsScreen(currentUserId: widget.currentUserId),
              ),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
