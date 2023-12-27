import 'dart:io';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:w_app/bloc/auth_bloc/auth_bloc.dart';
import 'package:w_app/bloc/auth_bloc/auth_bloc_event.dart';
import 'package:w_app/bloc/auth_bloc/auth_bloc_state.dart';
import 'package:w_app/data/countries_data.dart';
import 'package:w_app/screens/signInUp/verificationSMS_screen.dart';
import 'package:w_app/screens/signInUp/widgets/custom_textfield_widget.dart';
import 'package:w_app/screens/signInUp/widgets/roundedBottomSheet.dart';
import 'package:w_app/services/api/api_service.dart';
import 'package:w_app/styles/color_style.dart';
import 'package:w_app/widgets/custom_dropdown_menu.dart';
import 'package:w_app/widgets/pdf_screen.dart';
import 'package:w_app/widgets/press_transform_widget.dart';
import 'package:w_app/widgets/snackbar.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final controllerPage = PageController(initialPage: 0);

  final controllerUserName = TextEditingController();
  final controllerEmail = TextEditingController();
  final controllerPassword = TextEditingController();
  final controllerConfirmPassword = TextEditingController();
  final controllerName = TextEditingController();
  final controllerLastName = TextEditingController();
  final controllerCodePhone = TextEditingController();
  final controllerPhone = TextEditingController();

  final _focusNodeUserName = FocusNode();
  final _focusNodeName = FocusNode();
  final _focusNodeLastName = FocusNode();
  final _focusNodeEmail = FocusNode();
  final _focusNodePhone = FocusNode();
  final _focusNodePassword = FocusNode();
  final _focusNodeConfirmPassword = FocusNode();

  String? gender;
  DateTime? birthdate;
  String preffix = '52';
  bool loadingOTP = false;

  final GlobalKey<FormState> _formKey1 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKey2 = GlobalKey<FormState>();

  bool obscurePassword = true;
  @override
  void initState() {
    super.initState();
  }

  bool isEighteenYearsOrOlder(DateTime birthdate) {
    DateTime currentDate = DateTime.now();
    DateTime eighteenYearsAgo =
        DateTime(currentDate.year - 18, currentDate.month, currentDate.day);

    return birthdate.isBefore(eighteenYearsAgo) ||
        birthdate.isAtSameMomentAs(eighteenYearsAgo);
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
        key: _scaffoldKey,
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
                                child: Center(
                                  child: Text("Crear cuenta",
                                      style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: "Montserrat")),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(top: 0, bottom: 36),
                                child: Center(
                                  child: Text(
                                      "Completa los datos y únete a la comunidad de Whistleblowwer",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: ColorStyle.textGrey,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: "Montserrat")),
                                ),
                              ),

                              CustomTextFormField(
                                labelText: 'Username',
                                controller: controllerUserName,
                                // inputType: TextInputType.name,
                                // hintText: '',
                                focusNode: _focusNodeUserName,
                                onFieldSubmitted: (_) {
                                  FocusScope.of(context).requestFocus(
                                      _focusNodeName); // esto mueve el foco al siguiente campo de texto cuando se presiona Enter.
                                },
                              ),

                              CustomTextFormField(
                                labelText: 'Nombre',
                                controller: controllerName,
                                // inputType: TextInputType.name,
                                // hintText: '',
                                focusNode: _focusNodeName,
                                onFieldSubmitted: (_) {
                                  FocusScope.of(context).requestFocus(
                                      _focusNodeLastName); // esto mueve el foco al siguiente campo de texto cuando se presiona Enter.
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your name';
                                  }
                                  return null;
                                },
                              ),

                              CustomTextFormField(
                                labelText: 'Apellidos',
                                controller: controllerLastName,
                                focusNode: _focusNodeLastName,
                                onFieldSubmitted: (_) {
                                  FocusScope.of(context).requestFocus(
                                      _focusNodePhone); // esto mueve el foco al siguiente campo de texto cuando se presiona Enter.
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your last name';
                                  }
                                  return null;
                                },
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

                              // CustomDatePicker(
                              //   title: 'Fecha de nacimiento',
                              //   margin: EdgeInsets.only(top: 4),
                              //   style: const TextStyle(
                              //       color: ColorStyle.textGrey,
                              //       fontFamily: 'Montserrat',
                              //       fontSize: 14,
                              //       fontWeight: FontWeight.w600),
                              //   onDateSelected: (onDateSelected) {
                              //     setState(() {
                              //       birthdate = onDateSelected;
                              //     });
                              //   },
                              // ),

                              const SizedBox(
                                height: 32,
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
                                        .requestOTP(controllerEmail.text);

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
                                  margin: const EdgeInsets.only(bottom: 16),
                                  width: double.maxFinite,
                                  height: 48,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: ColorStyle.darkPurple),
                                  child: const Text(
                                    "Siguiente",
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
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: SingleChildScrollView(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                    padding:
                                        EdgeInsets.only(top: 24, bottom: 32),
                                    child: Center(
                                        child: Text("Completa los datos",
                                            style: TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.w600,
                                                fontFamily: "Montserrat")))),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: CustomDropdown(
                                        title: '',
                                        hintText: '52',
                                        initialValue: preffix,
                                        type: "phone_code",
                                        // showIcon: true,
                                        list: countries
                                            .map((country) =>
                                                country["phone_code"]
                                                    .toString())
                                            .toList()
                                          ..sort((a, b) => a.compareTo(b)),
                                        padding: const EdgeInsets.only(
                                            bottom: 16, right: 8),
                                        onSelected: (selected) {
                                          setState(() {
                                            preffix = selected;
                                          });
                                        },
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: CustomTextFormField(
                                        labelText: 'Teléfono',
                                        controller: controllerPhone,
                                        onFieldSubmitted: (_) {},
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter your phone number';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                CustomDropdown(
                                  title: 'Género',
                                  style: const TextStyle(
                                      color: ColorStyle.textGrey,
                                      fontFamily: 'Montserrat',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600),
                                  hintText: 'Selecciona un género',
                                  list: const ['Masculino', 'Femenino'],
                                  padding:
                                      const EdgeInsets.only(bottom: 16, top: 0),
                                  onSelected: (selected) {
                                    setState(() {
                                      gender = selected;
                                    });
                                  },
                                ),
                                CustomDatePicker(
                                  title: 'Fecha de nacimiento',
                                  margin:
                                      const EdgeInsets.only(top: 2, bottom: 16),
                                  style: const TextStyle(
                                      color: ColorStyle.textGrey,
                                      fontFamily: 'Montserrat',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600),
                                  onDateSelected: (onDateSelected) {
                                    setState(() {
                                      birthdate = onDateSelected;
                                    });
                                  },
                                ),

                                Form(
                                  key: _formKey2,
                                  child: Column(
                                    children: [
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
                                          FocusScope.of(context).requestFocus(
                                              _focusNodeConfirmPassword);
                                        },
                                      ),
                                      CustomTextFormField(
                                        controller: controllerConfirmPassword,
                                        focusNode: _focusNodeConfirmPassword,
                                        labelText: 'Contraseña',
                                        obscureText: true,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter a confirm password';
                                          }
                                          return null;
                                        },
                                        onFieldSubmitted: (_) {
                                          // FocusScope.of(context).requestFocus(
                                          //     _focusNodeConfirmPassword);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 32,
                                ),
                                // Row(
                                //   crossAxisAlignment: CrossAxisAlignment.start,
                                //   children: [
                                //     SizedBox(
                                //       width: 8,
                                //     ),
                                //   ],
                                // ),

                                Text.rich(TextSpan(
                                    children: [
                                      const TextSpan(
                                          text: "Al registrarte, aceptas los"),
                                      TextSpan(
                                          text: "Términos de servicio",
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () async {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        PDFScreen()),
                                              );

                                              // final Uri url = Uri.parse(
                                              //     'https://www.whistleblowwer.com/admin');
                                              // if (!await launchUrl(url)) {
                                              //   print('Could not launch $url');
                                              // }
                                            },
                                          style: const TextStyle(
                                              decoration:
                                                  TextDecoration.underline)),
                                      const TextSpan(text: " y la "),
                                      TextSpan(
                                          text: "Política de privacidad",
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () async {
                                              showModalBottomSheet(
                                                context: context,
                                                builder: (BuildContext
                                                        context) =>
                                                    const RoundedBottomSheet(),
                                                backgroundColor:
                                                    Colors.transparent,
                                                isScrollControlled: true,
                                              );
                                              // final Uri url = Uri.parse(
                                              //     'https://www.whistleblowwer.com/admin');
                                              // if (!await launchUrl(url)) {
                                              //   print('Could not launch $url');
                                              // }
                                            },
                                          style: const TextStyle(
                                              decoration:
                                                  TextDecoration.underline)),
                                      const TextSpan(
                                          text: ", incluida la política de "),
                                      TextSpan(
                                          text: "Uso de Cookies.",
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () async {
                                              showModalBottomSheet(
                                                context: context,
                                                builder: (BuildContext
                                                        context) =>
                                                    const RoundedBottomSheet(),
                                                backgroundColor:
                                                    Colors.transparent,
                                                isScrollControlled: true,
                                              );
                                              // final Uri url = Uri.parse(
                                              //     'https://www.whistleblowwer.com');
                                              // if (!await launchUrl(url)) {
                                              //   print('Could not launch $url');
                                              // }
                                            },
                                          style: const TextStyle(
                                              decoration:
                                                  TextDecoration.underline)),
                                    ],
                                    style: const TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 13))),
                                const SizedBox(
                                  height: 24,
                                ),

                                PressTransform(
                                  onPressed: () async {
                                    if (_formKey2.currentState!.validate() &&
                                        birthdate != null) {
                                      _formKey2.currentState!.save();

                                      if (!isEighteenYearsOrOlder(birthdate!)) {
                                        showErrorSnackBar(
                                            context, "Es menor de 18 años");
                                        return;
                                      }

                                      if (controllerPassword.text !=
                                          controllerConfirmPassword.text) {
                                        showErrorSnackBar(context,
                                            "Las contraseñas no son iguales");
                                        return;
                                      }

                                      String phoneNumber = '';

                                      if (controllerPhone.text.isNotEmpty) {
                                        phoneNumber = preffix.startsWith('+')
                                            ? preffix + controllerPhone.text
                                            : '+$preffix${controllerPhone.text}';
                                      }

                                      print(phoneNumber);

                                      BlocProvider.of<AuthBloc>(context)
                                          .add(CreateUser(
                                        userName: controllerUserName.text,
                                        name: controllerName.text,
                                        lastName: controllerLastName.text,
                                        phone: phoneNumber,
                                        email: controllerEmail.text,
                                        birthdate: birthdate!,
                                        password:
                                            controllerConfirmPassword.text,
                                        role: "admin",
                                        gender:
                                            gender == 'Masculino' ? 'M' : 'F',
                                      ));
                                    } else {
                                      showErrorSnackBar(
                                          context, "Ingresa una fecha");
                                    }
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    width: double.maxFinite,
                                    height: 48,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: ColorStyle.darkPurple),
                                    child: const Text(
                                      "Crear cuenta",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Montserrat',
                                          fontSize: 16),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    width: double.maxFinite,
                                    height: 48,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: ColorStyle.sectionBase),
                                    child: const Text(
                                      "Cancelar",
                                      style: TextStyle(
                                          color: ColorStyle.textGrey,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Montserrat',
                                          fontSize: 16),
                                    ),
                                  ),
                                ),
                              ]),
                        )),
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

