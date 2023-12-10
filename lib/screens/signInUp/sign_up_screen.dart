import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:w_app/bloc/auth_bloc/auth_bloc.dart';
import 'package:w_app/bloc/auth_bloc/auth_bloc_event.dart';
import 'package:w_app/bloc/auth_bloc/auth_bloc_state.dart';
import 'package:w_app/screens/add/add_review.dart';
import 'package:w_app/screens/signInUp/widgets/custom_textfield_widget.dart';
import 'package:w_app/screens/signInUp/widgets/password_input_widget.dart';
import 'package:w_app/screens/signInUp/sign_in_screen.dart';
import 'package:w_app/styles/color_style.dart';
import 'package:w_app/styles/gradient_style.dart';
import 'package:w_app/widgets/custom_dropdown_menu.dart';
import 'package:w_app/widgets/press_transform_widget.dart';
import 'package:w_app/widgets/snackbar.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final controllerEmail = TextEditingController();
  final controllerPassword = TextEditingController();
  final controllerConfirmPassword = TextEditingController();
  final controllerName = TextEditingController();
  final controllerLastName = TextEditingController();
  final controllerCodePhone = TextEditingController();
  final controllerPhone = TextEditingController();

  final _focusNodeName = FocusNode();
  final _focusNodeLastName = FocusNode();
  final _focusNodeEmail = FocusNode();
  final _focusNodeCodePhone = FocusNode();
  final _focusNodePhone = FocusNode();
  final _focusNodePassword = FocusNode();
  final _focusNodeConfirmPassword = FocusNode();

  String? gender;
  DateTime? birthdate;

  final _formKey = GlobalKey<FormState>();

  late AuthBloc _authBloc;

  bool obscurePassword = true;
  @override
  void initState() {
    super.initState();
    _authBloc = BlocProvider.of<AuthBloc>(context);
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
        body: Form(
          key: _formKey,
          child: Container(
            width: sizeW * 100,
            height: sizeH * 100,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: 104),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 88, bottom: 0),
                      child: Row(
                        children: [],
                      ),
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
                            margin: const EdgeInsets.only(right: 8),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: ColorStyle.darkPurple, width: 1.5)),
                            child: Icon(
                              Icons.arrow_back,
                              size: 14,
                              color: ColorStyle.darkPurple,
                            ),
                          ),
                          Text("Regresar",
                              style: TextStyle(
                                  fontSize: 14,
                                  color: ColorStyle.darkPurple,
                                  fontFamily: "Montserrat")),
                        ],
                      ),
                    ),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: CustomTextFormField(
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
                                return 'Please enter your last name';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Expanded(
                          child: CustomTextFormField(
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
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 4,
                          child: CustomTextFormField(
                            labelText: 'Teléfono',
                            controller: controllerPhone,
                            focusNode: _focusNodePhone,
                            onFieldSubmitted: (_) {
                              FocusScope.of(context).requestFocus(
                                  _focusNodeEmail); // esto mueve el foco al siguiente campo de texto cuando se presiona Enter.
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your last name';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: CustomDropdown(
                            title: 'Género',
                            style: const TextStyle(
                                color: ColorStyle.textGrey,
                                fontFamily: 'Montserrat',
                                fontSize: 14,
                                fontWeight: FontWeight.w600),
                            hintText: 'Selecciona un género',
                            list: const ['Masculino', 'Femenino'],
                            padding: EdgeInsets.only(bottom: 0, top: 0),
                            onSelected: (selected) {
                              setState(() {
                                gender = selected;
                              });
                            },
                          ),
                        ),
                        Expanded(
                            child: CustomDatePicker(
                          title: 'Fecha de nacimiento',
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
                        ))
                      ],
                    ),
                    SizedBox(
                      height: 8,
                    ),
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
                    SizedBox(
                      height: 32,
                    ),
                    PressTransform(
                      onPressed: () async {
                        if (_formKey.currentState!.validate() &&
                            gender != null &&
                            birthdate != null) {
                          _formKey.currentState!.save();
                          if (controllerPassword.text ==
                              controllerConfirmPassword.text) {
                            BlocProvider.of<AuthBloc>(context).add(CreateUser(
                              name: controllerName.text,
                              lastName: controllerLastName.text,
                              phone: controllerPhone.text,
                              email: controllerEmail.text,
                              birthdate: birthdate!,
                              password: controllerConfirmPassword.text,
                              role: "admin",
                              gender: gender == 'Masculino' ? 'M' : 'F',
                            ));
                          } else {
                            showErrorSnackBar(
                                context, "Las contraseñas no son iguales");
                          }
                        }
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 16),
                        width: double.maxFinite,
                        height: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: ColorStyle.darkPurple),
                        child: Text(
                          "Ingresar",
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
                        margin: EdgeInsets.only(bottom: 16),
                        width: double.maxFinite,
                        height: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: ColorStyle.sectionBase),
                        child: Text(
                          "Cancelar",
                          style: TextStyle(
                              color: ColorStyle.textGrey,
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

  CustomDatePicker(
      {this.onDateSelected,
      this.withIcon,
      this.margin,
      required this.title,
      this.style});

  @override
  _CustomDatePickerState createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<CustomDatePicker> {
  DateTime _selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
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
      children: [
        Text(
          widget.title,
          textAlign: TextAlign.center,
          style: widget.style ??
              TextStyle(
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
                    ? Icon(
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
