import 'package:chatmate/services/auth_service.dart';
/* UI / BLoC
    ↓
AuthRepository
    ↓
AuthService
    ↓
Firebase
*/

class AuthRepository {
  final AuthService _authService = AuthService();

  Future<void> sendOtp(String phoneNumber) async {
    await _authService.sendOtp(phoneNumber);
  }

  Future<void> verifyOtp(String otp) async {
    await _authService.verifyOtp(otp);
  }

  Future<void> logout() async {
    await _authService.logout();
  }
}
