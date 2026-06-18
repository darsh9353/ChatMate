import 'package:chatmate/l10n/app_localizations.dart';
import 'package:chatmate/models/discover_contact_result.dart';
import 'package:chatmate/screens/chat_screen/chat_screen.dart';
import 'package:chatmate/services/discover_people_service.dart';
import 'package:chatmate/services/invite_service.dart';
import 'package:chatmate/utils/chat_util.dart';
import 'package:chatmate/utils/phone_util.dart';
import 'package:chatmate/widgets/user_avathar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class DiscoverPeopleScreen extends StatefulWidget {
  final String currentUserId;

  const DiscoverPeopleScreen({super.key, required this.currentUserId});

  @override
  State<DiscoverPeopleScreen> createState() => _DiscoverPeopleScreenState();
}

class _DiscoverPeopleScreenState extends State<DiscoverPeopleScreen> {
  final TextEditingController _searchController = TextEditingController();
  final DiscoverPeopleService _discoverService = DiscoverPeopleService();
  final InviteService _inviteService = InviteService();

  List<DiscoverContactResult> _results = [];
  bool _isSearching = false;
  bool _hasSearched = false;
  bool _permissionDenied = false;
  String _lastQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _runSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _isSearching = true;
      _hasSearched = true;
      _permissionDenied = false;
      _lastQuery = query;
    });

    final granted = await _discoverService.requestContactsPermission();
    if (!granted) {
      if (!mounted) return;
      setState(() {
        _isSearching = false;
        _permissionDenied = true;
        _results = [];
      });
      return;
    }

    try {
      final results = await _discoverService.search(
        query: query,
        currentUserId: widget.currentUserId,
      );

      if (!mounted) return;
      setState(() {
        _results = results;
        _isSearching = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSearching = false;
        _results = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)?.somethingWentWrong ??
                'Something went wrong',
          ),
        ),
      );
    }
  }

  void _openChat(DiscoverContactResult result) {
    final user = result.registeredUser!;
    final chatId = ChatService().generateChatId(widget.currentUserId, user.uid);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          currentUserId: widget.currentUserId,
          chatId: chatId,
          otherUserId: user.uid,
          otherUserName: user.name,
        ),
      ),
    );
  }

  Future<void> _sendInvite(DiscoverContactResult result) async {
    final sent = await _inviteService.sendSmsInvite(result.phoneNumber);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          sent
              ? (AppLocalizations.of(context)?.inviteSent ?? 'Invite sent')
              : (AppLocalizations.of(context)?.couldNotOpenSms ??
                    'Could not open SMS app'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.discoverPeople ?? 'Discover People'),
        backgroundColor: theme.colorScheme.secondary,
        systemOverlayStyle: theme.brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _runSearch(),
                    decoration: InputDecoration(
                      hintText: l10n?.discoverSearchHint ??
                          'Search by name or phone number',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _results = [];
                                  _hasSearched = false;
                                  _permissionDenied = false;
                                  _lastQuery = '';
                                });
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _isSearching ? null : _runSearch,
                  child: Text(l10n?.searchPeople ?? 'Search'),
                ),
              ],
            ),
          ),
          Expanded(child: _buildBody(theme, l10n)),
        ],
      ),
    );
  }

  Widget _buildBody(ThemeData theme, AppLocalizations? l10n) {
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_permissionDenied) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.contacts_outlined, size: 56, color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                l10n?.contactsPermissionRequired ??
                    'Contacts permission is required to search people on your device.',
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: openAppSettings,
                child: Text(l10n?.openSettings ?? 'Open Settings'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_hasSearched) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.person_search, size: 64, color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                l10n?.discoverEmptyTitle ?? 'Find people from your phone',
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n?.discoverEmptySubtitle ??
                    'Search by contact name or mobile number. '
                    'Your full contact list is never shown here.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_results.isEmpty) {
      return Center(
        child: Text(
          l10n?.discoverNoResults ?? 'No matching contacts found for "$_lastQuery"',
        ),
      );
    }

    return ListView.separated(
      itemCount: _results.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final result = _results[index];
        return _DiscoverResultTile(
          result: result,
          onChat: () => _openChat(result),
          onInvite: () => _sendInvite(result),
        );
      },
    );
  }
}

class _DiscoverResultTile extends StatelessWidget {
  final DiscoverContactResult result;
  final VoidCallback onChat;
  final VoidCallback onInvite;

  const _DiscoverResultTile({
    required this.result,
    required this.onChat,
    required this.onInvite,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final registered = result.registeredUser;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: registered != null
          ? UserAvatar(userId: registered.uid)
          : CircleAvatar(
              backgroundColor: theme.colorScheme.secondary,
              child: Text(
                result.displayName.isNotEmpty
                    ? result.displayName[0].toUpperCase()
                    : '?',
                style: TextStyle(color: theme.colorScheme.onSecondary),
              ),
            ),
      title: Text(
        registered?.name ?? result.displayName,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(PhoneUtil.toIndiaE164(result.phoneNumber)),
          const SizedBox(height: 4),
          Text(
            result.isRegistered
                ? (l10n?.onChatMate ?? 'On ChatMate')
                : (l10n?.notOnChatMate ?? 'Not on ChatMate yet'),
            style: TextStyle(
              color: result.isRegistered ? Colors.green : theme.colorScheme.outline,
              fontSize: 12,
            ),
          ),
        ],
      ),
      trailing: result.isRegistered
          ? FilledButton(
              onPressed: onChat,
              child: Text(l10n?.startChat ?? 'Chat'),
            )
          : OutlinedButton(
              onPressed: onInvite,
              child: Text(l10n?.sendInvite ?? 'Invite'),
            ),
    );
  }
}
