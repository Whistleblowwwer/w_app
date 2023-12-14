import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_svg/svg.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:w_app/bloc/search_bloc/search_bloc.dart';
import 'package:w_app/bloc/search_bloc/search_event.dart';
import 'package:w_app/bloc/search_bloc/search_state.dart';
import 'package:w_app/bloc/user_bloc/user_bloc.dart';
import 'package:w_app/bloc/user_bloc/user_bloc_event.dart';
import 'package:w_app/models/company_model.dart';
import 'package:w_app/models/review_model.dart';
import 'package:w_app/models/user.dart';
import 'package:w_app/repository/user_repository.dart';
import 'package:w_app/screens/add/add_business_screen.dart';
import 'package:w_app/screens/business_screen.dart';
import 'package:w_app/screens/home/widgets/review_card.dart';
import 'package:w_app/screens/profile/foreign_profile_screen.dart';
import 'package:w_app/services/api/api_service.dart';
import 'package:w_app/styles/color_style.dart';
import 'package:w_app/styles/gradient_style.dart';
import 'package:w_app/styles/shadow_style.dart';
import 'package:w_app/widgets/circularAvatar.dart';
import 'package:w_app/widgets/dotters.dart';
import 'package:w_app/widgets/press_transform_widget.dart';
import 'package:w_app/widgets/snackbar.dart';

class SearchScreen extends StatefulWidget {
  final UserRepository userRepository;

