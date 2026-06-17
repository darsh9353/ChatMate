import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chatmate/widgets/user_avathar.dart';
import 'package:chatmate/blocs/block/block_bloc.dart';
import 'package:chatmate/blocs/block/block_event.dart';
import 'package:chatmate/blocs/block/block_state.dart';
import 'package:chatmate/l10n/app_localizations.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String currentUserId;
  final String otherUserId;
  final String otherUserName;

  const ChatAppBar({
    super.key,
    required this.currentUserId,
    required this.otherUserId,
    required this.otherUserName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      backgroundColor: theme.colorScheme.secondary,
      title: Row(
        children: [
          UserAvatar(userId: otherUserId, radius: 16),
          const SizedBox(width: 10),
          Text(otherUserName),
        ],
      ),
      actions: [
        BlocBuilder<BlockBloc, BlockState>(
          builder: (context, state) {
            return PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'block') {
                  context.read<BlockBloc>().add(
                    BlockUserEvent(currentUserId, otherUserId),
                  );
                } else {
                  context.read<BlockBloc>().add(
                    UnblockUserEvent(currentUserId, otherUserId),
                  );
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: state.isBlockedByMe ? 'unblock' : 'block',
                  child: Text(
                    state.isBlockedByMe
                        ? AppLocalizations.of(context)?.unblockUser ??
                              'Unblock User'
                        : AppLocalizations.of(context)?.blockUser ??
                              'Block User',
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
