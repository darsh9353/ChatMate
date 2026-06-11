class UserModel {
  final String uid;
  final String name;
  final String profileImage;
  final String phoneNumber;
  final bool isOnline;
  final DateTime lastSeen;
  final String? fcmToken;

  const UserModel({
    required this.uid,
    required this.name,
    required this.profileImage,
    required this.phoneNumber,
    required this.isOnline,
    required this.lastSeen,
    this.fcmToken,
  });

  Map<String, dynamic> toMap() {
    //Object → Map (send to Firebase)
    return {
      'uid': uid,
      'name': name,
      'phoneNumber': phoneNumber,
      'profileImage': profileImage,
      'isOnline': isOnline,
      'lastSeen': lastSeen.millisecondsSinceEpoch,
      if (fcmToken != null) 'fcmToken': fcmToken,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    //Map → Object (get from Firebase)

    return UserModel(
      uid: map['uid'] as String? ?? '',
      name: map['name'] as String? ?? '',
      phoneNumber: map['phoneNumber'] as String? ?? '',
      profileImage: map['profileImage'] as String? ?? '',
      isOnline: map['isOnline'] as bool? ?? false,

      lastSeen: map['lastSeen'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastSeen'])
          : DateTime.now(),
      fcmToken: map['fcmToken'] as String?,
    );
  }
}
