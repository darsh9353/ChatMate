import 'package:chatmate/models/user_model.dart';

/// One searchable row in Discover People (one phone number per contact).
class AllContactResult {
  final String displayName;
  final String phoneNumber;
  final String normalizedPhone;
  final UserModel? registeredUser;

  const AllContactResult({
    required this.displayName,
    required this.phoneNumber,
    required this.normalizedPhone,
    this.registeredUser,
  });

  bool get isRegistered => registeredUser != null;
}
