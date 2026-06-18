import 'package:chatmate/utils/phone_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //  Save user profile
  Future<void> saveUser(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toMap());
  }

  // Get current user
  Future<UserModel?> getUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();

    if (doc.exists) {
      return UserModel.fromMap(doc.data()!);
    }
    return null;
  }

  //  Get all users (Contacts)
  Stream<List<UserModel>> getUsers() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
    });
  }

  /// Map of normalized phone (last 10 digits) → registered user.
  Future<Map<String, UserModel>> getRegisteredUsersByPhone() async {
    final snapshot = await _firestore.collection('users').get();
    final map = <String, UserModel>{};

    for (final doc in snapshot.docs) {
      final user = UserModel.fromMap(doc.data());
      final key = PhoneUtil.normalize(user.phoneNumber);
      if (key.length == 10) {
        map[key] = user;
      }
    }

    return map;
  }
}
