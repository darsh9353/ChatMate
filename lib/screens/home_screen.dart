import 'package:chatmate/screens/chat_screen.dart';
import 'package:chatmate/screens/settings_screen.dart';
import 'package:chatmate/widgets/app_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chatmate/models/chat_model.dart';
import 'contacts_screen.dart';
import 'package:chatmate/widgets/user_avathar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:chatmate/blocs/chat_list/chat_list_bloc.dart';
import 'package:chatmate/blocs/chat_list/chat_list_event.dart';
import 'package:chatmate/utils/date_formatter.dart';
import 'package:chatmate/blocs/chat_list/chat_list_state.dart';

import 'package:chatmate/utils/date_formatter.dart';

class HomeScreen extends StatefulWidget {
  final String currentUserId;

  const HomeScreen({super.key, required this.currentUserId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    // USE ChatListBloc
    context.read<ChatListBloc>().add(LoadUserChatsEvent(widget.currentUserId));
  }

  Stream<DocumentSnapshot> getUserData(String uid) {
    return FirebaseFirestore.instance.collection('users').doc(uid).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("ChatMate"),
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
                      const SizedBox(width: 10),
                      IconButton(
                        icon: const Icon(Icons.settings),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SettingsScreen(
                                name: data['name'],
                                imagePath: imagePath,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),

        body: AppBackground(
          child: BlocBuilder<ChatListBloc, ChatListState>(
            builder: (context, state) {
              if (state is ChatListLoaded) {
                final chats = state.chats;

                if (chats.isEmpty) {
                  return const Center(child: Text("No chats yet"));
                }

                return ListView.builder(
                  itemCount: chats.length,
                  itemBuilder: (context, index) {
                    final chat = chats[index];

                    final otherUserId = chat.participants.firstWhere(
                      (id) => id != widget.currentUserId,
                    );

                    final otherUserName =
                        chat.participantNames[otherUserId] ?? "User";

                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 2,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: UserAvatar(userId: otherUserId),
                        title: Text(otherUserName),
                        subtitle: Text(chat.lastMessage),
                        trailing: Text(
                          DateFormatter.formatChatTime(chat.timestamp),
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

              //  Default loader
              return const Center(child: CircularProgressIndicator());
            },
          ),
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
