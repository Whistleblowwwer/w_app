import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:w_app/bloc/auth_bloc/auth_bloc.dart';
import 'package:w_app/bloc/auth_bloc/auth_bloc_event.dart';
import 'package:w_app/screens/signInUp/reset_password_screen.dart';
import 'package:w_app/screens/signInUp/sign_up_screen.dart';
import 'package:w_app/screens/signInUp/widgets/custom_textfield_widget.dart';
import 'package:w_app/widgets/press_transform_widget.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  bool isValidEmail(String input) {
    final RegExp regex = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9._%+-]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    );
    return regex.hasMatch(input);
  }

  void _onSignInButtonPressed() {
    if (_formKey.currentState!.validate()) {
      BlocProvider.of<AuthBloc>(context).add(
        SignInButtonPressed(
          username: _usernameController.text,
          password: _passwordController.text,
        ),
      );
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Inicia sesión',
          style: TextStyle(
            fontFamily: 'Montserrat',
          ),
        ),
        backgroundColor: const Color.fromRGBO(16, 28, 43, 1),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(
                  height: 48,
                ),
                Image.asset(
                  'assets/images/logos/imagew.png',
                  width: 102,
                ),
                const SizedBox(
                  height: 48,
                ),
                CustomTextFormField(
                  controller: _usernameController,
                  focusNode: _usernameFocus,
                  nextFocusNode: _passwordFocus,
                  labelText: 'Email',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    } else if (!EmailValidator.validate(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 0,
                ),
                CustomTextFormField(
                  controller: _passwordController,
                  focusNode: _passwordFocus,
                  labelText: 'Contraseña',
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) {
                    // _onSignInButtonPressed();
                  },
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.only(top: 8, bottom: 16),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const ResetPasswordScreen()));
                      },
                      child: const Text(
                        "¿Olvidaste tu contraseña?",
                        style: TextStyle(
                            color: Color.fromRGBO(100, 31, 137, 1),
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
                PressTransform(
                  onPressed: _onSignInButtonPressed,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 32),
                    width: double.maxFinite,
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: const Color.fromRGBO(100, 31, 137, 1)),
                    child: const Text(
                      "Ingresar",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Montserrat',
                          fontSize: 18),
                    ),
                  ),
                ),
                // InterceptionTextWidget(
                //   text: "Ingresa también con",
                // ),
                // GestureDetector(
                //   onTap: () {},
                //   child: SignInWithButton(
                //     text: "Ingresa con Google",
                //   ),
                // ),

                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SignUpPage()));
                  },
                  child: const Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '¿No tienes cuenta? ',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        TextSpan(
                            text: 'Regístrate',
                            style: TextStyle(
                                letterSpacing: 0.02 * 1,
                                fontWeight: FontWeight.w600,
                                color: Color.fromRGBO(100, 31, 137, 1))),
                      ],
                    ),
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SignInWithButton extends StatelessWidget {
  final String text;
  const SignInWithButton({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      height: 56,
      margin: const EdgeInsets.only(top: 32, bottom: 48),
      alignment: Alignment.center,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            width: 1,
            color: const Color.fromRGBO(217, 217, 217, 1),
          )),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w400,
          fontFamily: 'Montserrat',
        ),
      ),
    );
  }
}

class InterceptionTextWidget extends StatelessWidget {
  final String text;
  const InterceptionTextWidget({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Container(
            height: 1,
            margin: const EdgeInsets.only(right: 8),
            color: const Color.fromRGBO(217, 217, 217, 1),
          ),
        ),
        Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            fontFamily: 'Montserrat',
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            margin: const EdgeInsets.only(left: 8),
            color: const Color.fromRGBO(217, 217, 217, 1),
          ),
        )
      ],
    );
  }
}
