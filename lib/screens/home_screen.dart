import 'dart:io';

import 'package:chatmate/screens/settings_screen.dart';
import 'package:chatmate/widgets/app_background.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../repositories/chat_repository.dart';
import '../models/chat_model.dart';
import 'contacts_screen.dart';

class HomeScreen extends StatelessWidget {
  final String currentUserId;

  const HomeScreen({super.key, required this.currentUserId});

  Stream<DocumentSnapshot> getUserData(String uid) {
    return FirebaseFirestore.instance.collection('users').doc(uid).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final chatRepo = ChatRepository();

    return Scaffold(
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
                    // 🔥 Profile Image (LOCAL ONLY)
                    CircleAvatar(
                      radius: 18,
                      backgroundImage: imagePath.isNotEmpty
                          ? FileImage(File(imagePath))
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
          stream: chatRepo.getChats(currentUserId),
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

                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(
                    chat.participants.where((id) => id != currentUserId).first,
                  ),
                  subtitle: Text(chat.lastMessage),
                  trailing: Text(
                    "${chat.timestamp.hour}:${chat.timestamp.minute}",
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
    );
  }
}