  const SearchScreen(this.userRepository);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with TickerProviderStateMixin {
  late UserBloc _userBloc;
  late SearchBloc _searchBloc;
  TabController? _tabController;
  TabController? _tabControllerSearched;
  TextEditingController controllerSearch = TextEditingController();
  FocusNode focusNodeSearch = FocusNode();
  late Future<List<Business>> futureSearch;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabControllerSearched = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // await widget.userRepository.deleteToken();
      _userBloc = BlocProvider.of<UserBloc>(context);
      _searchBloc = BlocProvider.of<SearchBloc>(context);
      controllerSearch.addListener(() {
        setState(() {
          print(controllerSearch.text);
          // try {
          futureSearch = ApiService().getSearch(controllerSearch.text);
          // } catch (e) {}
        });
      });

      // _fetchUserProfile();
    });
  }

  UnderlineTabIndicator _customUnderlineIndicator() {
    return UnderlineTabIndicator(
      borderSide: BorderSide(
          width: 3.0, color: Colors.purple), // Grosor y color del indicador
      borderRadius: BorderRadius.circular(2),
      insets: EdgeInsets.fromLTRB(8.0, 0.0, 8.0,
          0.0), // Ajusta el espacio a los lados y debajo del texto
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.maxFinite,
        width: double.maxFinite,
        child: Stack(
          children: [
            BlocBuilder<SearchBloc, SearchState>(builder: (context, state) {
              if (state is SearchEmpty) {
                return TabBarView(
                  controller: _tabController,
                  children: [
                    ForYouScreen(),
                    Center(child: Text('Contenido de Tendencias')),
                    NoticeScreen(),
                    Center(child: Text('Contenido de Empresas')),
                  ],
                );
              } else if (state is Searching) {
                return SingleChildScrollView(
                  physics: BouncingScrollPhysics(), //ClampingScrollPhysics(),
                  padding: EdgeInsets.only(bottom: 600, top: 200),
                  child: Column(
                    children: [
                      Container(
                        width: double.maxFinite,
                        decoration: BoxDecoration(
                            // color: Colors.white,
                            ),
                        child: Column(
                          children: List.generate(
                              state.lastSearchs.length >= 4
                                  ? 4
                                  : state.lastSearchs.length,
                              (index) => PressTransform(
                                    onPressed: () {
                                      _searchBloc.add(SearchCompleted(
                                          state.lastSearchs[index]));
                                    },
                                    child: Container(
                                      height: 48,
                                      width: double.maxFinite,
                                      padding:
                                          EdgeInsets.only(left: 16, right: 24),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              state.lastSearchs[index],
                                              style: TextStyle(
                                                  fontFamily: 'Montserrat',
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                          ),
                                          Icon(
                                            FeatherIcons.arrowUpLeft,
                                            size: 18,
                                            color: ColorStyle.darkPurple,
                                          )
                                        ],
                                      ),
                                    ),
                                  )),
                        ),
                      ),
                      Divider(
                        color: ColorStyle.borderGrey, // Color del borde.
                        height: 0.5,
                      ),
                      FutureBuilder(
                          future: futureSearch,
                          builder: (context,
                              AsyncSnapshot<List<Business>> snapshot) {
                            if (snapshot.hasError) {
                              return Padding(
                                  padding: EdgeInsets.only(
                                      top: 224 +
                                          min(192,
                                              state.lastSearchs.length * 48),
                                      left: 24,
                                      right: 24),
                                  child: Center(
                                    child: Text(
                                      'Al parecer hubo un error: \n"${snapshot.error}"',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          color: ColorStyle.textGrey,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16),
                                    ),
                                  ));
                            } else if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return Padding(
                                padding: EdgeInsets.only(
                                    top: 32, left: 24, right: 24),
                                child: PressTransform(
                                  onPressed: () {
                                    setState(() {});
                                  },
                                  child: PressTransform(
                                    onPressed: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const AddBusinessScreen()),
                                      );
                                    },
                                    child: RoundedDotterRectangleBorder(
                                        height: 52,
                                        width: double.maxFinite,
                                        color: ColorStyle.darkPurple,
                                        borderWidth: 1,
                                        icon: Container(
                                          width: double.maxFinite,
                                          height: double.maxFinite,
                                          child: const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                FeatherIcons.plusCircle,
                                                color: ColorStyle.darkPurple,
                                              ),
                                              SizedBox(
                                                width: 8,
                                              ),
                                              Text(
                                                'Agregar Empresa',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color:
                                                        ColorStyle.darkPurple,
                                                    fontSize: 14,
                                                    fontFamily: 'Montserrat'),
                                              ),
                                            ],
                                          ),
                                        )),
                                  ),
                                ),
                              );
                            } else {
                              return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: List.generate(
                                    snapshot.data!.length + 1,
                                    (index) => GestureDetector(
                                        onTap: () {
                                          setState(() {});
                                          ApiService()
                                              .getBusinessDetail(snapshot
                                                  .data![index].idBusiness)
                                              .then((value) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      BusinessScreen(
                                                        business: value,
                                                      )),
                                            );
                                          }, onError: (e) {
                                            showErrorSnackBar(
                                                context, e.toString());
                                          });
                                          // Aquí puedes agregar lógica adicional si es necesario, por ejemplo, para manejar la selección de la empresa
                                        },
                                        child: index < snapshot.data!.length
                                            ? Container(
                                                width: double.maxFinite,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 16,
                                                        horizontal: 16),
                                                decoration: BoxDecoration(),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    // const CircularAvatarW(
                                                    //   externalRadius: Offset(42, 42),
                                                    //   internalRadius: Offset(36, 36),
                                                    //   nameAvatar: "S",
                                                    //   isCompany: true,
                                                    // ),
                                                    // const SizedBox(
                                                    //   width: 16,
                                                    // ),
                                                    Flexible(
                                                      child: SizedBox(
                                                        width: double.maxFinite,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Text(
                                                              snapshot
                                                                  .data![index]
                                                                  .name,
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize: 14,
                                                                  fontFamily:
                                                                      'Montserrat'),
                                                            ),
                                                            Text(
                                                              '${snapshot.data![index].entity} • ${snapshot.data![index].city}',
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  color:
                                                                      ColorStyle
                                                                          .grey,
                                                                  fontSize: 12,
                                                                  fontFamily:
                                                                      'Montserrat'),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8),
                                                      alignment:
                                                          Alignment.center,
                                                      decoration: BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: ColorStyle
                                                              .lightGrey),
                                                      child: SvgPicture.asset(
                                                        'assets/images/icons/WhistleActive.svg',
                                                        width: 24,
                                                        height: 20,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              )
                                            : Padding(
                                                padding: EdgeInsets.only(
                                                    top: 32,
                                                    left: 24,
                                                    right: 24),
                                                child: PressTransform(
                                                  onPressed: () {
                                                    setState(() {});
                                                  },
                                                  child: PressTransform(
                                                    onPressed: () async {
                                                      await Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                const AddBusinessScreen()),
                                                      );
                                                    },
                                                    child:
                                                        RoundedDotterRectangleBorder(
                                                            height: 52,
                                                            width: double
                                                                .maxFinite,
                                                            color: ColorStyle
                                                                .darkPurple,
                                                            borderWidth: 1,
                                                            icon: Container(
                                                              width: double
                                                                  .maxFinite,
                                                              height: double
                                                                  .maxFinite,
                                                              child: const Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Icon(
                                                                    FeatherIcons
                                                                        .plusCircle,
                                                                    color: ColorStyle
                                                                        .darkPurple,
                                                                  ),
                                                                  SizedBox(
                                                                    width: 8,
                                                                  ),
                                                                  Text(
                                                                    'Agregar Empresa',
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w600,
                                                                        color: ColorStyle
                                                                            .darkPurple,
                                                                        fontSize:
                                                                            14,
                                                                        fontFamily:
                                                                            'Montserrat'),
                                                                  ),
                                                                ],
                                                              ),
                                                            )),
                                                  ),
                                                ),
                                              )),
                                  ));
                            }
                          }),
                    ],
                  ),
                );
              } else if (state is Searched) {
                return TabBarView(
                  controller: _tabControllerSearched,
                  children: [
                    FutureBuilder(
                        future: ApiService().getSearch(state.searchSelection),
                        builder:
                            (context, AsyncSnapshot<List<Business>> snapshot) {
                          if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                'Al parecer hubo un error: \n"${snapshot.error}"',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    color: ColorStyle.textGrey,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16),
                              ),
                            );
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'No encontramos un proyecto, empresa o sucursal que se llame "${state.searchSelection}"',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        color: ColorStyle.textGrey,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16),
                                  ),
                                  SizedBox(
                                    height: 24,
                                  ),
                                  PressTransform(
                                    onPressed: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const AddBusinessScreen()),
                                      );
                                    },
                                    child: RoundedDotterRectangleBorder(
                                        height: 52,
                                        width: double.maxFinite,
                                        color: ColorStyle.darkPurple,
                                        borderWidth: 1,
                                        icon: Container(
                                          width: double.maxFinite,
                                          height: double.maxFinite,
                                          color: Colors.white,
                                          child: const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                FeatherIcons.plusCircle,
                                                color: ColorStyle.darkPurple,
                                              ),
                                              SizedBox(
                                                width: 8,
                                              ),
                                              Text(
                                                'Agregar Empresa',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color:
                                                        ColorStyle.darkPurple,
                                                    fontSize: 14,
                                                    fontFamily: 'Montserrat'),
                                              ),
                                            ],
                                          ),
                                        )),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            return SingleChildScrollView(
                              padding: EdgeInsets.only(top: 184),
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: List.generate(
                                    snapshot.data!.length + 1,
                                    (index) => GestureDetector(
                                        onTap: () {
                                          setState(() {});
                                          ApiService()
                                              .getBusinessDetail(snapshot
                                                  .data![index].idBusiness)
                                              .then((value) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      BusinessScreen(
                                                        business: value,
                                                      )),
                                            );
                                          }, onError: (e) {
                                            showErrorSnackBar(
                                                context, e.toString());
                                          });
                                          // Aquí puedes agregar lógica adicional si es necesario, por ejemplo, para manejar la selección de la empresa
                                        },
                                        child: index < snapshot.data!.length
                                            ? Container(
                                                width: double.maxFinite,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 16,
                                                        horizontal: 16),
                                                decoration: BoxDecoration(),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Flexible(
                                                      child: SizedBox(
                                                        width: double.maxFinite,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Text(
                                                              snapshot
                                                                  .data![index]
                                                                  .name,
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize: 14,
                                                                  fontFamily:
                                                                      'Montserrat'),
                                                            ),
                                                            Text(
                                                              '${snapshot.data![index].entity} • ${snapshot.data![index].city}',
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  color:
                                                                      ColorStyle
                                                                          .grey,
                                                                  fontSize: 12,
                                                                  fontFamily:
                                                                      'Montserrat'),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8),
                                                      alignment:
                                                          Alignment.center,
                                                      decoration: BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: ColorStyle
                                                              .lightGrey),
                                                      child: SvgPicture.asset(
                                                        'assets/images/icons/WhistleActive.svg',
                                                        width: 24,
                                                        height: 20,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              )
                                            : Padding(
                                                padding: EdgeInsets.only(
                                                    top: 32,
                                                    left: 24,
                                                    right: 24),
                                                child: PressTransform(
                                                  onPressed: () {
                                                    setState(() {});
                                                  },
                                                  child: PressTransform(
                                                    onPressed: () async {
                                                      await Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                const AddBusinessScreen()),
                                                      );
                                                    },
                                                    child:
                                                        RoundedDotterRectangleBorder(
                                                            height: 52,
                                                            width: double
                                                                .maxFinite,
                                                            color: ColorStyle
                                                                .darkPurple,
                                                            borderWidth: 1,
                                                            icon: Container(
                                                              width: double
                                                                  .maxFinite,
                                                              height: double
                                                                  .maxFinite,
                                                              color:
                                                                  Colors.white,
                                                              child: const Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Icon(
                                                                    FeatherIcons
                                                                        .plusCircle,
                                                                    color: ColorStyle
                                                                        .darkPurple,
                                                                  ),
                                                                  SizedBox(
                                                                    width: 8,
                                                                  ),
                                                                  Text(
                                                                    'Agregar Empresa',
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w600,
                                                                        color: ColorStyle
                                                                            .darkPurple,
                                                                        fontSize:
                                                                            14,
                                                                        fontFamily:
                                                                            'Montserrat'),
                                                                  ),
                                                                ],
                                                              ),
                                                            )),
                                                  ),
                                                ),
                                              )),
                                  )),
                            );
                          }
                        }),
                    FutureBuilder(
                        future:
                            ApiService().getSearchUsers(state.searchSelection),
                        builder: (context, AsyncSnapshot<List<User>> snapshot) {
                          if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                'Al parecer hubo un error: \n"${snapshot.error}"',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    color: ColorStyle.textGrey,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16),
                              ),
                            );
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return Center(
                              child: Text(
                                'No encontramos a nadie\nque se llame "${state.searchSelection}"',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    color: ColorStyle.textGrey,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16),
                              ),
                            );
                          } else {
                            return SingleChildScrollView(
                                padding: EdgeInsets.only(top: 184, bottom: 112),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: List.generate(
                                      snapshot.data!.length,
                                      (index) => GestureDetector(
                                          onTap: () async {
                                            await ApiService()
                                                .getProfileDetail(snapshot
                                                        .data?[index].idUser ??
                                                    '')
                                                .then((value) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ForeignProfileScreen(
                                                            value)),
                                              );
                                            }, onError: (e) {
                                              showErrorSnackBar(
                                                  context, e.toString());
                                            });
                                          },
                                          child: Container(
                                            width: double.maxFinite,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 16, horizontal: 16),
                                            decoration: BoxDecoration(),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                CircularAvatarW(
                                                  externalRadius:
                                                      Offset(38, 38),
                                                  internalRadius:
                                                      Offset(34, 34),
                                                  nameAvatar:
                                                      '${snapshot.data![index].name.substring(0, 1).toUpperCase()}${snapshot.data![index].lastName.substring(0, 1).toUpperCase()}',
                                                  isCompany: false,
                                                  sizeText: 16,
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Flexible(
                                                  child: SizedBox(
                                                    width: double.maxFinite,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          '${snapshot.data![index].name} ${snapshot.data![index].lastName}',
                                                          style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  'Montserrat'),
                                                        ),
                                                        Text(
                                                          '@${snapshot.data![index].userName!.isEmpty ? 'User$index' : snapshot.data![index].userName!}',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              color: ColorStyle
                                                                  .grey,
                                                              fontSize: 13,
                                                              fontFamily:
                                                                  'Montserrat'),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ))),
                                ));
                          }
                        }),
                  ],
                );
              } else {
                return SizedBox.shrink();
              }
            }),
            BlocBuilder<SearchBloc, SearchState>(
              builder: (context, state) {
                return Container(
                  height:
                      state is SearchEmpty || state is Searched ? 176 : null,
                  width: double.maxFinite,
                  padding: EdgeInsets.only(top: 56),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [ShadowStyle().dropComponentShadow]),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedPadding(
                        duration: Duration(milliseconds: 100),
                        padding: EdgeInsets.only(left: 24, bottom: 8),
                        child: Row(
                          children: [
                            Visibility(
                              visible: state is Searching,
                              child: PressTransform(
                                  onPressed: () {
                                    setState(() {
                                      controllerSearch.text = '';
                                      _searchBloc.add(SearchTextChanged(
                                          controllerSearch.text));
                                    });
                                  },
                                  child: Icon(FeatherIcons.x)),
                            ),
                            AnimatedPadding(
                              duration: Duration(milliseconds: 100),
                              padding: EdgeInsets.only(
                                  left: state is Searching ? 8 : 0),
                              child: Text(
                                "Buscar",
                                style: TextStyle(
                                    fontSize: 22,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 40,
                        width: double.maxFinite,
                        margin:
                            EdgeInsets.only(left: 24, right: 24, bottom: 16),
                        decoration: BoxDecoration(
                            color: Color.fromRGBO(118, 118, 118, 0.12),
                            borderRadius: BorderRadius.circular(8)),
                        child: TextField(
                          controller: controllerSearch,
                          maxLines: 1,
                          focusNode: focusNodeSearch,
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Buscar por establecimiento/persona',
                            hintStyle: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: ColorStyle.textGrey),
                            contentPadding: const EdgeInsets.only(),
                            border: const OutlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                            prefixIcon: Icon(FeatherIcons.search,
                                size: 18, color: ColorStyle.textGrey),
                            // suffixIcon: controllerSearch.text.isNotEmpty
                            //     ? IconButton(
                            //         onPressed: () {
                            //           controllerSearch.clear();
                            //           _searchBloc
                            //               .add(const SearchTextChanged(''));
                            //         },
                            //         icon: Icon(Icons.clear,
                            //             size: 20, color: ColorStyle.textGrey),
                            //       )
                            //     : null,
                          ),
                          onChanged: (value) {
                            _searchBloc.add(SearchTextChanged(value));
                          },
                        ),
                      ),
                      Visibility(
                        visible: state is SearchEmpty,
                        child: Expanded(
                          child: TabBar(
                            controller: _tabController,
                            labelColor: Colors.black,
                            isScrollable: true,
                            physics: BouncingScrollPhysics(),
                            padding: EdgeInsets.only(left: 24),
                            unselectedLabelColor: Colors.grey,
                            indicator: _customUnderlineIndicator(),
                            indicatorColor: Colors.purple,
                            indicatorWeight: 4.0,
                            labelStyle: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w600),
                            tabs: [
                              Tab(text: 'Para ti'),
                              Tab(text: 'Tendencias'),
                              Tab(text: 'Noticias'),
                              Tab(text: 'Empresas'),
                            ],
                          ),
                        ),
                      ),
                      Visibility(
                        visible: state is Searched,
                        child: Expanded(
                          child: TabBar(
                            controller: _tabControllerSearched,
                            labelColor: Colors.black,
                            isScrollable: true,
                            physics: BouncingScrollPhysics(),
                            padding: EdgeInsets.only(left: 24),
                            unselectedLabelColor: Colors.grey,
                            indicator: _customUnderlineIndicator(),
                            indicatorColor: Colors.purple,
                            indicatorWeight: 4.0,
                            labelStyle: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w600),
                            tabs: [
                              Tab(text: 'Empresas'),
                              Tab(text: 'Personas'),
                            ],
                          ),
                        ),
                      ),
                      state is Searching
                          ? PressTransform(
                              onPressed: () {
                                _searchBloc.add(
                                    SearchCompleted(controllerSearch.text));
                              },
                              child: Container(
                                width: double.maxFinite,
                                padding: EdgeInsets.only(
                                    left: 32, bottom: 8, top: 8),
                                margin: EdgeInsets.only(),
                                child: Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Icon(
                                          FeatherIcons.search,
                                          color: ColorStyle.textGrey,
                                          size: 20,
                                        ),
                                        SizedBox(
                                          width: 16,
                                        ),
                                        Expanded(
                                          child: Text(
                                            'Buscar "${controllerSearch.text}"',
                                            style: TextStyle(
                                                fontFamily: 'Montserrat',
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                        Icon(
                                          FeatherIcons.chevronRight,
                                          color: ColorStyle.textGrey,
                                          size: 20,
                                        ),
                                        SizedBox(
                                          width: 24,
                                        ),
                                      ],
                                    ),
                                    Container(
                                      height: 0.5,
                                      width: double.maxFinite,
                                      color: ColorStyle.borderGrey,
                                      margin:
                                          EdgeInsets.only(left: 32, top: 16),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : SizedBox.shrink()
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class NoticeScreen extends StatelessWidget {
  const NoticeScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(top: 170, bottom: 160),
      child: Column(
        children: [
          Container(
            height: 256,
            width: double.maxFinite,
            padding: EdgeInsets.only(left: 24, bottom: 16),
            decoration: BoxDecoration(gradient: GradientStyle().grayGradient),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text("Encabezado",
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Montserrat',
                            fontSize: 14,
                            fontWeight: FontWeight.w500)),
                    SizedBox(
                      height: 4,
                    ),
                    Text(
                      "Noticia Principal",
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Montserrat',
                          fontSize: 26,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                )
              ],
            ),
          ),
          SizedBox(
            height: 16,
          ),
          Column(
            children: List.generate(
                3,
                (index) => Container(
                      margin: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 102,
                            width: double.maxFinite,
                            padding: EdgeInsets.only(left: 24, bottom: 16),
                            margin: EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                                color: ColorStyle.borderGrey,
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          Text(
                            "Titulo increible",
                            style: TextStyle(
                                color: Colors.black,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w600,
                                fontSize: 14),
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          Text(
                            "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                            style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 14,
                                fontWeight: FontWeight.w400),
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              "Nov 17. 2023",
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  color: ColorStyle.textGrey,
                                  fontFamily: 'Montserrat',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    )),
          ),
        ],
      ),
    );
  }
}

class ForYouScreen extends StatelessWidget {
  const ForYouScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(top: 170, bottom: 160),
      child: Column(
        children: [
          Container(
            height: 256,
            width: double.maxFinite,
            padding: EdgeInsets.only(left: 24, bottom: 16),
            decoration: BoxDecoration(
                // gradient: GradientStyle().grayGradient,
                image: DecorationImage(
                    image: AssetImage(
                        'assets/images/ilustrations/Banner 1 - W.jpg'))),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text("Encabezado",
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Montserrat',
                            fontSize: 14,
                            fontWeight: FontWeight.w500)),
                    SizedBox(
                      height: 4,
                    ),
                    Text(
                      "Publicidad",
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Montserrat',
                          fontSize: 26,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                )
              ],
            ),
          ),
          Column(
            children: List.generate(
                3,
                (index) => Container(
                      margin: EdgeInsets.symmetric(horizontal: 24),
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Tendencia en Mexico",
                            style: TextStyle(
                                color: ColorStyle.textGrey,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w500),
                          ),
                          SizedBox(
                            height: 6,
                          ),
                          Text(
                            "Estafadores!!! No cumplen sus políticas, son unos corruptos.",
                            style: TextStyle(
                                color: Colors.black,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w600,
                                fontSize: 16),
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          Text(
                            "2342 Me gusta • 200 comentarios",
                            style: TextStyle(
                                color: ColorStyle.textGrey,
                                fontFamily: 'Montserrat',
                                fontSize: 12,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    )),
          ),
          Divider(
            color: ColorStyle.midToneGrey,
          ),
          ReviewCardDefault(
              review: Review(
                  idReview: '',
                  content:
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud.',
                  likes: 2,
                  rating: 2.5,
                  isLiked: true,
                  isValid: true,
                  createdAt: null,
                  updatedAt: null,
                  comments: 4,
                  business: BusinessData(
                      idBusiness: '',
                      name: 'Starbucks',
                      entity: 'Alsea',
                      rating: 4,
                      followed: true),
                  user: UserData(
                      idUser: '',
                      name: 'Harold',
                      lastName: 'Lancheros',
                      followed: true)))
        ],
      ),
    );
  }
}
