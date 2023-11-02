import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:w_app/bloc/user_bloc/user_bloc.dart';
import 'package:w_app/bloc/user_bloc/user_bloc_state.dart';
import 'package:w_app/data/countries_data.dart';
import 'package:w_app/models/company_model.dart';
import 'package:w_app/models/user.dart';
import 'package:w_app/screens/add/widgets/custom_textfield_widget.dart';
import 'package:w_app/services/api/api_service.dart';
import 'package:w_app/styles/color_style.dart';
import 'package:w_app/widgets/circularAvatar.dart';
import 'package:w_app/widgets/dotters.dart';
import 'package:w_app/widgets/press_transform_widget.dart';
import 'package:w_app/widgets/snackbar.dart';

class CombinedBottomSheet extends StatefulWidget {
  final User user;

  const CombinedBottomSheet({super.key, required this.user});
  @override
  _CombinedBottomSheetState createState() => _CombinedBottomSheetState();
}

class _CombinedBottomSheetState extends State<CombinedBottomSheet>
    with SingleTickerProviderStateMixin {
  TextEditingController controllerReview = TextEditingController();
  TextEditingController controllerSearch = TextEditingController();
  double ratingController = 0.0;
  FocusNode focusNodeReview = FocusNode();
  FocusNode focusNodeSearch = FocusNode();
  ValueNotifier<bool> showReviewPageNotifier = ValueNotifier<bool>(true);
  bool showAddCompanyPage = false;

  Business? selectedCompany;
  String searchTerm = '';

//AddCompany
  String? selectedCountry;
  List<String> states = [];
  String? selectedState;
  List<String> cities = [];
  String? selectedCity;
  TextEditingController controllerCompanyName = TextEditingController();
  TextEditingController controllerEntity = TextEditingController();
  FocusNode focusNodeCompany = FocusNode();
  FocusNode focusNodeEntity = FocusNode();
  late Future<List<Business>> futureSearch;
  final _formKeyReview = GlobalKey<FormState>();

  late UserBloc _userBloc;

  @override
  void initState() {
    super.initState();
    showReviewPageNotifier.value = true;
    _userBloc = BlocProvider.of<UserBloc>(context);

    showReviewPageNotifier.addListener(() {
      if (showReviewPageNotifier.value) {
        focusNodeReview.requestFocus();
      } else {
        if (showAddCompanyPage) {
          focusNodeCompany.requestFocus();
        } else {
          futureSearch = ApiService().getSearch(searchTerm);
          focusNodeSearch.requestFocus();
        }
      }
    });
  }

  @override
  void dispose() {
    showReviewPageNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      child: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: showReviewPageNotifier.value
            ? _reviewPage(context)
            : (showAddCompanyPage
                ? _addCompanyPage(context)
                : _companyListPage(context)),
      ),
    );
  }

  Widget _reviewPage(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(focusNodeReview);
    });
    return Form(
      key: _formKeyReview,
      child: Container(
        width: double.maxFinite,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  left: 16, right: 16, top: 16, bottom: 12),
              child: Stack(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      "Cancelar",
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Montserrat',
                          fontSize: 15),
                    ),
                  ),
                  const Align(
                      alignment: Alignment.center,
                      child: Text(
                        "Nueva reseña",
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Montserrat',
                            fontSize: 15),
                      )),
                  const Positioned(
                      right: 0, child: Icon(FeatherIcons.moreHorizontal))
                ],
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: Row(
                children: [
                  const CircularAvatarW(
                    externalRadius: Offset(42, 42),
                    internalRadius: Offset(36, 36),
                    nameAvatar: "J",
                    isCompany: false,
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  Flexible(
                    child: SizedBox(
                      width: double.maxFinite,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.user.name} ${widget.user.lastName}',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Montserrat',
                                fontSize: 14),
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          Text(
                            "Oct 25",
                            style: TextStyle(
                                fontWeight: FontWeight.w400,
                                color: ColorStyle().grey,
                                fontFamily: 'Montserrat',
                                fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: CustomTextField(
                  focusNode: focusNodeReview,
                  controller: controllerReview,
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        selectedCompany == null) {
                      return 'Por favor escribe una reseña y elige una entidad';
                    }
                    // Add more validation if necessary
                    return null;
                  },
                )),
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 8),
              child: SvgPicture.asset(
                'assets/images/icons/addImage.svg',
                width: 24,
                height: 24,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: RatingBar.builder(
                maxRating: 5,
                itemSize: 24,
                initialRating: 0,
                glowColor: Colors.white,

                minRating: 1,
                direction: Axis.horizontal,
                unratedColor: Colors.grey[200],
                // ignoreGestures: true,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 0.5),
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: ColorStyle().solidBlue,
                ),
                onRatingUpdate: (rating) {
                  setState(() {
                    ratingController = rating;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: PressTransform(
                      onPressed: () {
                        setState(() {
                          showReviewPageNotifier.value = false;
                        });
                      },
                      child: Container(
                        width: double.maxFinite,
                        color: Colors.transparent,
                        child: selectedCompany != null
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  CircularAvatarW(
                                    externalRadius: Offset(42, 42),
                                    internalRadius: Offset(36, 36),
                                    nameAvatar:
                                        selectedCompany!.name.substring(0, 1),
                                    isCompany: false,
                                  ),
                                  const SizedBox(
                                    width: 12,
                                  ),
                                  Flexible(
                                    child: SizedBox(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            selectedCompany!.name,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                                fontFamily: 'Montserrat'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 12,
                                  ),
                                  SizedBox(
                                    width: 56,
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          right: 8,
                                          child: CircularAvatarW(
                                            externalRadius: Offset(32, 32),
                                            internalRadius: Offset(28, 28),
                                            nameAvatar: "S",
                                            isCompany: true,
                                            sizeIcon: 16,
                                          ),
                                        ),
                                        Positioned(
                                          child: Container(
                                            width: 32,
                                            height: 32,
                                            decoration: BoxDecoration(
                                                color: ColorStyle().lightGrey,
                                                shape: BoxShape.circle),
                                            child: DottedCircularBorder(
                                              color: ColorStyle().borderGrey,
                                              diameter: 26,
                                              borderWidth: 1.2,
                                              icon: Container(
                                                decoration: const BoxDecoration(
                                                    shape: BoxShape.circle),
                                                child: Icon(
                                                  Icons.cached,
                                                  color: ColorStyle().solidBlue,
                                                  size: 20,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              )
                            : Row(
                                children: [
                                  DottedCircularBorder(
                                    color: ColorStyle().borderGrey,
                                    diameter: 32,
                                    borderWidth: 1.5,
                                    icon: Container(
                                      decoration: const BoxDecoration(
                                          shape: BoxShape.circle),
                                      child: Icon(
                                        FeatherIcons.plus,
                                        color: ColorStyle().borderGrey,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 16,
                                  ),
                                  Text(
                                    "Selecciona una entidad",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        color: ColorStyle().textGrey,
                                        fontFamily: 'Montserrat',
                                        fontSize: 14),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                  PressTransform(
                    onPressed: () async {
                      if (_formKeyReview.currentState!.validate()) {
                        final userState = _userBloc.state;
                        if (userState is UserLoaded) {
                          await ApiService()
                              .createReview(
                                  content: controllerReview.text,
                                  idBusiness: selectedCompany!.idBusiness,
                                  idUser: userState.user.idUser)
                              .then((value) {
                            if (value.statusCode == 201) {
                              showSuccessSnackBar(context);
                              Navigator.pop(context);
                            } else {
                              showErrorSnackBar(
                                  context, "No se logro crear reseña");
                              Navigator.pop(context);
                            }
                          });
                        }
                      }
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                          color: ColorStyle().lightGrey,
                          shape: BoxShape.circle),
                      child: Icon(
                        FeatherIcons.arrowRight,
                        color: ColorStyle().midToneGrey,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _companyListPage(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(focusNodeSearch);
    });
    return ConstrainedBox(
      constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.54,
          minHeight: MediaQuery.of(context).size.height * 0.2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.only(top: 16),
            width: double.maxFinite,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Stack(
                    alignment: AlignmentDirectional.centerStart,
                    children: [
                      InkWell(
                          onTap: () {
                            setState(() {
                              showReviewPageNotifier.value = true;
                              controllerSearch.clear();
                              searchTerm = '';
                            });
                          },
                          child: const Icon(FeatherIcons.arrowLeft)),
                      const Align(
                          alignment: Alignment.center,
                          child: Text(
                            "Elegir entidad",
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Montserrat',
                                fontSize: 15),
                          )),
                      const Positioned(
                          right: 0, child: Icon(FeatherIcons.moreHorizontal))
                    ],
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                Container(
                  height: 0.8,
                  width: double.maxFinite,
                  color: ColorStyle().borderGrey,
                )
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 96), //51 textfield
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: PressTransform(
                      onPressed: () {
                        setState(() {
                          showReviewPageNotifier.value = false;
                          showAddCompanyPage = true;
                        });
                      },
                      child: RoundedDotterRectangleBorder(
                          height: 52,
                          width: double.maxFinite,
                          color: ColorStyle().borderGrey,
                          borderWidth: 1,
                          icon: Container(
                            width: double.maxFinite,
                            height: double.maxFinite,
                            color: Colors.white,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  FeatherIcons.plusCircle,
                                  color: ColorStyle().borderGrey,
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                Text(
                                  'Agregar Empresa',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: ColorStyle().borderGrey,
                                      fontSize: 14,
                                      fontFamily: 'Montserrat'),
                                ),
                              ],
                            ),
                          )),
                    ),
                  ),
                  FutureBuilder(
                      future: futureSearch,
                      builder:
                          (context, AsyncSnapshot<List<Business>> snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                            return _buildLoadingState();
                          case ConnectionState.done:
                            if (snapshot.hasError) {
                              return _buildErrorState();
                            } else if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return _buildEmptyState();
                            } else {
                              return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: List.generate(
                                    snapshot.data!.length,
                                    (index) => GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          showReviewPageNotifier.value = true;
                                          selectedCompany =
                                              snapshot.data![index];
                                        });

                                        // Aquí puedes agregar lógica adicional si es necesario, por ejemplo, para manejar la selección de la empresa
                                      },
                                      child: Container(
                                        width: double.maxFinite,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16, horizontal: 16),
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              color: ColorStyle()
                                                  .borderGrey, // Color del borde.
                                              width: 0.5, // Ancho del borde.
                                            ),
                                          ),
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            const CircularAvatarW(
                                              externalRadius: Offset(42, 42),
                                              internalRadius: Offset(36, 36),
                                              nameAvatar: "S",
                                              isCompany: true,
                                            ),
                                            const SizedBox(
                                              width: 16,
                                            ),
                                            Flexible(
                                              child: SizedBox(
                                                width: double.maxFinite,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      snapshot
                                                          .data![index].name,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 14,
                                                          fontFamily:
                                                              'Montserrat'),
                                                    ),
                                                    Text(
                                                      snapshot
                                                          .data![index].city,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color:
                                                              ColorStyle().grey,
                                                          fontSize: 12,
                                                          fontFamily:
                                                              'Montserrat'),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color:
                                                      ColorStyle().lightGrey),
                                              child: SvgPicture.asset(
                                                'assets/images/icons/WhistleActive.svg',
                                                width: 24,
                                                height: 20,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ));
                            }
                          default:
                            return _buildInitialState(); // Otros estados no esperados
                        }
                      }),
                ],
              ),
            ),
          ),
          TextField(
            controller: controllerSearch,
            maxLines: null,
            focusNode: focusNodeSearch,
            decoration: InputDecoration(
              hintText: 'Escribe algo...',
              contentPadding: const EdgeInsets.only(bottom: 16, top: 16),
              border: const OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[100],
              prefixIcon: const Icon(FeatherIcons.search),
              suffixIcon: IconButton(
                onPressed: () {
                  controllerSearch.clear();
                },
                icon: const Icon(Icons.clear),
              ),
            ),
            onChanged: (value) {
              if (value.isNotEmpty) {
                searchTerm =
                    value; // <-- Actualiza el término de búsqueda cada vez que cambia el valor
                if (value.length >= 3) {
                  setState(() {
                    futureSearch = ApiService().getSearch(value);
                  });
                }
              } else {
                setState(() {
                  futureSearch = ApiService().getSearch(value);
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _addCompanyPage(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(focusNodeCompany);
    });
    return ConstrainedBox(
      constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.54,
          minHeight: MediaQuery.of(context).size.height * 0.2),
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.only(top: 16),
              width: double.maxFinite,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Stack(
                      alignment: AlignmentDirectional.centerStart,
                      children: [
                        InkWell(
                            onTap: () {
                              setState(() {
                                showAddCompanyPage = false;
                                // controllerSearch.clear();
                              });
                            },
                            child: const Icon(FeatherIcons.arrowLeft)),
                        const Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Agregar entidad",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Montserrat',
                                  fontSize: 15),
                            )),
                        const Positioned(
                            right: 0, child: Icon(FeatherIcons.moreHorizontal))
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Container(
                    height: 0.8,
                    width: double.maxFinite,
                    color: ColorStyle().borderGrey,
                  )
                ],
              ),
            ),
            CustomDropdown(
              title: 'País *',
              hintText: 'Selecciona un país',
              list: countries.keys.toList(),
              showIcon: true,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                        selectedState = selected as String?;
                        cities = countries[selectedCountry]![selectedState]!;
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
                      // Aquí puedes manejar la selección de la ciudad si es necesario
                    },
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 16,
            ),
            CustomInput(
              title: 'Nombre de la empresa',
              controller: controllerCompanyName,
              focusNode: focusNodeCompany,
            ),
            CustomInput(
              title: 'Entidad / Grupo',
              controller: controllerEntity,
              focusNode: focusNodeEntity,
            ),
            PressTransform(
              onPressed: () {},
              child: Container(
                width: double.maxFinite,
                height: 56,
                margin: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: ColorStyle().solidBlue),
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
    );
  }
}

