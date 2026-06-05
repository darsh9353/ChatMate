import 'dart:io';

import 'package:chatmate/screens/chat_screen.dart';
import 'package:chatmate/screens/settings_screen.dart';
import 'package:chatmate/widgets/app_background.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../repositories/chat_repository.dart';
import '../models/chat_model.dart';
import 'contacts_screen.dart';
import 'package:chatmate/widgets/user_avathar.dart';

class HomeScreen extends StatelessWidget {
  final String currentUserId;

  const HomeScreen({super.key, required this.currentUserId});

  Stream<DocumentSnapshot> getUserData(String uid) {
    return FirebaseFirestore.instance.collection('users').doc(uid).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final chatRepo = ChatRepository();

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("ChatMate"),
          actions: [
            StreamBuilder<DocumentSnapshot>(
              stream: getUserData(currentUserId),
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
                      //  Profile Image (LOCAL ONLY)
                      CircleAvatar(
                        radius: 18,
                        backgroundImage:
                            (imagePath.isNotEmpty &&
                                imagePath.startsWith('http'))
                            ? NetworkImage(imagePath)
                            : null,
                        onBackgroundImageError: (_, _) {
                          // if fails to load
                          print("Image load failed");
                        },
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
                                imagePath: imagePath, // from Firestore
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
          child: StreamBuilder<List<ChatModel>>(
            stream: chatRepo.getUserChats(currentUserId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final chats = snapshot.data!;

              if (chats.isEmpty) {
                return const Center(child: Text("No chats yet"));
              }

              return ListView.builder(
                itemCount: chats.length,
                itemBuilder: (context, index) {
                  final chat = chats[index];
                  final otherUserId = chat.participants.firstWhere(
                    (id) => id != currentUserId,
                  );

                  final otherUserName =
                      chat.participantNames[otherUserId] ?? "User";

                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 5),

                    decoration: BoxDecoration(
                      color: Colors.grey.shade200, //grey background
                      borderRadius: BorderRadius.circular(12),
                    ),

                    child: ListTile(
                      leading: UserAvatar(userId: otherUserId),

                      title: Text(otherUserName),
                      subtitle: Text(chat.lastMessage),
                      trailing: Text(
                        "${chat.timestamp.hour.toString().padLeft(2, '0')}:"
                        "${chat.timestamp.minute.toString().padLeft(2, '0')}",
                      ),
                      //
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(
                              chatId: chat.chatId,
                              currentUserId: currentUserId,
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
            },
          ),
        ),

        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ContactsScreen(currentUserId: currentUserId),
              ),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
