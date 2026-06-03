import 'package:flutter/material.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  // 🔥 Dummy contacts
  List<Map<String, dynamic>> getContacts() {
    return [
      {"id": "1", "name": "Elena Rodriguez"},
      {"id": "2", "name": "Marcus Chen"},
      {"id": "3", "name": "Julian Barnes"},
      {"id": "4", "name": "Sarah Higgins"},
      {"id": "5", "name": "Lila Voss"},
      {"id": "6", "name": "David Smith"},
    ];
  }

  @override
  Widget build(BuildContext context) {
    final contacts = getContacts();

    return Scaffold(
      appBar: AppBar(title: const Text("All Contacts")),

      body: ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          final contact = contacts[index];

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: CircleAvatar(child: Text(contact['name'][0])),
              title: Text(contact['name']),

              // 🔥 Send selected contact back
              onTap: () {
                Navigator.pop(context, contact);
              },
            ),
          );
        },
      ),
    );
  }
}
