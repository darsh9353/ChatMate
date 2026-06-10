import 'package:chatmate/blocs/auth/auth_bloc.dart';
import 'package:chatmate/blocs/auth/auth_event.dart';
import 'package:chatmate/blocs/auth/auth_state.dart';
import 'package:chatmate/screens/otp_screen.dart';
import 'package:chatmate/widgets/app_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final numberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.secondary,
        systemOverlayStyle: theme.brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        elevation: 0,
        title: const Text("ChatMate"),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          // Navigate when OTP sent
          if (state is OtpSentState) {
            final phone = "+91${numberController.text.trim()}";

            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => OtpScreen(phoneNumber: phone)),
            );
          }

          //  Error handling
          if (state is AuthErrorState) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: AppBackground(
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: screenHeight * 0.18,
                        width: screenWidth * 0.4,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          image: const DecorationImage(
                            image: AssetImage('assets/images/message.png'),
                            fit: BoxFit.cover, // change to contain if needed
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        'LOGIN',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 30,
                          ),
                          child: Column(
                            children: [
                              const SizedBox(height: 10),

                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.secondary,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Row(
                                  children: [
                                    const Text(
                                      '+91',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),

                                    const SizedBox(width: 2),

                                    Expanded(
                                      child: TextFormField(
                                        controller: numberController,
                                        keyboardType: TextInputType.phone,
                                        maxLength: 10,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                          color: theme.colorScheme.onSecondary,
                                        ),
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          fillColor:
                                              theme.colorScheme.secondary,
                                          counterText: "",
                                          hintText: "Enter number",
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return "Enter mobile number";
                                          }
                                          if (value.length != 10) {
                                            return "Enter valid 10-digit number";
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 25),

                              ///  BUTTON WITH BLOC
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: BlocBuilder<AuthBloc, AuthState>(
                                  builder: (context, state) {
                                    return ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            theme.colorScheme.primary,
                                        foregroundColor:
                                            theme.colorScheme.onPrimary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      onPressed: state is AuthLoading
                                          ? null
                                          : () {
                                              if (_formKey.currentState!
                                                  .validate()) {
                                                final phone =
                                                    "+91${numberController.text.trim()}";

                                                // CALL BLOC
                                                context.read<AuthBloc>().add(
                                                  SendOtpEvent(phone),
                                                );
                                              }
                                            },
                                      child: state is AuthLoading
                                          ? CircularProgressIndicator(
                                              color:
                                                  theme.colorScheme.onSecondary,
                                            )
                                          : const Text(
                                              'Send OTP',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
