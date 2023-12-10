import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:w_app/bloc/user_bloc/user_bloc.dart';
import 'package:w_app/bloc/user_bloc/user_bloc_state.dart';
import 'package:w_app/data/countries_data.dart';
import 'package:w_app/models/company_model.dart';
import 'package:w_app/screens/add/add_review.dart';
import 'package:w_app/services/api/api_service.dart';
import 'package:w_app/styles/color_style.dart';
import 'package:w_app/widgets/custom_dropdown_menu.dart';
import 'package:w_app/widgets/press_transform_widget.dart';
import 'package:w_app/widgets/snackbar.dart';

class AddBusinessScreen extends StatefulWidget {
  const AddBusinessScreen({super.key});

  @override
  State<AddBusinessScreen> createState() => _AddBusinessScreenState();
}

class _AddBusinessScreenState extends State<AddBusinessScreen> {
  String? selectedCountry;
  List<String> states = [];
  String? selectedState;

  List<String> cities = [];
  String? selectedCity;
  String? selecteCategory;
  TextEditingController controllerCompanyName = TextEditingController();
  TextEditingController controllerEntity = TextEditingController();
  FocusNode focusNodeCompany = FocusNode();
  FocusNode focusNodeEntity = FocusNode();
  final _formKeyBusiness = GlobalKey<FormState>();
  late UserBloc _userBloc;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _userBloc = BlocProvider.of<UserBloc>(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(focusNodeCompany);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.maxFinite,
        height: double.maxFinite,
        child: Form(
          key: _formKeyBusiness,
          child: Stack(
            children: [
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(top: 96),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomDropdown(
                      title: 'País *',
                      hintText: 'Selecciona un país',
                      list: countries.keys.toList(),
                      showIcon: true,
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      onSelected: (selected) {
                        setState(() {
                          selectedCountry = selected;

                          // Reseteamos los valores de estado y ciudad al cambiar el país
                          selectedState = null;
                          selectedCity = null;

                          states = countries[selectedCountry]!.keys.toList();
                          cities = [];
                        });
                      },
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: CustomDropdown(
                            title: 'Estado *',
                            hintText: 'Seleccionar',
                            list: states,
                            padding: EdgeInsets.only(left: 24, right: 8),
                            onSelected: (selected) {
                              setState(() {
                                selectedState = selected;
                                cities =
                                    countries[selectedCountry]![selectedState]!;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: CustomDropdown(
                            title: 'Ciudad *',
                            hintText: 'Seleccionar',
                            list: cities,
                            padding: EdgeInsets.only(right: 24, left: 8),
                            onSelected: (selected) {
                              selectedCity = selected;
                              // Aquí puedes manejar la selección de la ciudad si es necesario
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    CustomDropdown(
                      title: 'Categoria',
                      hintText: 'Seleccionar',
                      list: const [
                        'Inmobiliaria',
                        'Automotriz',
                        'Restaurantes',
                        'Otro'
                      ],
                      padding: EdgeInsets.only(left: 24, right: 24),
                      onSelected: (selected) {
                        setState(() {
                          selecteCategory = selected;
                          controllerCompanyName.text = '';
                          controllerEntity.text = '';
                        });
                      },
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Visibility(
                      visible: selecteCategory != null,
                      child: CustomInput(
                        title: selecteCategory == 'Inmobiliaria'
                            ? 'Proyecto'
                            : selecteCategory == 'Automotriz'
                                ? 'Empresa/Marca'
                                : 'Empresa',
                        controller: controllerCompanyName,
                        focusNode: focusNodeCompany,
                      ),
                    ),
                    Visibility(
                      visible: selecteCategory != null,
                      child: CustomInput(
                        title: selecteCategory == 'Inmobiliaria'
                            ? 'Empresa desarrolladora'
                            : selecteCategory == 'Automotriz'
                                ? 'Sucursal/Agencia'
                                : 'Sucursal',
                        controller: controllerEntity,
                        focusNode: focusNodeEntity,
                      ),
                    ),
                    PressTransform(
                      onPressed: () async {
                        if (!_formKeyBusiness.currentState!.validate()) {
                          showErrorSnackBar(context,
                              "Por favor, completa todos los campos requeridos.");
                          return;
                        }

                        if (selecteCategory == null ||
                            selectedCity == null ||
                            selectedCountry == null ||
                            selectedState == null) {
                          showErrorSnackBar(context,
                              "Por favor, selecciona todas las opciones requeridas.");
                          return;
                        }

                        final userState = _userBloc.state;
                        if (userState is! UserLoaded) {
                          showErrorSnackBar(context,
                              "El usuario no está cargado correctamente.");
                          return;
                        }

                        try {
                          final response = await ApiService().createBusiness(
                              name: controllerCompanyName.text,
                              entity: controllerEntity.text,
                              country: selectedCountry!,
                              state: selectedState!,
                              city: selectedCity!,
                              category: selecteCategory!);

                          if (!mounted) return;

                          if (response.statusCode == 201) {
                            showSuccessSnackBar(context);
                            Navigator.pop(
                                context,
                                Business.fromJson(
                                    jsonDecode(response.body)['business']));
                          } else {
                            showErrorSnackBar(
                                context, "No se logró crear la empresa");
                          }
                        } catch (e) {
                          if (!mounted) return;
                          showErrorSnackBar(context, "Ocurrió un error: $e");
                        }
                      },
                      child: Container(
                        width: double.maxFinite,
                        height: 56,
                        margin:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: ColorStyle.solidBlue),
                        child: Text(
                          "Crear",
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Montserrat',
                              color: Colors.white,
                              fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.only(bottom: 0),
                height: 96,
                color: Colors.white,
                width: double.maxFinite,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Stack(
                        alignment: AlignmentDirectional.centerStart,
                        children: [
                          InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: const Icon(FeatherIcons.arrowLeft)),
                          const Align(
                              alignment: Alignment.center,
                              child: Text(
                                "Agregar empresas",
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Montserrat',
                                    fontSize: 15),
                              )),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Container(
                      height: 0.8,
                      width: double.maxFinite,
                      color: ColorStyle.borderGrey,
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    ;
  }
}
