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
                    final chats = state.chats;

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
                            subtitle: Text(
                              chat.lastMessage,
                              style: TextStyle(
                                color: theme.colorScheme.onSecondary,
                              ),
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

        bottomNavigationBar: const MainBottomNav(currentIndex: 0),
      ),
    );
  }
}
