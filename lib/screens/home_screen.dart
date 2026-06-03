import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'contacts_screen.dart';

class ChatModel {
  final String id;
  final String name;
  final String lastMessage;
  final String time;

  ChatModel({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.time,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatModel> chats = [];

  // 🔥 Add chat when contact is clicked
  void addChat(Map<String, dynamic> contact) {
    final exists = chats.any((chat) => chat.id == contact['id']);

    if (!exists) {
      setState(() {
        chats.add(
          ChatModel(
            id: contact['id'],
            name: contact['name'],
            lastMessage: "Start chatting...",
            time: "Now",
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ChatMate"),
        actions: [
          Row(
            children: [
              CircleAvatar(
                radius: 10,
                backgroundColor: Theme.of(context).colorScheme.secondary,
              ),
              Icon(Icons.settings),
            ],
          ),
        ],
      ),

      body: chats.isEmpty
          ? const Center(child: Text("No chats yet"))
          : ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final chat = chats[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(child: Text(chat.name[0])),
                    title: Text(chat.name),
                    subtitle: Text(chat.lastMessage),
                    trailing: Text(chat.time),
                  ),
                );
              },
            ),

      // 🔥 Open contacts
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final selectedContact = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ContactsScreen()),
          );

          if (selectedContact != null) {
            addChat(selectedContact);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
