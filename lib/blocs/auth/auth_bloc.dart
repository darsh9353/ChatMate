import 'package:chatmate/repositories/auth_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc(this.authRepository) : super(AuthInitial()) {
    // Send OTP
    on<SendOtpEvent>((event, emit) async {
      emit(AuthLoading());

      try {
        await authRepository.sendOtp(
          phoneNumber: event.phoneNumber,

          onCodeSent: () {
            add(OtpSentInternalEvent()); // trigger new event
          },

          onError: (error) {
            add(AuthErrorEvent(error));
          },
        );
      } catch (e) {
        emit(AuthErrorState(e.toString()));
      }
    });

    on<VerifyOtpEvent>((event, emit) async {
      emit(AuthLoading());

      try {
        final user = await authRepository.verifyOtp(event.otp);

        if (user == null) {
          emit(AuthErrorState("Invalid OTP"));
          return;
        }

        //  Firestore check here (NOT UI)
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          emit(ExistingUserState(user.uid)); //existing user
        } else {
          emit(NewUserState(user.uid)); //new user
        }
      } catch (e) {
        emit(AuthErrorState("Verification failed"));
      }
    });

    // Logout
    on<LogoutEvent>((event, emit) async {
      emit(AuthLoading());

      try {
        await authRepository.logout();
        emit(UnauthenticatedState());
      } catch (e) {
        emit(AuthErrorState(e.toString()));
      }
    });

    on<OtpSentInternalEvent>((event, emit) {
      emit(OtpSentState());
    });

    on<AuthErrorEvent>((event, emit) {
      emit(AuthErrorState(event.message));
    });

    on<CheckAuthStatusEvent>((event, emit) {
      final user = authRepository.getCurrentUser();

      if (user != null) {
        emit(AuthenticatedState());
      } else {
        emit(UnauthenticatedState());
      }
    });
  }
}
