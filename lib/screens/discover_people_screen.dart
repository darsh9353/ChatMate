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
  List<DiscoverContactResult> _allContacts = [];
  bool _isLoading = true;
  bool _permissionDenied = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadDeviceContacts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDeviceContacts() async {
    setState(() {
      _isLoading = true;
      _permissionDenied = false;
    });

    final granted = await _discoverService.requestContactsPermission();
    if (!granted) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _permissionDenied = true;
        _allContacts = [];
        _results = [];
      });
      return;
    }

    try {
      // Load all device contacts at once
      final results = await _discoverService.loadAllDeviceContacts(
        currentUserId: widget.currentUserId,
      );

      if (!mounted) return;
      setState(() {
        _allContacts = results;
        _results = results;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _allContacts = [];
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

  void _filterContacts(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      if (_searchQuery.isEmpty) {
        _results = _allContacts;
      } else {
        _results = _allContacts.where((contact) {
          final name = contact.displayName.toLowerCase();
          final phone = contact.phoneNumber.toLowerCase();
          return name.contains(_searchQuery) || phone.contains(_searchQuery);
        }).toList();
      }
    });
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
        title: Text(l10n?.allContacts ?? 'All Contacts'),
        backgroundColor: theme.colorScheme.secondary,
        systemOverlayStyle: theme.brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: TextField(
              controller: _searchController,
              onChanged: _filterContacts,
              decoration: InputDecoration(
                hintText:
                    l10n?.discoverSearchHint ??
                    'Search by name or phone number',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterContacts('');
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
            ),
          ),
          Expanded(child: _buildBody(theme, l10n)),
        ],
      ),
    );
  }

  Widget _buildBody(ThemeData theme, AppLocalizations? l10n) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_permissionDenied) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.contacts_outlined,
                size: 56,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                l10n?.contactsPermissionRequired ??
                    'Contacts permission is required to view your contacts.',
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

    if (_results.isEmpty) {
      return Center(
        child: Text(
          l10n?.noUsersFound ??
              'No contacts found',
        ),
      );
    }

    return ListView.builder(
      itemCount: _results.length,
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
              color: result.isRegistered
                  ? Colors.green
                  : theme.colorScheme.outline,
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
