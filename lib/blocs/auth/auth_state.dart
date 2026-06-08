abstract class AuthState {}

// Initial state
class AuthInitial extends AuthState {}

// Loading state
class AuthLoading extends AuthState {}

// OTP sent successfully
class OtpSentState extends AuthState {}

// OTP verified / user logged in
class AuthenticatedState extends AuthState {}

// Logged out
class UnauthenticatedState extends AuthState {}

// Error state
class AuthErrorState extends AuthState {
  final String message;

  AuthErrorState(this.message);
}

class NewUserState extends AuthState {
  final String userId;
  NewUserState(this.userId);
}

class ExistingUserState extends AuthState {
  final String userId;
  ExistingUserState(this.userId);
}
