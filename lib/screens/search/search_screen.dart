import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:w_app/bloc/user_bloc/user_bloc.dart';
import 'package:w_app/bloc/user_bloc/user_bloc_event.dart';
import 'package:w_app/models/review_model.dart';
import 'package:w_app/repository/user_repository.dart';
import 'package:w_app/screens/home/widgets/review_card.dart';
import 'package:w_app/styles/color_style.dart';
import 'package:w_app/styles/gradient_style.dart';
import 'package:w_app/styles/shadow_style.dart';

class SearchScreen extends StatefulWidget {
  final UserRepository userRepository;

  const SearchScreen(this.userRepository);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  late UserBloc _userBloc;
  TabController? _tabController;
  TextEditingController controllerSearch = TextEditingController();
  FocusNode focusNodeSearch = FocusNode();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // await widget.userRepository.deleteToken();
      _userBloc = BlocProvider.of<UserBloc>(context);
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
            TabBarView(
              controller: _tabController,
              children: [
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(top: 170, bottom: 160),
                  child: Column(
                    children: [
                      Container(
                        height: 256,
                        width: double.maxFinite,
                        padding: EdgeInsets.only(left: 24, bottom: 16),
                        decoration: BoxDecoration(
                            gradient: GradientStyle().grayGradient),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Tendencia en Mexico",
                                        style: TextStyle(
                                            color: ColorStyle().textGrey,
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
                                            color: ColorStyle().textGrey,
                                            fontFamily: 'Montserrat',
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                )),
                      ),
                      Divider(
                        color: ColorStyle().midToneGrey,
                      ),
                      ReviewCardDefault(
                          review: Review(
                              idReview: '',
                              content:
                                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud.',
                              idBusiness: '',
                              idUser: '',
                              nameBusiness: 'Startbucks',
                              namePerson: 'Jairo',
                              entity: 'Alsea',
                              lastName: ''))
                    ],
                  ),
                ),
                Center(child: Text('Contenido de Tendencias')),
                Center(child: Text('Contenido de Noticias')),
                Center(child: Text('Contenido de Empresas')),
              ],
            ),
            Container(
              height: 176,
              width: double.maxFinite,
              decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [ShadowStyle().dropComponentShadow]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 24, top: 56, bottom: 8),
                    child: Text(
                      "Buscar",
                      style: TextStyle(
                          fontSize: 22,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  Container(
                    height: 40,
                    width: double.maxFinite,
                    margin: EdgeInsets.only(left: 24, right: 24, bottom: 16),
                    decoration: BoxDecoration(
                        color: Color.fromRGBO(118, 118, 118, 0.12),
                        borderRadius: BorderRadius.circular(8)),
                    child: TextField(
                      controller: controllerSearch,
                      maxLines: null,
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
                            color: ColorStyle().textGrey),
                        contentPadding: const EdgeInsets.only(),
                        border: const OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        prefixIcon: Icon(FeatherIcons.search,
                            size: 20, color: ColorStyle().textGrey),
                        suffixIcon: IconButton(
                          onPressed: () {
                            controllerSearch.clear();
                          },
                          icon: Icon(Icons.clear,
                              size: 20, color: ColorStyle().textGrey),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          // searchTerm =
                          //     value; // <-- Actualiza el término de búsqueda cada vez que cambia el valor
                          if (value.length >= 3) {
                            setState(() {
                              // futureSearch = ApiService().getSearch(value);
                            });
                          }
                        } else {
                          setState(() {
                            // futureSearch = ApiService().getSearch(value);
                          });
                        }
                      },
                    ),
                  ),
                  Expanded(
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
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
