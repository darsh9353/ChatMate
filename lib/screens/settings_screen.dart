import 'package:chatmate/repositories/auth_repository.dart';
import 'package:chatmate/screens/contacts_screen.dart';
import 'package:chatmate/screens/home_screen.dart';
import 'package:chatmate/screens/login_screen.dart';
import 'package:chatmate/screens/profile_setup_screen.dart';
import 'package:chatmate/widgets/app_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsScreen extends StatefulWidget {
  final String name;
  final String imagePath;

  const SettingsScreen({
    super.key,
    required this.name,
    required this.imagePath,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late String name;
  late String imagePath;

  @override
  void initState() {
    super.initState();
    name = widget.name;
    imagePath = widget.imagePath;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "ChatMate",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: AppBackground(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // PROFILE CARD
            Container(
              width: width * 0.5,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 55,
                        backgroundColor: Colors.grey.shade300,

                        backgroundImage: imagePath.isNotEmpty
                            ? NetworkImage(imagePath)
                            : null,

                        child: imagePath.isEmpty
                            ? const Icon(Icons.person, size: 40)
                            : null,
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            //  BUTTONS
            SizedBox(
              width: width * 0.7,
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade100,
                ),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProfileSetupScreen(isEdit: true),
                    ),
                  );

                  if (result != null) {
                    setState(() {
                      name = result['name'];
                      imagePath = result['image'];
                    });
                  }
                },
                child: const Text("Edit Profile"),
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: width * 0.7,
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade100,
                ),
                onPressed: () async {
                  await context.read<AuthRepository>().logout();
                  //clear entire screen stack,After logout, user cannot go back to HomeScreen
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => LoginScreen()),
                    (route) => false,
                  );
                },
                child: const Text("Logout"),
              ),
            ),
          ],
        ),
      ),

      //  BOTTOM NAV
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        onTap: (index) {
          final user = context.read<AuthRepository>().getCurrentUser();

          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => HomeScreen(currentUserId: user!.uid),
              ),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => ContactsScreen(currentUserId: user!.uid),
              ),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chats"),
          BottomNavigationBarItem(
            icon: Icon(Icons.contacts),
            label: "Contacts",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
      ),
    );
  }
}
