import 'dart:io';
import 'package:chatmate/widgets/app_background.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  final String name;
  final String imagePath;

  const SettingsScreen({
    super.key,
    required this.name,
    required this.imagePath,
  });

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

            //  PROFILE CARD
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
                            ? FileImage(File(imagePath))
                            : null,
                        child: imagePath.isEmpty
                            ? const Icon(Icons.person, size: 40)
                            : null,
                      ),

                      CircleAvatar(
                        radius: 18,
                        backgroundColor: theme.colorScheme.primary,
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 18,
                        ),
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

            //  SIMPLE BUTTONS
            SizedBox(
              width: width * 0.7,
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade100,
                ),
                onPressed: () {
                  // Logout logic
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
                onPressed: () {
                  // Logout logic
                },
                child: const Text("Logout"),
              ),
            ),
          ],
        ),
      ),

      //  SIMPLE BOTTOM NAVIGATION
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2, // Settings selected
        onTap: (index) {
          if (index == 0) {
            // Navigate to Chats
          } else if (index == 1) {
            // Navigate to Contacts
          } else if (index == 2) {
            // Already in Settings
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
