class UserModel {
  final String uid;
  final String name;
  final String profileImage;
  final String phoneNumber;
  final bool isOnline;
  final DateTime lastSeen;
  final String? fcmToken;
  final List<String> blockedUsers;

  const UserModel({
    required this.uid,
    required this.name,
    required this.profileImage,
    required this.phoneNumber,
    required this.isOnline,
    required this.lastSeen,
    this.fcmToken,
    this.blockedUsers = const [],
  });

  //Save to Firestore
  Map<String, dynamic> toMap() {
    //converts use model to map
    return {
      'uid': uid,
      'name': name,
      'phoneNumber': phoneNumber,
      'profileImage': profileImage,
      'isOnline': isOnline,
      'lastSeen': lastSeen.millisecondsSinceEpoch,
      'blockedUsers': blockedUsers,
      if (fcmToken != null) 'fcmToken': fcmToken,
    };
  }

  //Read from Firestore
  factory UserModel.fromMap(Map<String, dynamic> map) {
    //converts map to userModel
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      profileImage: map['profileImage'] ?? '',
      isOnline: map['isOnline'] ?? false,
      lastSeen: map['lastSeen'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              map['lastSeen'],
            ) //convert to this format 2026-06-22 20:15
          : DateTime.now(),
      fcmToken: map['fcmToken'],
      blockedUsers: List<String>.from(map['blockedUsers'] ?? []),
    );
  }
}
