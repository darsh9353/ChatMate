import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserAvatar extends StatelessWidget {
  final String userId;
  final double radius;

  const UserAvatar({super.key, required this.userId, this.radius = 20});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircleAvatar(radius: radius);
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final imageUrl = data['profileImage'] ?? '';
        final name = data['name'] ?? '';

        return CircleAvatar(
          radius: radius,
          backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
          child: imageUrl.isEmpty
              ? Text(name.isNotEmpty ? name[0].toUpperCase() : "?")
              : null,
        );
      },
    );
  }
}
