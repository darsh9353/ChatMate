import 'package:flutter/material.dart';
import 'package:chatmate/l10n/app_localizations.dart';
import 'package:chatmate/blocs/block/block_state.dart';

class BlockStatusView extends StatelessWidget {
  final BlockState state;

  const BlockStatusView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.isBlockedByMe) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          AppLocalizations.of(context)?.youBlockedThisUser ??
              "You blocked this user",
          style: const TextStyle(color: Colors.red, fontSize: 17),
        ),
      );
    }

    if (state.isBlockedByOther) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          AppLocalizations.of(context)?.cannotMessageUser ??
              "You cannot message this user",
          style: const TextStyle(color: Colors.red, fontSize: 17),
        ),
      );
    }

    return const SizedBox();
  }
}
