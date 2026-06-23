import 'package:chatmate/models/all_contact_result.dart';
import 'package:chatmate/models/user_model.dart';
import 'package:chatmate/repositories/user_repository.dart';
import 'package:chatmate/services/all_contacts_service.dart';
import 'package:chatmate/utils/phone_util.dart';

class AllPeopleService {
  AllPeopleService({
    AllContactsService? deviceContactsService,
    UserRepository? userRepository,
  }) : _deviceContactsService = deviceContactsService ?? AllContactsService(),
       _userRepository = userRepository ?? UserRepository();

  final AllContactsService _deviceContactsService;
  final UserRepository _userRepository;

  Future<bool> requestContactsPermission() =>
      _deviceContactsService.requestPermission();

  Future<List<AllContactResult>> loadAllDeviceContacts({
    required String currentUserId,
  }) async {
    final currentUser = await _userRepository.getUser(currentUserId);
    final currentUserPhone = currentUser != null
        ? PhoneUtil.normalize(currentUser.phoneNumber)
        : '';

    final allDeviceContacts = await _deviceContactsService.getAllContacts();
    if (allDeviceContacts.isEmpty) return [];

    final registeredByPhone = await _userRepository.getRegisteredUsersByPhone();

    final results = allDeviceContacts
        .where((entry) => entry.normalizedPhone != currentUserPhone)
        .map((entry) {
          final registered = registeredByPhone[entry.normalizedPhone];

          if (registered?.uid == currentUserId) {
            return null;
          }

          return AllContactResult(
            displayName: entry.name,
            phoneNumber: entry.phone,
            normalizedPhone: entry.normalizedPhone,
            registeredUser: registered,
          );
        })
        .whereType<AllContactResult>()
        .toList();

    // Sort
    results.sort((a, b) {
      if (a.isRegistered && !b.isRegistered) {
        return -1;
      } //"Place a before b."

      if (!a.isRegistered && b.isRegistered) {
        return 1; //"Place a after b."
      }
      //If both are registered or not registered Then compare names
      final aName = (a.registeredUser?.name ?? a.displayName).toLowerCase();

      final bName = (b.registeredUser?.name ?? b.displayName).toLowerCase();

      return aName.compareTo(bName);
    });

    return results;
  }

  Future<List<AllContactResult>> search({
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

    final results = deviceMatches
        .where((entry) => entry.normalizedPhone != currentUserPhone)
        .map((entry) {
          final registered = registeredByPhone[entry.normalizedPhone];

          if (registered?.uid == currentUserId) {
            return null;
          }

          return AllContactResult(
            displayName: entry.name,
            phoneNumber: entry.phone,
            normalizedPhone: entry.normalizedPhone,
            registeredUser: registered,
          );
        })
        .whereType<AllContactResult>()
        .toList();

    // Keep registered users at the top of search results too
    results.sort((a, b) {
      if (a.isRegistered && !b.isRegistered) {
        return -1;
      }

      if (!a.isRegistered && b.isRegistered) {
        return 1;
      }

      final aName = (a.registeredUser?.name ?? a.displayName).toLowerCase();

      final bName = (b.registeredUser?.name ?? b.displayName).toLowerCase();

      return aName.compareTo(bName);
    });

    return results;
  }
}
