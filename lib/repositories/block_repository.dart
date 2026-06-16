import '../services/block_service.dart';

class BlockRepository {
  final BlockService service;

  BlockRepository(this.service);

  Future<void> blockUser(String currentUserId, String targetUserId) {
    return service.blockUser(currentUserId, targetUserId);
  }

  Future<void> unblockUser(String currentUserId, String targetUserId) {
    return service.unblockUser(currentUserId, targetUserId);
  }

  Future<Map<String, bool>> checkBlockStatus(
    String currentUserId,
    String targetUserId,
  ) async {
    final isBlockedByMe = await service.isBlockedByMe(
      currentUserId,
      targetUserId,
    );

    final isBlockedByOther = await service.isBlockedByOther(
      currentUserId,
      targetUserId,
    );

    return {
      "isBlockedByMe": isBlockedByMe,
      "isBlockedByOther": isBlockedByOther,
    };
  }
}
