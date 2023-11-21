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
import 'package:w_app/repository/user_repository.dart';
import 'package:w_app/screens/home/widgets/review_card.dart';
import 'package:w_app/services/api/api_service.dart';
import 'package:w_app/styles/color_style.dart';
import 'package:w_app/styles/gradient_style.dart';
import 'package:w_app/styles/shadow_style.dart';
import 'package:w_app/widgets/circularAvatar.dart';
import 'package:w_app/widgets/press_transform_widget.dart';

class SearchScreen extends StatefulWidget {
  final UserRepository userRepository;

  const SearchScreen(this.userRepository);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  late UserBloc _userBloc;
  late SearchBloc _searchBloc;
  TabController? _tabController;
  TextEditingController controllerSearch = TextEditingController();
  FocusNode focusNodeSearch = FocusNode();
  late Future<List<Business>> futureSearch;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // await widget.userRepository.deleteToken();
      _userBloc = BlocProvider.of<UserBloc>(context);
      _searchBloc = BlocProvider.of<SearchBloc>(context);
      controllerSearch.addListener(() {
        setState(() {
          print(controllerSearch.text);
          futureSearch = ApiService().getSearch(controllerSearch.text);
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
              return state is SearchEmpty
                  ? TabBarView(
                      controller: _tabController,
                      children: [
                        ForYouScreen(),
                        Center(child: Text('Contenido de Tendencias')),
                        NoticeScreen(),
                        Center(child: Text('Contenido de Empresas')),
                      ],
                    )
                  : state is Searching
                      ? FutureBuilder(
                          future: futureSearch,
                          builder: (context,
                              AsyncSnapshot<List<Business>> snapshot) {
                            if (snapshot.hasError) {
                              return Container();
                            } else if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return Container();
                            } else {
                              return SingleChildScrollView(
                                padding: EdgeInsets.only(
                                    top: 200 +
                                        min(192,
                                            state.lastSearchs.length * 48)),
                                physics: BouncingScrollPhysics(),
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: List.generate(
                                      snapshot.data!.length,
                                      (index) => GestureDetector(
                                        onTap: () {
                                          setState(() {});

                                          // Aquí puedes agregar lógica adicional si es necesario, por ejemplo, para manejar la selección de la empresa
                                        },
                                        child: Container(
                                          width: double.maxFinite,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16, horizontal: 16),
                                          decoration: BoxDecoration(
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
                                                padding:
                                                    const EdgeInsets.all(8),
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color:
                                                        ColorStyle.lightGrey),
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
                                    )),
                              );
                            }
                          })
                      : SizedBox.shrink();
            }),
            BlocBuilder<SearchBloc, SearchState>(
              builder: (context, state) {
                return Container(
                  height: state is SearchEmpty ? 176 : null,
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
                            // suffixIcon: IconButton(
                            //   onPressed: () {
                            //     controllerSearch.clear();
                            //   },
                            //   icon: Icon(Icons.clear,
                            //       size: 20, color: ColorStyle.textGrey),
                            // ),
                          ),
                          onChanged: (value) {
                            _searchBloc.add(SearchTextChanged(value));
                            // if (value.isNotEmpty) {

                            //   // searchTerm =
                            //   //     value; // <-- Actualiza el término de búsqueda cada vez que cambia el valor
                            // } else {
                            //   setState(() {
                            //     // futureSearch = ApiService().getSearch(value);
                            //   });
                            // }
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
                      state is Searching
                          ? Column(
                              children: [
                                Container(
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

                                Column(
                                  children: List.generate(
                                      state.lastSearchs.length >= 4
                                          ? 4
                                          : state.lastSearchs.length,
                                      (index) => Container(
                                            height: 48,
                                            width: double.maxFinite,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 24),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    state.lastSearchs[index],
                                                    style: TextStyle(
                                                        fontFamily:
                                                            'Montserrat',
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w400),
                                                  ),
                                                ),
                                                Icon(
                                                  FeatherIcons.arrowUpLeft,
                                                  size: 18,
                                                  color: ColorStyle.darkPurple,
                                                )
                                              ],
                                            ),
                                          )),
                                )
                                // FutureBuilder(
                                //     future: null,
                                //     builder: (context, snapshot) {
                                //       switch (snapshot.connectionState) {
                                //         case ConnectionState.waiting:
                                //           return Container();
                                //         case ConnectionState.done:
                                //           if (snapshot.hasError) {
                                //             return Container();
                                //           } else if (!snapshot.hasData ||
                                //               snapshot.data!.isEmpty) {
                                //             return Container();
                                //           } else {
                                //             return Column(
                                //               children: List.generate(
                                //                   8,
                                //                   (index) => ListTile(
                                //                         title: Text('Starbucks'),
                                //                       )),
                                //             );
                                //           }
                                //         default:
                                //           return Container(); // Otros estados no esperados
                                //       }
                                //     }),
                              ],
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
            decoration: BoxDecoration(gradient: GradientStyle().grayGradient),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text("Encabeza",
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
                  idBusiness: '',
                  idUser: '',
                  likes: 2,
                  isLiked: true,
                  isValid: true,
                  createdAt: null,
                  updatedAt: null,
                  comments: 4,
                  business: BusinessData(
                      idBusiness: '',
                      name: 'Starbucks',
                      entity: 'Alsea',
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
