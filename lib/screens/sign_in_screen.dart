import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:w_app/bloc/auth_bloc/auth_bloc.dart';
import 'package:w_app/bloc/auth_bloc/auth_bloc_event.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Inicia sesión',
          style: TextStyle(
            fontFamily: 'Montserrat',
          ),
        ),
        backgroundColor: Color.fromRGBO(16, 28, 43, 1),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              children: [
                SizedBox(
                  height: 48,
                ),
                Image.asset(
                  'assets/images/logos/imagew.png',
                  width: 102,
                ),
                SizedBox(
                  height: 48,
                ),
                CustomTextFormField(
                  controller: _usernameController,
                  focusNode: _usernameFocus,
                  nextFocusNode: _passwordFocus,
                  labelText: 'Email',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),
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
                    _onSignInButtonPressed();
                  },
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      "¿Olvidaste tu contraseña?",
                      style: TextStyle(
                          color: Color.fromRGBO(100, 31, 137, 1),
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _onSignInButtonPressed,
                  child: Container(
                    margin: EdgeInsets.only(bottom: 32),
                    width: double.maxFinite,
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Color.fromRGBO(100, 31, 137, 1)),
                    child: Text(
                      "Ingresar",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Montserrat',
                          fontSize: 18),
                    ),
                  ),
                ),
                InterceptionTextWidget(
                  text: "Ingresa tambien con",
                ),
                GestureDetector(
                  onTap: () {},
                  child: SignInWithButton(
                    text: "Ingresa con Google",
                  ),
                ),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '¿No tienes cuenta? ',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      TextSpan(
                          text: 'Registrate',
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
      margin: EdgeInsets.only(top: 32, bottom: 48),
      alignment: Alignment.center,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            width: 1,
            color: Color.fromRGBO(217, 217, 217, 1),
          )),
      child: Text(
        text,
        style: TextStyle(
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
            margin: EdgeInsets.only(right: 8),
            color: Color.fromRGBO(217, 217, 217, 1),
          ),
        ),
        Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            fontFamily: 'Montserrat',
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            margin: EdgeInsets.only(left: 8),
            color: Color.fromRGBO(217, 217, 217, 1),
          ),
        )
      ],
    );
  }
}

class CustomTextFormField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final FocusNode? nextFocusNode;
  final String labelText;
  final bool obscureText;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onFieldSubmitted;

  CustomTextFormField({
    required this.controller,
    this.focusNode,
    this.nextFocusNode,
    required this.labelText,
    this.obscureText = false,
    this.validator,
    this.onFieldSubmitted,
  });

  @override
  _CustomTextFormFieldState createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      style: TextStyle(
        fontFamily: 'Montserrat',
      ),
      decoration: InputDecoration(
        labelText: widget.labelText,
        floatingLabelStyle: TextStyle(
            color: Color.fromRGBO(163, 173, 179, 1),
            fontSize: 16,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600),
        labelStyle: TextStyle(
            color: Color.fromRGBO(163, 173, 179, 1),
            fontFamily: 'Montserrat',
            fontSize: 16,
            fontWeight: FontWeight.w600),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(
              color: const Color.fromRGBO(217, 217, 217, 1), width: 1.0),
        ),
        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Color.fromRGBO(163, 173, 179, 1),
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : null,
      ),
      focusNode: widget.focusNode,
      validator: widget.validator,
      obscureText: widget.obscureText ? _obscureText : false,
      onFieldSubmitted: (value) {
        if (widget.nextFocusNode != null) {
          FocusScope.of(context).requestFocus(widget.nextFocusNode);
        }
        if (widget.onFieldSubmitted != null) {
          widget.onFieldSubmitted!(value);
        }
      },
    );
  }
}
