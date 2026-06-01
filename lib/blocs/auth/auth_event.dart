abstract class AuthEvent {}

// Trigger when user enters phone number
class SendOtpEvent extends AuthEvent {
  final String phoneNumber;

  SendOtpEvent(this.phoneNumber);
}

// Trigger when user enters OTP
class VerifyOtpEvent extends AuthEvent {
  final String otp;

  VerifyOtpEvent(this.otp);
}

// Trigger logout
class LogoutEvent extends AuthEvent {}
