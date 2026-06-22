import 'package:chatmate/models/discover_contact_result.dart';
import 'package:chatmate/models/user_model.dart';
import 'package:chatmate/repositories/user_repository.dart';
import 'package:chatmate/services/device_contacts_service.dart';
import 'package:chatmate/utils/phone_util.dart';

class DiscoverPeopleService {
  DiscoverPeopleService({
    DeviceContactsService? deviceContactsService,
    UserRepository? userRepository,
  })  : _deviceContactsService = deviceContactsService ?? DeviceContactsService(),
        _userRepository = userRepository ?? UserRepository();

  final DeviceContactsService _deviceContactsService;
  final UserRepository _userRepository;

  Future<bool> requestContactsPermission() =>
      _deviceContactsService.requestPermission();

  Future<List<DiscoverContactResult>> loadAllDeviceContacts({
    required String currentUserId,
  }) async {
    final currentUser = await _userRepository.getUser(currentUserId);
    final currentUserPhone = currentUser != null
        ? PhoneUtil.normalize(currentUser.phoneNumber)
        : '';

    final allDeviceContacts = await _deviceContactsService.getAllContacts();
    if (allDeviceContacts.isEmpty) return [];

    final registeredByPhone = await _userRepository.getRegisteredUsersByPhone();

    return allDeviceContacts
        .where((entry) => entry.normalizedPhone != currentUserPhone)
        .map((entry) {
          final registered = registeredByPhone[entry.normalizedPhone];
          if (registered?.uid == currentUserId) return null;

          return DiscoverContactResult(
            displayName: entry.name,
            phoneNumber: entry.phone,
            normalizedPhone: entry.normalizedPhone,
            registeredUser: registered,
          );
        })
        .whereType<DiscoverContactResult>()
        .toList();
  }

  Future<List<DiscoverContactResult>> search({
    required String query,
    required String currentUserId,
  }) async {
    final currentUser = await _userRepository.getUser(currentUserId);
    final currentUserPhone = currentUser != null
        ? PhoneUtil.normalize(currentUser.phoneNumber)
        : '';

    final deviceMatches = await _deviceContactsService.search(query);
    if (deviceMatches.isEmpty) return [];

    final registeredByPhone = await _userRepository.getRegisteredUsersByPhone();

    return deviceMatches
        .where((entry) => entry.normalizedPhone != currentUserPhone)
        .map((entry) {
          final registered = registeredByPhone[entry.normalizedPhone];
          if (registered?.uid == currentUserId) return null;

          return DiscoverContactResult(
            displayName: entry.name,
            phoneNumber: entry.phone,
            normalizedPhone: entry.normalizedPhone,
            registeredUser: registered,
          );
        })
        .whereType<DiscoverContactResult>()
        .toList();
  }
}
