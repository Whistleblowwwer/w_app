import 'dart:convert';
import 'package:http/http.dart' as http;
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
import 'package:w_app/widgets/countries_list_screen.dart';
import 'package:w_app/widgets/custom_dropdown_menu.dart';
import 'package:w_app/widgets/press_transform_widget.dart';
import 'package:w_app/widgets/snackbar.dart';

class AddBusinessScreen extends StatefulWidget {
  const AddBusinessScreen({super.key});

  @override
  State<AddBusinessScreen> createState() => _AddBusinessScreenState();
}

class _AddBusinessScreenState extends State<AddBusinessScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Map<String, dynamic>>? states;
  List<Map<String, dynamic>>? cities;

  String? selecteCategory;

  TextEditingController controllerCompanyName = TextEditingController();
  TextEditingController controllerEntity = TextEditingController();
  FocusNode focusNodeCompany = FocusNode();
  FocusNode focusNodeEntity = FocusNode();
  final _formKeyBusiness = GlobalKey<FormState>();
  late UserBloc _userBloc;
  bool isProcessing = false;

  Map<String, dynamic>? selectedCountry;
  Map<String, dynamic>? selectedState;
  Map<String, dynamic>? selectedCity;

  bool loadingCountry = false;
  bool loadingState = false;
  bool loadingCity = false;

  final GlobalKey navigatorKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _userBloc = BlocProvider.of<UserBloc>(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(focusNodeCompany);
    });
  }

  Future<List<Map<String, dynamic>>> getStatesbyCountry(String iso2Code) async {
    var headers = {
      'X-CSCAPI-KEY': 'NWlXQUJPZ2JmejVZY2NSODdTNXpBc3VxdWVxSTAydEpqU01tVENZaQ=='
    };
    var url = Uri.parse(
        'https://api.countrystatecity.in/v1/countries/$iso2Code/states');

    try {
      var request = http.Request('GET', url);
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final List<dynamic> list = json.decode(responseBody);
        return list
            .map<Map<String, dynamic>>((item) => item as Map<String, dynamic>)
            .toList();
      } else {
        // Manejar otros códigos de estado específicos si es necesario
        return [];
      }
    } catch (e) {
      // Manejar errores de conexión, timeout, etc.
      print('Ocurrió un error al realizar la solicitud: $e');
      return []; // O considera devolver null o lanzar la excepción
    } finally {
      // Cerrar la respuesta si es necesario
    }
  }

  Future<List<Map<String, dynamic>>> getCitiesbyStateAndCountry(
      String iso2CountryLocal, String iso2StateLocal) async {
    var headers = {
      'X-CSCAPI-KEY': 'NWlXQUJPZ2JmejVZY2NSODdTNXpBc3VxdWVxSTAydEpqU01tVENZaQ=='
    };
    var url = Uri.parse(
        'https://api.countrystatecity.in/v1/countries/$iso2CountryLocal/states/$iso2StateLocal/cities');

    try {
      var request = http.Request('GET', url);
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final List<dynamic> list = json.decode(responseBody);
        return list
            .map<Map<String, dynamic>>((item) => item as Map<String, dynamic>)
            .toList();
      } else {
        // Manejar otros códigos de estado específicos si es necesario
        return [];
      }
    } catch (e) {
      // Manejar errores de conexión, timeout, etc.
      return []; // O considera devolver null o lanzar la excepción
    } finally {
      // Cerrar la respuesta si es necesario
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        width: double.maxFinite,
        height: double.maxFinite,
        child: Form(
          key: _formKeyBusiness,
          child: Stack(
            children: [
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(top: 96),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      margin:
                          const EdgeInsets.only(top: 24, left: 24, right: 24),
                      width: double.maxFinite,
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        'País',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: "Montserrat",
                            color: Colors.grey,
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                    PressTransform(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CountriesListScreen(
                                    listDrop: countries,
                                    title: 'Lista de Países',
                                    showIcon: true,
                                  )),
                        ).then((value) async {
                          setState(() {
                            selectedCountry = value;
                          });
                          if (selectedCountry == null) return;
                          setState(() {
                            loadingState = true;
                            loadingCity = true;
                            selectedState = null;
                            selectedCity = null;
                          });
                          states = await getStatesbyCountry(
                              selectedCountry!['iso2']);
                          setState(() {
                            loadingState = false;
                          });
                        });
                      },
                      child: Container(
                        width: double.maxFinite,
                        height: 48,
                        margin:
                            const EdgeInsets.only(top: 2, left: 24, right: 24),
                        padding: const EdgeInsets.only(left: 12, right: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.0),
                          border: Border.all(
                            color: ColorStyle.borderGrey,
                            width: 1.0,
                          ),
                          color: Colors.white,
                        ),
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${selectedCountry?['name'] ?? ''}',
                                style:
                                    const TextStyle(fontFamily: 'Montserrat'),
                              ),
                            ),
                            const Icon(
                              Icons.navigate_next_rounded,
                              color: ColorStyle.textGrey,
                            )
                          ],
                        ),
                      ),
                    ),
