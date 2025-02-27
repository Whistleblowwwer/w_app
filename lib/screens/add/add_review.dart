import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:w_app/bloc/feed_bloc/feed_bloc.dart';
import 'package:w_app/bloc/feed_bloc/feed_event.dart';
import 'package:w_app/bloc/user_bloc/user_bloc.dart';
import 'package:w_app/bloc/user_bloc/user_bloc_state.dart';
import 'package:w_app/models/company_model.dart';
import 'package:w_app/models/review_model.dart';
import 'package:w_app/models/user.dart';
import 'package:w_app/screens/add/add_business_screen.dart';
import 'package:w_app/screens/add/widgets/custom_textfield_widget.dart';
import 'package:w_app/services/api/api_service.dart';
import 'package:w_app/styles/color_style.dart';
import 'package:w_app/widgets/circularAvatar.dart';
import 'package:w_app/widgets/dotters.dart';
import 'package:w_app/widgets/press_transform_widget.dart';
import 'package:w_app/widgets/showLoadingModal_widget.dart';
import 'package:w_app/widgets/snackbar.dart';
import 'package:intl/intl.dart';

class CombinedBottomSheet extends StatefulWidget {
  final User user;
  final Business? business;

  const CombinedBottomSheet({super.key, required this.user, this.business});
  @override
  CombinedBottomSheetState createState() => CombinedBottomSheetState();
}

