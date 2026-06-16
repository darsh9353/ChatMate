class BlockState {
  final bool isBlockedByMe;
  final bool isBlockedByOther;
  final bool isLoading;

  BlockState({
    this.isBlockedByMe = false,
    this.isBlockedByOther = false,
    this.isLoading = false,
  });

  BlockState copyWith({
    bool? isBlockedByMe,
    bool? isBlockedByOther,
    bool? isLoading,
  }) {
    return BlockState(
      isBlockedByMe: isBlockedByMe ?? this.isBlockedByMe,
      isBlockedByOther: isBlockedByOther ?? this.isBlockedByOther,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
