import 'package:chatmate/l10n/app_localizations.dart';
import 'package:chatmate/screens/chat_screen.dart';
import 'package:chatmate/widgets/user_avathar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';
import '../repositories/chat_repository.dart';
import 'package:chatmate/utils/chat_util.dart';

class ContactsScreen extends StatefulWidget {
  final String currentUserId;

  const ContactsScreen({super.key, required this.currentUserId});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userRepo = UserRepository();
    final chatRepo = ChatRepository();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)?.allContacts ?? "All Contacts",
        ),
        backgroundColor: theme.colorScheme.secondary,
        systemOverlayStyle: theme.brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),

      body: Column(
        children: [
          /// SEARCH BAR
          TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                searchQuery = value.toLowerCase();
              });
            },
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              hintText: "Discover People",
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
              fillColor: theme.colorScheme.surface,
              border: OutlineInputBorder(borderSide: BorderSide.none),
            ),
          ),

          ///  USER LIST
          Expanded(
            child: StreamBuilder<List<UserModel>>(
              stream: userRepo.getUsers(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                /// Remove current user
                final users = snapshot.data!
                    .where((user) => user.uid != widget.currentUserId)
                    .toList();

                ///  FILTER LOGIC (NAME + PHONE)
                final filteredUsers = users.where((user) {
                  final name = user.name.toLowerCase();
                  final phone = user.phoneNumber.toLowerCase();

                  return name.contains(searchQuery) ||
                      phone.contains(searchQuery);
                }).toList();

                if (filteredUsers.isEmpty) {
                  return const Center(child: Text("No users found"));
                }

                return ListView.builder(
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];

                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondary,
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                        leading: UserAvatar(userId: user.uid),

                        title: Text(
                          user.name,
                          style: TextStyle(
                            color: theme.colorScheme.onSecondary,
                          ),
                        ),

                        subtitle: Text(
                          user.phoneNumber,
                          style: TextStyle(
                            color: theme.colorScheme.onSecondary.withOpacity(
                              0.7,
                            ),
                          ),
                        ),

                        onTap: () {
                          final chatService = ChatService();

                          final chatId = chatService.generateChatId(
                            widget.currentUserId,
                            user.uid,
                          );

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                currentUserId: widget.currentUserId,
                                chatId: chatId,
                                otherUserId: user.uid,
                                otherUserName: user.name,
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
        ],
      ),
    );
  }
}