class CombinedBottomSheetState extends State<CombinedBottomSheet>
    with SingleTickerProviderStateMixin {
  TextEditingController controllerReview = TextEditingController();
  TextEditingController controllerSearch = TextEditingController();
  double ratingController = 0.0;
  FocusNode focusNodeReview = FocusNode();
  FocusNode focusNodeSearch = FocusNode();
  ValueNotifier<bool> showReviewPageNotifier = ValueNotifier<bool>(true);
  bool showAddCompanyPage = false;

  Business? selectedCompany;
  bool ratingError = false;
  String searchTerm = '';

  List<File> images = [];

//AddCompany
  // String? selectedCountry;
  // List<String> states = [];
  // String? selectedState;

  // List<String> cities = [];
  // String? selectedCity;
  // String? selecteCategory;
  // TextEditingController controllerCompanyName = TextEditingController();
  // TextEditingController controllerEntity = TextEditingController();
  // FocusNode focusNodeCompany = FocusNode();
  // FocusNode focusNodeEntity = FocusNode();
  //   final _formKeyBusiness = GlobalKey<FormState>();
  final _formKeyReview = GlobalKey<FormState>();

  late Future<List<Business>> futureSearch;

  late UserBloc _userBloc;

  @override
  void initState() {
    super.initState();
    showReviewPageNotifier.value = true;
    _userBloc = BlocProvider.of<UserBloc>(context);

    selectedCompany = widget.business;

    showReviewPageNotifier.addListener(() {
      if (showReviewPageNotifier.value) {
        focusNodeReview.requestFocus();
      } else {
        if (showAddCompanyPage) {
          // focusNodeCompany.requestFocus();
        } else {
          futureSearch = ApiService().getSearch(searchTerm);
          focusNodeSearch.requestFocus();
        }
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(focusNodeReview);
    });
  }

  @override
  void dispose() {
    showReviewPageNotifier.dispose();
    focusNodeReview.dispose();
    focusNodeSearch.dispose();
    super.dispose();
  }

  String printFormattedDate() {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('MMM d').format(now);
    return formattedDate;
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
              : _companyListPage(context)),
    );
  }

  Widget _reviewPage(BuildContext context) {
    return Form(
      key: _formKeyReview,
      child: Container(
        width: double.maxFinite,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.54,
        ),
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(top: 64, bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16),
                    child: Row(
                      children: [
                        CircularAvatarW(
                          externalRadius: Offset(42, 42),
                          internalRadius: Offset(36, 36),
                          nameAvatar: widget.user.nameFirstLetter,
                          sizeText: 18,
                          isCompany: false,
                          urlImage: widget.user.profilePictureUrl,
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
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Montserrat',
                                      fontSize: 14),
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                Text(
                                  printFormattedDate(),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w400,
                                      color: ColorStyle.grey,
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      child: CustomTextField(
                        focusNode: focusNodeReview,
                        controller: controllerReview,
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              selectedCompany == null) {
                            return 'Por favor escribe una reseña y elige un proyecto - empresa';
                          }
                          // Add more validation if necessary
                          return null;
                        },
                      )),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.only(
                        left: 24, bottom: 16, top: images.isNotEmpty ? 8 : 0),
                    child: Row(
                      children: List.generate(
                        images.length + 1,
                        (index) {
                          if (index == 0) {
                            return PressTransform(
                              onPressed: () async {
                                if (images.length >= 6) return;
                                try {
                                  final ImagePicker picker = ImagePicker();
                                  final XFile? image = await picker.pickImage(
                                    source: ImageSource.gallery,
                                    imageQuality: 100,
                                  );
                                  if (image != null) {
                                    File file = File(image.path);

                                    setState(() {
                                      images.add(file);
                                    });
                                    // _uploadFile(
                                    //     file); // Llama a la función para subir el archivo
                                  }
                                } catch (e) {
                                  debugPrint(e.toString());
                                }
                              },
                              child: images.isEmpty
                                  ? SvgPicture.asset(
                                      'assets/images/icons/addImage.svg',
                                      width: 32,
                                      height: 32,
                                    )
                                  : RoundedDotterRectangleBorder(
                                      width: 90,
                                      height: 160,
                                      color: ColorStyle.borderGrey,
                                      backgroundcolor: Colors.white,
                                      borderRadius: 8,
                                      borderWidth: 1,
                                      icon: SvgPicture.asset(
                                        'assets/images/icons/addImage.svg',
                                        width: 32,
                                        height: 32,
                                      ),
                                    ),
                            );
                          } else {
                            return Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: PressTransform(
                                  onPressed: () async {
                                    if (images.length >= 8) return;
                                    try {
                                      final ImagePicker picker = ImagePicker();
                                      final XFile? image =
                                          await picker.pickImage(
                                        source: ImageSource.gallery,
                                        imageQuality: 100,
                                      );
                                      if (image != null) {
                                        File file = File(image.path);

                                        setState(() {
                                          images.add(file);
                                        });
                                        // _uploadFile(
                                        //     file); // Llama a la función para subir el archivo
                                      }
                                    } catch (e) {
                                      debugPrint(e.toString());
                                    }

                                    // Navigator.of(context).push(
                                    //     navegarFadeIn(
                                    //         context,
                                    //         ImageCarousel(
                                    //             initialPage:
                                    //                 index - 1,
                                    //             images: images)));
                                  },
                                  child: Hero(
                                    tag: images[index - 1].path,
                                    child: Stack(
                                      children: [
                                        Container(
                                          constraints: const BoxConstraints(
                                            minWidth: 90,
                                          ),
                                          child: Image.file(
                                            images[index - 1],
                                            fit: BoxFit.cover,
                                            height: 160,
                                          ),
                                        ),
                                        Positioned(
                                          right: 0,
                                          top: 0,
                                          child: PressTransform(
                                            onPressed: () {
                                              setState(() {
                                                images.removeAt(index - 1);
                                              });
                                            },
                                            child: Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 8),
                                              padding: const EdgeInsets.all(2),
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Color.fromRGBO(
                                                    0, 0, 0, 0.5),
                                              ),
                                              child: const Icon(
                                                Icons.close_rounded,
                                                size: 20,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: RatingBar.builder(
                      maxRating: 5,
                      itemSize: 24,
                      initialRating: ratingController,
                      glowColor: Colors.white,

                      minRating: 1,
                      direction: Axis.horizontal,
                      unratedColor: Colors.grey[200],
                      // ignoreGestures: true,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemPadding: const EdgeInsets.symmetric(horizontal: 0.5),
                      itemBuilder: (context, _) => const Icon(
                        Icons.star,
                        color: ColorStyle.solidBlue,
                      ),
                      onRatingUpdate: (rating) {
                        setState(() {
                          ratingController = rating;
                        });
                      },
                    ),
                  ),
                  Visibility(
                    visible: ratingError,
                    child: const Padding(
                      padding: EdgeInsets.only(left: 16, top: 4),
                      child: Text('Agrega un rating al review',
                          style: TextStyle(
                              fontFamily: 'Montserrat',
                              color: ColorStyle.accentRed,
                              fontSize: 12)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        CircularAvatarW(
                                          externalRadius: const Offset(42, 42),
                                          internalRadius: const Offset(36, 36),
                                          nameAvatar: selectedCompany!.name
                                              .substring(0, 1),
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
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 14,
                                                      fontFamily: 'Montserrat'),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 12,
                                        ),
                                        SizedBox(
                                          width: 56,
                                          child: Stack(
                                            children: [
                                              const Positioned(
                                                right: 8,
                                                child: CircularAvatarW(
                                                  externalRadius:
                                                      Offset(32, 32),
                                                  internalRadius:
                                                      Offset(28, 28),
                                                  nameAvatar: "S",
                                                  isCompany: true,
                                                  sizeIcon: 16,
                                                ),
                                              ),
                                              Positioned(
                                                child: Container(
                                                  width: 32,
                                                  height: 32,
                                                  decoration:
                                                      const BoxDecoration(
                                                          color: ColorStyle
                                                              .lightGrey,
                                                          shape:
                                                              BoxShape.circle),
                                                  child: DottedCircularBorder(
                                                    color:
                                                        ColorStyle.borderGrey,
                                                    diameter: 26,
                                                    borderWidth: 1.2,
                                                    icon: Container(
                                                      decoration:
                                                          const BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle),
                                                      child: const Icon(
                                                        Icons.cached,
                                                        color: ColorStyle
                                                            .solidBlue,
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
                                          color: ColorStyle.borderGrey,
                                          diameter: 32,
                                          borderWidth: 1.5,
                                          icon: Container(
                                            decoration: const BoxDecoration(
                                                shape: BoxShape.circle),
                                            child: const Icon(
                                              FeatherIcons.plus,
                                              color: ColorStyle.borderGrey,
                                              size: 24,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 16,
                                        ),
                                        const Flexible(
                                          child: Text(
                                            "Selecciona una proyecto / empresa",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                color: ColorStyle.textGrey,
                                                fontFamily: 'Montserrat',
                                                fontSize: 14),
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                        PressTransform(
                          onPressed: () async {
                            if (ratingController <= 0.0) {
                              setState(() {
                                ratingError = true;
                              });
                              return;
                            } else {
                              setState(() {
                                ratingError = false;
                              });
                            }

                            if (_formKeyReview.currentState!.validate()) {
                              final userState = _userBloc.state;

                              if (userState is UserLoaded) {
                                showLoadingDialog(context);
                                await ApiService()
                                    .createReview(
                                        content: controllerReview.text,
                                        idBusiness: selectedCompany!.idBusiness,
                                        idUser: userState.user.idUser,
                                        rating: ratingController)
                                    .then((value) async {
                                  if (value.statusCode == 201) {
                                    showSuccessSnackBar(context);
                                    FeedBloc feedBloc =
                                        BlocProvider.of<FeedBloc>(context);
                                    Map<String, dynamic> jsonResponse =
                                        jsonDecode(value.body);

                                    Review newReview =
                                        Review.fromJson(jsonResponse['review']);

                                    List<String> filePaths = images
                                        .map((file) => file.path)
                                        .toList();
                                    try {
                                      final imagesResponse =
                                          await ApiService().uploadUserImages(
                                        newReview
                                            .idReview, // userState.user.idUser,
                                        filePaths,
                                      );

                                      if (imagesResponse.statusCode == 201 ||
                                          imagesResponse.statusCode == 200) {
                                        final jsonImageResponse =
                                            json.decode(imagesResponse.body);

                                        List<dynamic> dynamicList =
                                            jsonImageResponse['Images'];

                                        List<String> stringList = dynamicList
                                            .map((item) => item.toString())
                                            .toList();

                                        newReview = newReview.copyWith(
                                            images: stringList);
                                      }
                                    } catch (e) {
                                      if (mounted) {
                                        showErrorSnackBar(context,
                                            "No se logró subir imagenes");
                                      }
                                    }
                                    feedBloc.add(AddReview(newReview));
                                    if (mounted) {
                                      Navigator.of(context)
                                        ..pop()
                                        ..pop();
                                    }
                                  } else {
                                    showErrorSnackBar(
                                        context, "No se logró crear la reseña");
                                    Navigator.of(context)
                                      ..pop()
                                      ..pop();
                                  }
                                });
                              }
                            }
                          },
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: const BoxDecoration(
                                color: ColorStyle.lightGrey,
                                shape: BoxShape.circle),
                            child: const Icon(
                              FeatherIcons.arrowRight,
                              color: ColorStyle.midToneGrey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                ),
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.only(top: 16),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
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
                                right: 0,
                                child: Icon(FeatherIcons.moreHorizontal))
                          ],
                        ),
                      ),
                      Container(
                        width: double.maxFinite,
                        height: 0.8,
                        margin: const EdgeInsets.only(top: 12),
                        color: ColorStyle.lightGrey,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _companyListPage(BuildContext context) {
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   FocusScope.of(context).requestFocus(focusNodeSearch);
    // });
    return ConstrainedBox(
      constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.54,
          minHeight: MediaQuery.of(context).size.height * 0.2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.only(top: 16),
            width: double.maxFinite,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
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
                            "Elegir empresa",
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Montserrat',
                                fontSize: 15),
                          )),
                      // const Positioned(
                      //     right: 0, child: Icon(FeatherIcons.moreHorizontal))
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
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 96), //51 textfield
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    child: PressTransform(
                      onPressed: () async {
                        setState(() {
                          // showReviewPageNotifier.value = false;
                          // showAddCompanyPage = true;
                        });

                        focusNodeSearch.unfocus();
                        FocusScope.of(context).unfocus();

                        final businessResponse = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AddBusinessScreen()),
                        );

                        if (mounted) {
                          if (businessResponse != null &&
                              businessResponse is Business) {
                            setState(() {
                              showReviewPageNotifier.value = true;
                              selectedCompany = businessResponse;
                            });
                          }

                          FocusScope.of(context).requestFocus(focusNodeReview);
                        }
                      },
                      child: RoundedDotterRectangleBorder(
                          height: 52,
                          width: double.maxFinite,
                          color: ColorStyle.midToneGrey,
                          borderWidth: 1,
                          icon: Container(
                            width: double.maxFinite,
                            height: double.maxFinite,
                            color: Colors.white,
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(FeatherIcons.plusCircle,
                                    color: ColorStyle.midToneGrey),
                                SizedBox(
                                  width: 8,
                                ),
                                Text(
                                  'Agregar Empresa',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: ColorStyle.midToneGrey,
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
                                        decoration: const BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              color: ColorStyle
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
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 14,
                                                          fontFamily:
                                                              'Montserrat'),
                                                    ),
                                                    Text(
                                                      snapshot
                                                          .data![index].city,
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color:
                                                              ColorStyle.grey,
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
                                              decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: ColorStyle.lightGrey),
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

                setState(() {
                  futureSearch = ApiService().getSearch(value);
                });
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

  // Widget _addCompanyPage(BuildContext context) {
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     FocusScope.of(context).requestFocus(focusNodeCompany);
  //   });
  //   return ConstrainedBox(
  //     constraints: BoxConstraints(
  //         maxHeight: MediaQuery.of(context).size.height * 0.54,
  //         minHeight: MediaQuery.of(context).size.height * 0.2),
  //     child: Form(
  //       key: _formKeyBusiness,
  //       child: Stack(
  //         children: [
  //           SingleChildScrollView(
  //             physics: const BouncingScrollPhysics(),
  //             padding: EdgeInsets.only(top: 58),
  //             child: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 CustomDropdown(
  //                   title: 'País *',
  //                   hintText: 'Selecciona un país',
  //                   list: countries.keys.toList(),
  //                   showIcon: true,
  //                   padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
  //                   onSelected: (selected) {
  //                     setState(() {
  //                       selectedCountry = selected;

  //                       // Reseteamos los valores de estado y ciudad al cambiar el país
  //                       selectedState = null;
  //                       selectedCity = null;

  //                       states = countries[selectedCountry]!.keys.toList();
  //                       cities = [];
  //                     });
  //                   },
  //                 ),
  //                 Row(
  //                   children: [
  //                     Expanded(
  //                       child: CustomDropdown(
  //                         title: 'Estado *',
  //                         hintText: 'Seleccionar',
  //                         list: states,
  //                         padding: EdgeInsets.only(left: 24, right: 8),
  //                         onSelected: (selected) {
  //                           setState(() {
  //                             selectedState = selected as String?;
  //                             cities =
  //                                 countries[selectedCountry]![selectedState]!;
  //                           });
  //                         },
  //                       ),
  //                     ),
  //                     Expanded(
  //                       child: CustomDropdown(
  //                         title: 'Ciudad *',
  //                         hintText: 'Seleccionar',
  //                         list: cities,
  //                         padding: EdgeInsets.only(right: 24, left: 8),
  //                         onSelected: (selected) {
  //                           // Aquí puedes manejar la selección de la ciudad si es necesario
  //                         },
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //                 SizedBox(
  //                   height: 8,
  //                 ),
  //                 CustomInput(
  //                   title: 'Proyecto',
  //                   controller: controllerCompanyName,
  //                   focusNode: focusNodeCompany,
  //                 ),
  //                 CustomInput(
  //                   title: 'Empresa desarrolladora',
  //                   controller: controllerEntity,
  //                   focusNode: focusNodeEntity,
  //                 ),
  //                 CustomDropdown(
  //                   title: 'Categoria',
  //                   hintText: 'Seleccionar',
  //                   list: const ['Inmobiliaria', 'Automotriz', 'Restaurantes'],
  //                   padding: EdgeInsets.only(left: 24, right: 8),
  //                   onSelected: (selected) {
  //                     setState(() {
  //                       selecteCategory = selected;
  //                     });
  //                   },
  //                 ),
  //                 PressTransform(
  //                   onPressed: () async {
  //                     if (_formKeyBusiness.currentState!.validate()) {
  //                       final userState = _userBloc.state;
  //                       if (selecteCategory != null &&
  //                           selectedCity != null &&
  //                           selectedCountry != null &&
  //                           selectedState != null) {
  //                         if (userState is UserLoaded) {
  //                           await ApiService()
  //                               .createBusiness(
  //                                   name: controllerCompanyName.text,
  //                                   entity: controllerEntity.text,
  //                                   country: selectedCountry ?? '',
  //                                   state: selectedState ?? '',
  //                                   city: selectedCity ?? '',
  //                                   category: selecteCategory ?? '')
  //                               .then((value) {
  //                             if (value.statusCode == 201) {
  //                               showSuccessSnackBar(context);

  //                               Map<String, dynamic> json =
  //                                   jsonDecode(value.body);

  //                               // Navigator.pop(context);
  //                             } else {
  //                               showErrorSnackBar(
  //                                   context, "No se logró crear la empresa");
  //                               // Navigator.pop(context);
  //                             }
  //                           });
  //                         }
  //                       }
  //                     } else {
  //                       showErrorSnackBar(
  //                           context, "No se logró crear la empresa");
  //                     }
  //                   },
  //                   child: Container(
  //                     width: double.maxFinite,
  //                     height: 56,
  //                     margin:
  //                         EdgeInsets.symmetric(horizontal: 24, vertical: 16),
  //                     alignment: Alignment.center,
  //                     decoration: BoxDecoration(
  //                         borderRadius: BorderRadius.circular(10),
  //                         color: ColorStyle.solidBlue),
  //                     child: Text(
  //                       "Crear",
  //                       style: TextStyle(
  //                           fontWeight: FontWeight.w700,
  //                           fontFamily: 'Montserrat',
  //                           color: Colors.white,
  //                           fontSize: 16),
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //           ClipRRect(
  //             borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
  //             child: Container(
  //               padding: EdgeInsets.only(top: 16),
  //               height: 58,
  //               color: Colors.white,
  //               width: double.maxFinite,
  //               child: Column(
  //                 children: [
  //                   Padding(
  //                     padding: EdgeInsets.symmetric(horizontal: 16),
  //                     child: Stack(
  //                       alignment: AlignmentDirectional.centerStart,
  //                       children: [
  //                         InkWell(
  //                             onTap: () {
  //                               setState(() {
  //                                 showAddCompanyPage = false;
  //                                 // controllerSearch.clear();
  //                               });
  //                             },
  //                             child: const Icon(FeatherIcons.arrowLeft)),
  //                         const Align(
  //                             alignment: Alignment.center,
  //                             child: Text(
  //                               "Agregar entidad",
  //                               style: TextStyle(
  //                                   fontWeight: FontWeight.w600,
  //                                   fontFamily: 'Montserrat',
  //                                   fontSize: 15),
  //                             )),
  //                         const Positioned(
  //                             right: 0,
  //                             child: Icon(FeatherIcons.moreHorizontal))
  //                       ],
  //                     ),
  //                   ),
  //                   SizedBox(
  //                     height: 16,
  //                   ),
  //                   Container(
  //                     height: 0.8,
  //                     width: double.maxFinite,
  //                     color: ColorStyle.borderGrey,
  //                   )
  //                 ],
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
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
    child: Center(
        child: CircularProgressIndicator.adaptive(
      backgroundColor: ColorStyle.grey, // Fondo del indicador
      valueColor: AlwaysStoppedAnimation<Color>(ColorStyle.darkPurple),
    )),
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

class CustomInput extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final FocusNode focusNode;

  const CustomInput(
      {super.key,
      required this.title,
      required this.controller,
      required this.focusNode});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontFamily: "Montserrat",
                color: ColorStyle.textGrey,
                fontSize: 14,
                fontWeight: FontWeight.w400),
          ),
          const SizedBox(
            height: 4,
          ),
          TextFormField(
            controller: controller,
            focusNode: focusNode,
            style: const TextStyle(fontFamily: "Montserrat", fontSize: 14),
            validator: (value) {
              if (value!.isEmpty) {
                return "Por favor rellena los campos";
              }
              return null;
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white, // Color de fondo
              hintText: 'Input*', // Texto de marcador de posición
              contentPadding:
                  const EdgeInsets.only(left: 12, top: 2, bottom: 2), // Relleno
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
                borderSide: const BorderSide(
                  color: ColorStyle.borderGrey,
                  width: 1.0,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
                borderSide: const BorderSide(
                  color: ColorStyle.borderGrey,
                  width: 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
                borderSide: const BorderSide(
                  color: ColorStyle.borderGrey,
                  width: 1.0,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
