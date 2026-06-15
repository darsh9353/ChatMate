import 'dart:io';
import 'package:chatmate/models/user_model.dart';
import 'package:chatmate/repositories/auth_repository.dart';
import 'package:chatmate/screens/home_screen.dart';
import 'package:chatmate/screens/main_screen.dart';
import 'package:chatmate/services/image_service.dart';
import 'package:chatmate/services/notification_service.dart';
import 'package:chatmate/widgets/app_background.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class ProfileSetupScreen extends StatefulWidget {
  final bool isEdit; // ADD THIS

  const ProfileSetupScreen({
    super.key,
    this.isEdit = false, // default = first time login
  });

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final TextEditingController nameController = TextEditingController();

  File? selectedImage;
  String imageUrl = ''; //  store ImageKit URL

  final ImagePicker picker = ImagePicker();
  final ImageKitService imageService = ImageKitService();

  @override
  void initState() {
    super.initState();

    if (widget.isEdit) {
      loadUserData();
    }
  }

  Future<void> loadUserData() async {
    final user = context.read<AuthRepository>().getCurrentUser();

    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data()!;

        nameController.text = data['name'] ?? '';
        imageUrl = data['profileImage'] ?? '';

        setState(() {});
      }
    }
  }

  // Pick Image
  Future<void> pickImage() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        selectedImage = File(image.path); // preview
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.secondary,
        systemOverlayStyle: theme.brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        leading: const Icon(Icons.arrow_back),
        title: const Text(
          "ChatMate",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: AppBackground(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 10),

                Text(
                  "Set up profile",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black.withValues(alpha: 0.7),
                  ),
                ),

                const SizedBox(height: 25),

                // PROFILE IMAGE
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: theme.colorScheme.secondary,
                      backgroundImage: selectedImage != null
                          ? FileImage(selectedImage!) // preview
                          : (imageUrl.isNotEmpty
                                    ? NetworkImage(imageUrl) // after upload
                                    : null)
                                as ImageProvider?,
                      child: selectedImage == null && imageUrl.isEmpty
                          ? const Icon(Icons.person, size: 40)
                          : null,
                    ),

                    GestureDetector(
                      onTap: pickImage,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: theme.colorScheme.primary,
                        child: const Icon(Icons.add, color: Colors.white),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                const SizedBox(height: 6),

                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: "Enter your name",
                    filled: true,
                    fillColor: theme.colorScheme.secondary,
                    suffixIcon: const Icon(Icons.edit),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                //  CONTINUE BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      final name = nameController.text.trim();
                      final user = context
                          .read<AuthRepository>()
                          .getCurrentUser();

                      if (name.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Enter your name")),
                        );
                        return;
                      }

                      if (user == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("User not logged in")),
                        );
                        return;
                      }

                      // Upload image to ImageKit
                      if (selectedImage != null) {
                        final uploadedUrl = await imageService.uploadImage(
                          selectedImage!,
                        );

                        if (uploadedUrl != null) {
                          imageUrl = uploadedUrl;
                        }
                      }

                      try {
                        final newUser = UserModel(
                          uid: user.uid,
                          name: name,
                          phoneNumber: user.phoneNumber ?? "",
                          profileImage: imageUrl, // STORE URL
                          isOnline: true,
                          lastSeen: DateTime.now(),
                        );

                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(user.uid)
                            .set(newUser.toMap(), SetOptions(merge: true));

                        if (widget.isEdit) {
                          // Coming from Settings
                          Navigator.pop(
                            context,
                            {'name': name, 'image': imageUrl},
                          ); // go back to SettingsScreen (but data loading slowly)
                        } else {
                          await NotificationService.instance.saveTokenForUser(
                            user.uid,
                          );

                          if (!context.mounted) return;

                          //  Coming from Login flow
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => MainScreen()),
                            (route) => false,
                          );
                        }
                      } catch (e) {
                        print("Error: $e");
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Something went wrong")),
                        );
                      }
                    },
                    child: const Text(
                      "Continue",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
