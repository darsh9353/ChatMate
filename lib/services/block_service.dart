import 'package:cloud_firestore/cloud_firestore.dart';

class BlockService {
  final FirebaseFirestore firestore;

  BlockService(this.firestore);

  Future<void> blockUser(String currentUserId, String targetUserId) async {
    await firestore.collection('users').doc(currentUserId).update({
      'blockedUsers': FieldValue.arrayUnion([targetUserId]),
    });
  }

  Future<void> unblockUser(String currentUserId, String targetUserId) async {
    await firestore.collection('users').doc(currentUserId).update({
      'blockedUsers': FieldValue.arrayRemove([targetUserId]),
    });
  }

  Future<bool> isBlockedByMe(String currentUserId, String targetUserId) async {
    final doc = await firestore.collection('users').doc(currentUserId).get();

    final blocked = List<String>.from(doc.data()?['blockedUsers'] ?? []);
    return blocked.contains(targetUserId);
  }

  Future<bool> isBlockedByOther(
    String currentUserId,
    String targetUserId,
  ) async {
    final doc = await firestore.collection('users').doc(targetUserId).get();

    final blocked = List<String>.from(doc.data()?['blockedUsers'] ?? []);
    return blocked.contains(currentUserId);
  }
}
