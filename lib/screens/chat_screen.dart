import 'dart:io';
import 'package:chatmate/widgets/app_background.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  final String name;
  final String email;
  final String imagePath;

  const SettingsScreen({
    super.key,
    required this.name,
    required this.email,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFE8F0EF),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "ChatMate",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),

      body: AppBackground(
        child: Column(
          children: [
            const SizedBox(height: 20),

            //  PROFILE CARD
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  // 🔥 Profile Image
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

                  // 🔷 Name
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // 🔷 Email
                  Text(email, style: const TextStyle(color: Colors.grey)),

                  const SizedBox(height: 12),

                  // 🔷 Status Chips
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildChip(
                        "Premium User",
                        Colors.blue.shade100,
                        Colors.blue,
                      ),
                      const SizedBox(width: 10),
                      _buildChip("Online", Colors.green.shade100, Colors.green),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 🔷 Edit Profile Tile
            _buildOptionTile(
              icon: Icons.edit,
              text: "Edit Profile",
              iconBg: Colors.blue.shade100,
              iconColor: Colors.blue,
              onTap: () {},
            ),

            const SizedBox(height: 15),

            // 🔷 Logout Tile
            _buildOptionTile(
              icon: Icons.logout,
              text: "Logout",
              iconBg: Colors.red.shade100,
              iconColor: Colors.red,
              onTap: () {
                // TODO: logout logic
              },
            ),

            const Spacer(),

            // 🔷 Footer
            Column(
              children: const [
                Text("ChatMate v2.4.0", style: TextStyle(color: Colors.grey)),
                SizedBox(height: 5),
                Text(
                  "Made with care for connection",
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ),

      // 🔷 Bottom Navigation
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(Icons.chat, "Chats", false),
            _buildNavItem(Icons.contacts, "Contacts", false),
            _buildNavItem(Icons.settings, "Settings", true),
          ],
        ),
      ),
    );
  }

  // 🔷 Chip Widget
  Widget _buildChip(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
      ),
    );
  }

  // 🔷 Option Tile
  Widget _buildOptionTile({
    required IconData icon,
    required String text,
    required Color iconBg,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: iconBg,
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(width: 15),
              Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  // 🔷 Bottom Nav Item
  Widget _buildNavItem(IconData icon, String label, bool isSelected) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        isSelected
            ? Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade300,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(icon),
              )
            : Icon(icon),
        const SizedBox(height: 5),
        Text(label),
      ],
    );
  }
}
