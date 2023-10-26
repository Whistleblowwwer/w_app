import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:w_app/models/company_model.dart';
import 'package:w_app/screens/add/widgets/custom_textfield_widget.dart';
import 'package:w_app/services/api/api_service.dart';
import 'package:w_app/styles/color_style.dart';
import 'package:w_app/widgets/circularAvatar.dart';
import 'package:w_app/widgets/dotters.dart';
import 'package:w_app/widgets/press_transform_widget.dart';

class CombinedBottomSheet extends StatefulWidget {
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

  Company? selectedCompany;
  String searchTerm = '';

  @override
  void initState() {
    super.initState();
    showReviewPageNotifier.value = true;

    showReviewPageNotifier.addListener(() {
      if (showReviewPageNotifier.value) {
        focusNodeReview.requestFocus();
      } else {
        focusNodeSearch.requestFocus();
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
            : _companyListPage(context),
      ),
    );
  }

  Widget _reviewPage(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(focusNodeReview);
    });
    return Container(
      width: double.maxFinite,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding:
                const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 12),
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
                        const Text(
                          "Jorge Ancer",
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: CustomTextField(
                focusNode: focusNodeReview,
                controller: controllerReview,
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
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                      color: ColorStyle().lightGrey, shape: BoxShape.circle),
                  child: Icon(
                    FeatherIcons.arrowRight,
                    color: ColorStyle().midToneGrey,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _companyListPage(BuildContext context) {
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
              child: FutureBuilder(
                  future: searchTerm.length >= 3
                      ? ApiService().getSearch(searchTerm)
                      : null,
                  builder: (context, AsyncSnapshot<List<Company>> snapshot) {
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
                                      selectedCompany = snapshot.data![index];
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
                                                  snapshot.data![index].name,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 14,
                                                      fontFamily: 'Montserrat'),
                                                ),
                                                Text(
                                                  snapshot.data![index]
                                                      .parentCompany,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: ColorStyle().grey,
                                                      fontSize: 12,
                                                      fontFamily: 'Montserrat'),
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
                                              color: ColorStyle().lightGrey),
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
              if (value.length >= 3) {
                setState(() {
                  searchTerm =
                      value; // <-- Actualiza el término de búsqueda cada vez que cambia el valor
                });
              }
            },
          ),
        ],
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
