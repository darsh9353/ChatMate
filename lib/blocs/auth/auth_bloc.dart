import 'package:chatmate/repositories/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthRepository read) : super(AuthInitial()) {
    // Send OTP
    on<SendOtpEvent>((event, emit) async {
      emit(AuthLoading());

      // TODO: Add OTP sending logic

      emit(OtpSentState());
    });

    // Verify OTP
    on<VerifyOtpEvent>((event, emit) async {
      emit(AuthLoading());

      // TODO: Add OTP verification logic

      emit(AuthenticatedState());
    });

    // Logout
    on<LogoutEvent>((event, emit) async {
      emit(AuthLoading());

      // TODO: Add logout logic

      emit(UnauthenticatedState());
    });
  }
}
