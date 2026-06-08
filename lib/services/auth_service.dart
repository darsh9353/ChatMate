import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _verificationId;

  //  Send OTP
  Future<void> sendOtp({
    required String phoneNumber,
    required Function() onCodeSent,
    required Function(String) onError,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,

      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto login (rare)
        await _auth.signInWithCredential(credential);
      },

      verificationFailed: (FirebaseAuthException e) {
        onError(e.message ?? "Verification failed");
      },

      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        onCodeSent();
      },

      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  //  Verify OTP
  Future<User?> verifyOtp(String otp) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      return userCredential.user;
    } catch (e) {
      print("OTP Error: $e");
      return null;
    }
  }

  //  Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }
}
