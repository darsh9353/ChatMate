import 'package:flutter_bloc/flutter_bloc.dart';
import 'block_event.dart';
import 'block_state.dart';
import '../../repositories/block_repository.dart';

class BlockBloc extends Bloc<BlockEvent, BlockState> {
  final BlockRepository repository;

  BlockBloc(this.repository) : super(BlockState()) {
    on<LoadBlockStatusEvent>(_onLoadStatus);
    on<BlockUserEvent>(_onBlockUser);
    on<UnblockUserEvent>(_onUnblockUser);
  }

  Future<void> _onLoadStatus(
    LoadBlockStatusEvent event,
    Emitter<BlockState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    final result = await repository.checkBlockStatus(
      event.currentUserId,
      event.targetUserId,
    );

    emit(
      state.copyWith(
        isBlockedByMe: result['isBlockedByMe']!,
        isBlockedByOther: result['isBlockedByOther']!,
        isLoading: false,
      ),
    );
  }

  Future<void> _onBlockUser(
    BlockUserEvent event,
    Emitter<BlockState> emit,
  ) async {
    await repository.blockUser(event.currentUserId, event.targetUserId);

    add(LoadBlockStatusEvent(event.currentUserId, event.targetUserId));
  }

  Future<void> _onUnblockUser(
    UnblockUserEvent event,
    Emitter<BlockState> emit,
  ) async {
    await repository.unblockUser(event.currentUserId, event.targetUserId);

    add(LoadBlockStatusEvent(event.currentUserId, event.targetUserId));
  }
}