Widget _buildInitialState() {
  return const Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      SizedBox(
        height: 56,
      ),
      Text(
        '!Ups¡',
        textAlign: TextAlign.center,
        style: TextStyle(
            fontFamily: "Montserrat",
            fontSize: 18,
            fontWeight: FontWeight.w700),
      ),
      SizedBox(
        height: 16,
      ),
      Text(
        'Necesitas al menos 3 letras\npara realizar una búsqueda',
        textAlign: TextAlign.center,
        style: TextStyle(
            fontFamily: "Montserrat",
            fontSize: 18,
            fontWeight: FontWeight.w400),
      ),
    ],
  );
}

Widget _buildLoadingState() {
  return const Padding(
    padding: EdgeInsets.only(top: 32),
    child: Center(child: CircularProgressIndicator.adaptive()),
  );
}

Widget _buildErrorState() {
  return const Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      SizedBox(
        height: 56,
      ),
      Text(
        '!Ups¡',
        textAlign: TextAlign.center,
        style: TextStyle(
            fontFamily: "Montserrat",
            fontSize: 18,
            fontWeight: FontWeight.w700),
      ),
      SizedBox(
        height: 16,
      ),
      Text(
        'Parece que no existe ¿Quieres ser el primero en hacerlo?',
        textAlign: TextAlign.center,
        style: TextStyle(
            fontFamily: "Montserrat",
            fontSize: 18,
            fontWeight: FontWeight.w400),
      ),
    ],
  );
}