//
                    Container(
                      margin:
                          const EdgeInsets.only(top: 8, left: 24, right: 24),
                      width: double.maxFinite,
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        'Estado',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: "Montserrat",
                            color: Colors.grey,
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                    PressTransform(
                      onPressed: () async {
                        if (states == null || loadingState) return;
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CountriesListScreen(
                                    listDrop: states ?? [],
                                    title: 'Lista de Estados',
                                  )),
                        ).then((value) async {
                          setState(() {
                            selectedState = value;
                          });
                          if (selectedState == null) return;
                          setState(() {
                            loadingCity = true;
                          });
                          cities = await getCitiesbyStateAndCountry(
                              selectedCountry!['iso2'], selectedState!['iso2']);
                          setState(() {
                            loadingCity = false;
                          });
                        });
                      },
                      child: Container(
                        width: double.maxFinite,
                        height: 48,
                        margin:
                            const EdgeInsets.only(top: 2, left: 24, right: 24),
                        padding: const EdgeInsets.only(left: 12, right: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.0),
                          border: Border.all(
                            color: ColorStyle.borderGrey,
                            width: 1.0,
                          ),
                          color: Colors.white,
                        ),
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${selectedState?['name'] ?? ''}',
                                style:
                                    const TextStyle(fontFamily: 'Montserrat'),
                              ),
                            ),
                            loadingState || states == null
                                ? const CircularProgressIndicator.adaptive(
                                    backgroundColor:
                                        ColorStyle.grey, // Fondo del indicador
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        ColorStyle.darkPurple),
                                  )
                                : const Icon(
                                    Icons.navigate_next_rounded,
                                    color: ColorStyle.textGrey,
                                  )
                          ],
                        ),
                      ),
                    ),
                    Container(
                      margin:
                          const EdgeInsets.only(top: 8, left: 24, right: 24),
                      width: double.maxFinite,
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        'Ciudad',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: "Montserrat",
                            color: Colors.grey,
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                    PressTransform(
                      onPressed: () async {
                        if (cities == null || loadingCity) return;
                        selectedCity = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CountriesListScreen(
                                    listDrop: cities ?? [],
                                    title: 'Lista de Estados',
                                  )),
                        );
                      },
                      child: Container(
                        width: double.maxFinite,
                        height: 48,
                        margin:
                            const EdgeInsets.only(top: 2, left: 24, right: 24),
                        padding: const EdgeInsets.only(left: 12, right: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.0),
                          border: Border.all(
                            color: ColorStyle.borderGrey,
                            width: 1.0,
                          ),
                          color: Colors.white,
                        ),
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${selectedCity?['name'] ?? ''}',
                                style:
                                    const TextStyle(fontFamily: 'Montserrat'),
                              ),
                            ),
                            loadingCity || cities == null
                                ? const CircularProgressIndicator.adaptive(
                                    backgroundColor:
                                        ColorStyle.grey, // Fondo del indicador
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        ColorStyle.darkPurple),
                                  )
                                : const Icon(
                                    Icons.navigate_next_rounded,
                                    color: ColorStyle.textGrey,
                                  )
                          ],
                        ),
                      ),
                    ),
                    // CustomDropdown(
                    //   title: 'País *',
                    //   hintText: 'Selecciona un país',
                    //   list: countries
                    //       .map((country) => country["name"].toString())
                    //       .toList(),
                    //   showIcon: true,
                    //   padding:
                    //       EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    //   onSelected: (selected) {
                    //     setState(() {
                    //       selectedCountry = selected;

                    //       // Reseteamos los valores de estado y ciudad al cambiar el país
                    //       selectedState = null;
                    //       selectedCity = null;

                    //       states =
                    //           []; // countries[selectedCountry]!.keys.toList();
                    //       cities = [];
                    //     });
                    //   },
                    // ),
                    const Row(
                      children: [
                        // Expanded(
                        //   child: CustomDropdown(
                        //     title: 'Estado *',
                        //     hintText: 'Seleccionar',
                        //     list: ,
                        //     padding: EdgeInsets.only(left: 24, right: 8),
                        //     onSelected: (selected) {
                        //       setState(() {
                        //         selectedState = selected;
                        //         cities =
                        //             []; // countries[selectedCountry]![selectedState]!;
                        //       });
                        //     },
                        //   ),
                        // ),
                        // Expanded(
                        //   child: CustomDropdown(
                        //     title: 'Ciudad *',
                        //     hintText: 'Seleccionar',
                        //     list: cities,
                        //     padding: EdgeInsets.only(right: 24, left: 8),
                        //     onSelected: (selected) {
                        //       selectedCity = selected;
                        //       // Aquí puedes manejar la selección de la ciudad si es necesario
                        //     },
                        //   ),
                        // ),
                      ],
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    CustomDropdown(
                      title: 'Categoría',
                      hintText: 'Seleccionar',
                      list: const [
                        'Inmobiliaria',
                        'Automotriz',
                        'Restaurantes',
                        'Otro'
                      ],
                      padding: const EdgeInsets.only(left: 24, right: 24),
                      onSelected: (selected) {
                        setState(() {
                          selecteCategory = selected;
                          controllerCompanyName.text = '';
                          controllerEntity.text = '';
                        });
                      },
                    ),
                    const SizedBox(
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
                        if (isProcessing) return; // Evita múltiples presiones

                        if (!_formKeyBusiness.currentState!.validate()) {
                          showErrorSnackBar(context,
                              "Por favor, completa todos los campos requeridos.");
                          return;
                        }
                        _formKeyBusiness.currentState!.save();

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
                          isProcessing = true; // Comienza el procesamiento
                          final response = await ApiService().createBusiness(
                              name: controllerCompanyName.text,
                              entity: controllerEntity.text,
                              iso2Country: selectedCountry!['iso2'],
                              country: selectedCountry!['name'],
                              iso2State: selectedState!['iso2'],
                              state: selectedState!['name'],
                              city: selectedCity!['name'],
                              category: selecteCategory!);

                          if (!mounted) return;

                          if (response.statusCode == 201) {
                            showSuccessSnackBar(context);
                            Navigator.pop(
                                context,
                                Business.fromJson(
                                    jsonDecode(response.body)['business']));
                          } else if (response.statusCode == 400) {
                            showErrorSnackBar(
                                context, "Hay algo malo con la información");
                          } else {
                            print(response.statusCode);
                            print(response.body);
                            showErrorSnackBar(
                                context, "No se logró crear la empresa");
                          }
                        } catch (e) {
                          print(e);

                          if (!mounted) return;
                          showErrorSnackBar(context, "Ocurrió un error: $e");
                        }
                        setState(() {
                          isProcessing = false;
                        });
                      },
                      child: Container(
                        width: double.maxFinite,
                        height: 56,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 32),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: ColorStyle.solidBlue),
                        child: const Text(
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
                padding: const EdgeInsets.only(bottom: 0),
                height: 96,
                color: Colors.white,
                width: double.maxFinite,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
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
                    const SizedBox(
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
  }
}
