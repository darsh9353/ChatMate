import 'package:chatmate/utils/phone_util.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class AllContactsService {
  List<Contact>? _cachedContacts;

  Future<bool> requestPermission() async {
    return FlutterContacts.requestPermission(readonly: true);
  }

  Future<List<Contact>> _loadContacts() async {
    _cachedContacts ??= await FlutterContacts.getContacts(withProperties: true);
    return _cachedContacts!;
  }

  /// Returns all device contacts.
  /// Contacts are loaded and cached for later use.
  Future<List<({String name, String phone, String normalizedPhone})>>
  getAllContacts() async {
    final contacts = await _loadContacts();
    final results = <({String name, String phone, String normalizedPhone})>[];
    final seenPhones = <String>{};

    for (final contact in contacts) {
      final name = contact.displayName.trim();
      if (name.isEmpty && contact.phones.isEmpty) continue;

      for (final phoneEntry in contact.phones) {
        final phone = phoneEntry.number.trim();
        if (phone.isEmpty) continue;

        final normalized = PhoneUtil.normalize(phone);
        if (normalized.length != 10) continue;
        if (seenPhones.contains(normalized)) continue;

        seenPhones.add(normalized);
        results.add((
          name: name.isEmpty ? phone : name,
          phone: phone,
          normalizedPhone: normalized,
        ));
      }
    }

    results.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
    return results;
  }

  /// Returns device contacts whose name or phone matches [query].
  /// Contacts are loaded only when this method is called (after user searches).
  Future<List<({String name, String phone, String normalizedPhone})>> search(
    String query,
  ) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    final contacts = await _loadContacts();
    final queryLower = trimmed.toLowerCase();
    final queryDigits = trimmed.replaceAll(RegExp(r'\D'), '');
    final results = <({String name, String phone, String normalizedPhone})>[];
    final seenPhones = <String>{};

    for (final contact in contacts) {
      final name = contact.displayName.trim();
      if (name.isEmpty && contact.phones.isEmpty) continue;

      for (final phoneEntry in contact.phones) {
        final phone = phoneEntry.number.trim();
        if (phone.isEmpty) continue;

        final normalized = PhoneUtil.normalize(phone);
        if (normalized.length != 10) continue;
        if (seenPhones.contains(normalized)) continue;

        final phoneDigits = phone.replaceAll(RegExp(r'\D'), '');
        final nameMatches = name.toLowerCase().contains(queryLower);
        final phoneMatches =
            queryDigits.isNotEmpty &&
            (phoneDigits.contains(queryDigits) ||
                normalized.contains(queryDigits));

        if (!nameMatches && !phoneMatches) continue;

        seenPhones.add(normalized);
        results.add((
          name: name.isEmpty ? phone : name,
          phone: phone,
          normalizedPhone: normalized,
        ));
      }
    }

    results.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
    return results;
  }

  void clearCache() => _cachedContacts = null;
}
