abstract class BlockEvent {}

class LoadBlockStatusEvent extends BlockEvent {
  final String currentUserId;
  final String targetUserId;

  LoadBlockStatusEvent(this.currentUserId, this.targetUserId);
}

class BlockUserEvent extends BlockEvent {
  final String currentUserId;
  final String targetUserId;

  BlockUserEvent(this.currentUserId, this.targetUserId);
}

class UnblockUserEvent extends BlockEvent {
  final String currentUserId;
  final String targetUserId;

  UnblockUserEvent(this.currentUserId, this.targetUserId);
}
