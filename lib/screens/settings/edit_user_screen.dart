import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:w_app/bloc/auth_bloc/auth_bloc.dart';
import 'package:w_app/bloc/socket_bloc/socket_bloc.dart';
import 'package:w_app/bloc/user_bloc/user_bloc.dart';
import 'package:w_app/bloc/user_bloc/user_bloc_event.dart';
import 'package:w_app/data/countries_data.dart';
import 'package:w_app/models/user.dart';
import 'package:w_app/screens/signInUp/widgets/custom_textfield_widget.dart';
import 'package:w_app/styles/color_style.dart';
import 'package:w_app/styles/gradient_style.dart';
import 'package:w_app/widgets/custom_dropdown_menu.dart';
import 'package:w_app/widgets/press_transform_widget.dart';
import 'package:w_app/widgets/showAdaptiveDialog.dart';

class EditUserScreen extends StatefulWidget {
  final User user;
  const EditUserScreen({super.key, required this.user});

  @override
  State<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late UserBloc userBloc;
  late AuthBloc authBloc;
  late SocketBloc socketBloc;
  final controllerUserName = TextEditingController();
  final controllerEmail = TextEditingController();
  final controllerName = TextEditingController();
  final controllerLastName = TextEditingController();
  final controllerCodePhone = TextEditingController();
  final controllerPhone = TextEditingController();

  final _focusNodeUserName = FocusNode();
  final _focusNodeName = FocusNode();
  final _focusNodeLastName = FocusNode();
  final _focusNodeEmail = FocusNode();
  final _focusNodePhone = FocusNode();

  String preffix = '52';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userBloc = BlocProvider.of<UserBloc>(context);
    authBloc = BlocProvider.of<AuthBloc>(context);
    socketBloc = BlocProvider.of<SocketBloc>(context);

    controllerName.text = widget.user.name;
    controllerLastName.text = widget.user.lastName;
    controllerUserName.text = widget.user.userName ?? '';
    controllerPhone.text = widget.user.phoneNumber ?? '';
    controllerEmail.text = widget.user.email ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final sizeW = MediaQuery.of(context).size.width / 100;
    final sizeH = MediaQuery.of(context).size.height / 100;
    // final stateUser = BlocProvider.of<UserBloc>(context).state;

    return Scaffold(
      body: SizedBox(
          width: sizeW * 100,
          height: sizeH * 100,
          child: Stack(
            children: [
              Positioned.fill(
                  top: 96,
                  child: SizedBox(
                    width: double.maxFinite,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(left: 16, right: 16, top: 32),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                              onFieldSubmitted: (_) {},
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                } else if (!EmailValidator.validate(value)) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            CustomTextFormField(
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
                            PressTransform(
                                onPressed: () {
                                  showAdaptiveDialogIos(
                                      context: context,
                                      title: 'Advertencia',
                                      content:
                                          '¿Estás seguro de guardar cambios?',
                                      onTapCancel: () {
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .pop();
                                      },
                                      onTapOk: () async {
                                        if (_formKey.currentState!.validate()) {
                                          _formKey.currentState!.save();
                                          userBloc.add(UpdateUserProfile(
                                              user: widget.user,
                                              email: controllerEmail.text,
                                              userName: controllerUserName.text,
                                              phone: controllerPhone.text,
                                              name: controllerName.text,
                                              lastName:
                                                  controllerLastName.text));
                                          Navigator.of(context,
                                                  rootNavigator: true)
                                              .pop();
                                          // Navigator.of(context);
                                        }
                                      });
                                },
                                child: Container(
                                    margin: EdgeInsets.only(
                                        left: 16,
                                        right: 16,
                                        bottom: 8,
                                        top: 32),
                                    height: 48,
                                    width: double.maxFinite,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        gradient: GradientStyle()
                                            .whistleBlowwerGradient,
                                        borderRadius: BorderRadius.circular(8)),
                                    child: const Text(
                                      "Guardar cambios",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        fontFamily: 'Montserrat',
                                      ),
                                    ))),
                          ],
                        ),
                      ),
                    ),
                  )),
              Container(
                width: double.maxFinite,
                height: 96,
                padding: const EdgeInsets.only(top: 32),
                decoration: const BoxDecoration(color: Colors.white),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      left: 0,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Padding(
                          padding: EdgeInsets.only(left: 16, right: 8),
                          child: Icon(FeatherIcons.arrowLeft),
                        ),
                      ),
                    ),
                    const Text(
                      "Editar usuario",
                      style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 15,
                          fontWeight: FontWeight.w600),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        width: double.maxFinite,
                        height: 0.5,
                        color: ColorStyle.borderGrey,
                      ),
                    ),
                  ],
                ),
              )
            ],
          )),
    );
  }
}
