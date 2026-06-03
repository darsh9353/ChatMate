import 'package:chatmate/widgets/app_background.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';
import '../repositories/chat_repository.dart';
import '../models/chat_model.dart';

class ContactsScreen extends StatelessWidget {
  final String currentUserId;

  const ContactsScreen({super.key, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    final userRepo = UserRepository();
    final chatRepo = ChatRepository();

    return Scaffold(
      appBar: AppBar(title: const Text("All Contacts")),

      body: AppBackground(
        child: StreamBuilder<List<UserModel>>(
          stream: userRepo.getUsers(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final users = snapshot.data!
                .where((user) => user.uid != currentUserId)
                .toList();

            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];

                return ListTile(
                  leading: CircleAvatar(child: Text(user.name[0])),
                  title: Text(user.name),

                  onTap: () async {
                    final chatId = getChatId(currentUserId, user.uid);

                    final chat = ChatModel(
                      chatId: chatId,
                      participants: [currentUserId, user.uid],
                      lastMessage: "",
                      timestamp: DateTime.now(),
                    );

                    await chatRepo.createChat(chat);

                    Navigator.pop(context);
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  // Generate unique chatId
  String getChatId(String uid1, String uid2) {
    return uid1.hashCode <= uid2.hashCode ? "$uid1\_$uid2" : "$uid2\_$uid1";
  }
}
