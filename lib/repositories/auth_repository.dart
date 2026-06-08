import 'package:chatmate/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final AuthService _authService = AuthService();

  //  Send OTP
  Future<void> sendOtp({
    required String phoneNumber,
    required Function() onCodeSent,
    required Function(String) onError,
  }) async {
    await _authService.sendOtp(
      phoneNumber: phoneNumber,
      onCodeSent: onCodeSent,
      onError: onError,
    );
  }

  //  Verify OTP
  Future<User?> verifyOtp(String otp) async {
    return await _authService.verifyOtp(otp);
  }

  //  Get current user
  User? getCurrentUser() {
    return _authService.getCurrentUser();
  }

  // Logout
  Future<void> logout() async {
    await _authService.logout();
  }
}