class CustomDatePicker extends StatefulWidget {
  final Function(DateTime)? onDateSelected;
  final bool? withIcon;
  final EdgeInsets? margin;
  final String title;
  final TextStyle? style;

  const CustomDatePicker(
      {super.key,
      this.onDateSelected,
      this.withIcon,
      this.margin,
      required this.title,
      this.style});

  @override
  CustomDatePickerState createState() => CustomDatePickerState();
}

class CustomDatePickerState extends State<CustomDatePicker> {
  DateTime _selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1932),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: ColorStyle.darkPurple,
            hintColor: ColorStyle.darkPurple,
            colorScheme:
                const ColorScheme.light(primary: ColorStyle.darkPurple),
            buttonTheme:
                const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        if (widget.onDateSelected != null) {
          widget.onDateSelected!(picked);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          textAlign: TextAlign.center,
          style: widget.style ??
              const TextStyle(
                  fontFamily: "Montserrat",
                  color: Colors
                      .grey, // Suponiendo que no tienes la clase ColorStyle
                  fontSize: 14,
                  fontWeight: FontWeight.w400),
        ),
        GestureDetector(
          onTap: () {
            _selectDate(context);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            margin: widget.margin ??
                const EdgeInsets.only(bottom: 10, left: 16, right: 8, top: 2),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: ColorStyle.borderGrey)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${_selectedDate.toLocal()}".split(' ')[0],
                  style: const TextStyle(
                      fontSize: 14,
                      color: ColorStyle.textGrey,
                      fontFamily: 'Anuphan'),
                ),
                widget.withIcon ?? true
                    ? const Icon(
                        Icons.calendar_today,
                        color: ColorStyle.borderGrey,
                        size: 22,
                      )
                    : const SizedBox(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