Widget _buildEmptyState() {
  return const Center(
      child: Text('No hay resultados disponibles',
          style: TextStyle(
              fontFamily: "Montserrat",
              fontSize: 18,
              fontWeight: FontWeight.w400)));
}

// class ReviewBottomSheet extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding:
//           EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           const Padding(
//             padding: EdgeInsets.all(8.0),
//             child: TextField(
//               maxLines: null,
//               decoration: InputDecoration(
//                 hintText: 'Escribe algo...',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: ElevatedButton(
//               onPressed: () {
//                 showModalBottomSheet(
//                   context: context,
//                   isScrollControlled: true,
//                   builder: (context) => CompanyListBottomSheet(),
//                 );
//               },
//               child: const Text('Agregar Empresa'),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class CompanyListBottomSheet extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding:
//           EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
//       child: SingleChildScrollView(
//         child: ConstrainedBox(
//           constraints: BoxConstraints(
//             minHeight: 150, // La altura mínima que deseas para el bottom sheet
//             maxHeight: MediaQuery.of(context).size.height * 0.7,
//           ),
//           child: ListView.builder(
//             itemCount: 10, // Lista de empresas
//             itemBuilder: (context, index) {
//               return ListTile(
//                 title: Text("Empresa ${index}"), // Nombre de la empresa
//                 onTap: () {
//                   Navigator.pop(context);
//                   // Aquí puedes agregar lógica adicional si es necesario
//                 },
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }

