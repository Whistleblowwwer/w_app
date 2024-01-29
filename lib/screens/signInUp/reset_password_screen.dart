import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:w_app/bloc/auth_bloc/auth_bloc.dart';
import 'package:w_app/bloc/auth_bloc/auth_bloc_state.dart';
import 'package:w_app/screens/signInUp/verificationSMS_screen.dart';
import 'package:w_app/screens/signInUp/widgets/custom_textfield_widget.dart';
import 'package:w_app/services/api/api_service.dart';
import 'package:w_app/styles/color_style.dart';
import 'package:w_app/widgets/press_transform_widget.dart';
import 'package:w_app/widgets/snackbar.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final controllerPage = PageController(initialPage: 0);

  final controllerEmail = TextEditingController();
  final _focusNodeEmail = FocusNode();

  final controllerPassword = TextEditingController();
  final controllerConfirmPassword = TextEditingController();

  final _focusNodePassword = FocusNode();
  final _focusNodeConfirmPassword = FocusNode();

  bool loadingOTP = false;

  final GlobalKey<FormState> _formKey1 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKey2 = GlobalKey<FormState>();

  bool obscurePassword = true;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final sizeW = MediaQuery.of(context).size.width / 100;
    final sizeH = MediaQuery.of(context).size.height / 100;
    return BlocListener<AuthBloc, AuthState>(
      listener: (BuildContext context, state) {
        if (state is AuthAuthenticated) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        body: Container(
          width: sizeW * 100,
          height: sizeH * 100,
          color: Colors.white,
          child: Column(
            children: [
              const Padding(
                padding:
                    EdgeInsets.only(top: 88, right: 24, left: 24, bottom: 0),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      margin: const EdgeInsets.only(right: 8, left: 24),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: ColorStyle.darkPurple, width: 1.5)),
                      child: const Icon(
                        Icons.arrow_back,
                        size: 14,
                        color: ColorStyle.darkPurple,
                      ),
                    ),
                    const Text("Regresar",
                        style: TextStyle(
                            fontSize: 14,
                            color: ColorStyle.darkPurple,
                            fontFamily: "Montserrat")),
                  ],
                ),
              ),
              Expanded(
                child: PageView(
                  controller: controllerPage,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    Form(
                      key: _formKey1,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 24, bottom: 8),
                                child: Text("Ingresa tu correo",
                                    style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: "Montserrat")),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(top: 0, bottom: 32),
                                child: Text(
                                    "Se enviará un código a su correo electrónico para confirmar su identidad.",
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: ColorStyle.textGrey,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: "Montserrat")),
                              ),
                              CustomTextFormField(
                                labelText: 'Email',
                                controller: controllerEmail,
                                type: TextInputType.emailAddress,
                                focusNode: _focusNodeEmail,
                                onFieldSubmitted: (_) {
                                  FocusScope.of(context).requestFocus(
                                      _focusNodePassword); // esto mueve el foco al siguiente campo de texto cuando se presiona Enter.
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  } else if (!EmailValidator.validate(value)) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                              PressTransform(
                                onPressed: () async {
                                  if (loadingOTP) return;
                                  if (_formKey1.currentState!.validate()) {
                                    _formKey1.currentState!.save();
                                    setState(() {
                                      loadingOTP = true;
                                    });
                                    final bool requestOTP = await ApiService()
                                        .requestOTPPassword(
                                            controllerEmail.text);

                                    if (requestOTP) {
                                      if (mounted) {
                                        final bool? responseSMS =
                                            await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        SMSVerificationPage(
                                                          email: controllerEmail
                                                              .text,
                                                        )));

                                        if (responseSMS != null &&
                                            responseSMS == true) {
                                          controllerPage.jumpToPage(
                                            1,
                                          );
                                        }
                                      }
                                    } else {
                                      if (mounted) {
                                        showErrorSnackBar(context,
                                            "Al enviar código al correo ${controllerEmail.text}");
                                      }
                                    }
                                    setState(() {
                                      loadingOTP = false;
                                    });
                                  }
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(top: 16),
                                  width: double.maxFinite,
                                  height: 48,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: ColorStyle.darkPurple),
                                  child: const Text(
                                    "Enviar Código",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Montserrat',
                                        fontSize: 16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Form(
                      key: _formKey2,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 24, bottom: 32),
                                child: Text("Restablece tu constraseña",
                                    style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: "Montserrat")),
                              ),
                              // const Padding(
                              //   padding: EdgeInsets.only(top: 0, bottom: 36),
                              //   child: Text(
                              //       "Completa los datos y únete a la comunidad de Whistleblowwer",
                              //       style: TextStyle(
                              //           fontSize: 14,
                              //           color: ColorStyle.textGrey,
                              //           fontWeight: FontWeight.w500,
                              //           fontFamily: "Montserrat")),
                              // ),

                              CustomTextFormField(
                                controller: controllerPassword,
                                focusNode: _focusNodePassword,
                                labelText: 'Contraseña',
                                obscureText: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a password';
                                  }
                                  return null;
                                },
                                onFieldSubmitted: (_) {
                                  FocusScope.of(context)
                                      .requestFocus(_focusNodeConfirmPassword);
                                },
                              ),
                              CustomTextFormField(
                                controller: controllerConfirmPassword,
                                focusNode: _focusNodeConfirmPassword,
                                labelText: 'Confirmar Contraseña',
                                obscureText: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a confirm password';
                                  }
                                  return null;
                                },
                                onFieldSubmitted: (_) {},
                              ),
                              PressTransform(
                                onPressed: () async {
                                  if (_formKey2.currentState!.validate()) {
                                    _formKey2.currentState!.save();

                                    if (controllerPassword.text !=
                                        controllerConfirmPassword.text) {
                                      showErrorSnackBar(context,
                                          "Las contraseñas no son iguales");
                                      return;
                                    }

                                    final bool response = await ApiService()
                                        .changePassword(
                                            email: controllerEmail.text,
                                            password:
                                                controllerConfirmPassword.text);
                                    if (mounted) {
                                      if (response) {
                                        showSuccessSnackBar(context,
                                            message:
                                                "Se ha cambiado la contraseña");
                                      } else {
                                        showErrorSnackBar(context,
                                            "No se logro cambiar la contraseña");
                                      }
                                      Navigator.of(context).pop();
                                    }
                                  }
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(top: 16),
                                  width: double.maxFinite,
                                  height: 48,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: ColorStyle.darkPurple),
                                  child: const Text(
                                    "Restablecer constraseña",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Montserrat',
                                        fontSize: 16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