class CustomInput extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final FocusNode focusNode;

  CustomInput(
      {super.key,
      required this.title,
      required this.controller,
      required this.focusNode});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: "Montserrat",
                color: ColorStyle().textGrey,
                fontSize: 14,
                fontWeight: FontWeight.w400),
          ),
          Container(
            width: double.maxFinite,
            height: 48,
            margin: EdgeInsets.only(top: 2),
            padding: EdgeInsets.only(left: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.0),
              border: Border.all(
                color: ColorStyle().borderGrey,
                width: 1.0,
              ),
              color:
                  Colors.white, // Cambia el color de fondo según tu preferencia
            ),
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              style: TextStyle(fontFamily: "Montserrat", fontSize: 14),
              decoration: InputDecoration(
                border: InputBorder.none,

                hintText: 'Input*', // Cambia el texto de marcador de posición
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomDropdown extends StatefulWidget {
  final String title;
  final String hintText;
  final List<String> list;
  final ValueChanged<String> onSelected;
  final EdgeInsetsGeometry? padding;
  final bool? showIcon;

  CustomDropdown(
      {required this.list,
      required this.onSelected,
      required this.title,
      required this.hintText,
      this.padding,
      this.showIcon});

  @override
  _CustomDropdownState createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  String _selected = '';

  @override
  void didUpdateWidget(CustomDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Si la lista anterior no es igual a la lista nueva y la selección actual no está en la nueva lista, restablece la selección
    if (oldWidget.list != widget.list && !widget.list.contains(_selected)) {
      setState(() {
        _selected = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          widget.padding ?? EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: "Montserrat",
                color:
                    Colors.grey, // Suponiendo que no tienes la clase ColorStyle
                fontSize: 14,
                fontWeight: FontWeight.w400),
          ),
          Container(
            width: double.maxFinite,
            height: 48,
            margin: EdgeInsets.only(top: 2),
            padding: EdgeInsets.only(left: 12, right: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.0),
              border: Border.all(
                color: ColorStyle().borderGrey,
                width: 1.0,
              ),
              color: Colors.white,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: _selected.isEmpty ? null : _selected,
                style: TextStyle(fontFamily: "Montserrat", color: Colors.black),
                hint: Text(
                  widget.hintText,
                  style: TextStyle(color: Colors.grey),
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    _selected = newValue!;
                  });
                  widget.onSelected(_selected);
                },
                icon: Icon(
                  FeatherIcons.chevronDown,
                  size: 20,
                  color: ColorStyle().textGrey,
                ),
                items:
                    widget.list.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                      value: value,
                      child: ListTile(
                          leading: widget.showIcon ?? false
                              ? Icon(
                                  Icons.flag,
                                  size: 24,
                                )
                              : null,
                          minLeadingWidth: 0,
                          contentPadding: EdgeInsets.only(),
                          dense: true,
                          title: Text(
                            value,
                            style: TextStyle(
                                fontFamily: "Montserrat", color: Colors.black),
                          )));
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
