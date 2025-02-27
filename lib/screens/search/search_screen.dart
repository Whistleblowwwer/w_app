import 'dart:math';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_svg/svg.dart';
import 'package:w_app/bloc/search_bloc/search_bloc.dart';
import 'package:w_app/bloc/search_bloc/search_event.dart';
import 'package:w_app/bloc/search_bloc/search_state.dart';
import 'package:w_app/bloc/user_bloc/user_bloc.dart';
import 'package:w_app/bloc/user_bloc/user_bloc_state.dart';
import 'package:w_app/models/article_model.dart';
import 'package:w_app/models/banner_model.dart';
import 'package:w_app/models/company_model.dart';
import 'package:w_app/models/user.dart';
import 'package:w_app/repository/user_repository.dart';
import 'package:w_app/screens/add/add_business_screen.dart';
import 'package:w_app/screens/add/add_review.dart';
import 'package:w_app/screens/business_screen.dart';
import 'package:w_app/screens/profile/foreign_profile_screen.dart';
import 'package:w_app/screens/search/notice_detail_screen.dart';
import 'package:w_app/screens/search/trending_screen.dart';
import 'package:w_app/services/api/api_service.dart';
import 'package:w_app/styles/color_style.dart';
import 'package:w_app/styles/gradient_style.dart';
import 'package:w_app/styles/shadow_style.dart';
import 'package:w_app/widgets/business_card.dart';
import 'package:w_app/widgets/circularAvatar.dart';
import 'package:w_app/widgets/dotters.dart';
import 'package:w_app/widgets/press_transform_widget.dart';
import 'package:w_app/widgets/snackbar.dart';

class SearchScreen extends StatefulWidget {
  final UserRepository userRepository;

  const SearchScreen(this.userRepository);

  @override
  SearchScreenState createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin<SearchScreen> {
  @override
  bool get wantKeepAlive => true;

  late SearchBloc _searchBloc;
  TabController? _tabController;
  TabController? _tabControllerSearched;
  TextEditingController controllerSearch = TextEditingController();
  FocusNode focusNodeSearch = FocusNode();
  late Future<List<Business>> futureSearch;

  bool isLoading = true;
  List<Business> businesses = [];
  List<Article> articles = [];
  bool isLoadingArticles = true;
  List<BannerModel> banners = [];
  //Notices
  int currentPage = 0;
  final PageController _boardController =
      PageController(initialPage: 0, viewportFraction: 1);
  AnimatedContainer doIndicator(index) {
    return AnimatedContainer(
      margin: const EdgeInsets.only(right: 4, left: 4),
      duration: const Duration(milliseconds: 300),
      height: 2,
      width: currentPage == index ? 12 : 10,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: currentPage == index
            ? ColorStyle.darkPurple.withOpacity(0.8)
            : Colors.grey.withOpacity(0.5),
      ),
    );
  }

  List<BannerModel> noticeImages = [
    // 'assets/images/ilustrations/banner_startup1.jpg',
    // 'assets/images/ilustrations/banner_startup2.jpg',
  ];

  //For You
  int currentPageForYou = 0;
  final PageController _boardControllerForYou =
      PageController(initialPage: 0, viewportFraction: 1);
  AnimatedContainer doIndicatorForYou(index) {
    return AnimatedContainer(
      margin: const EdgeInsets.only(right: 4, left: 4),
      duration: const Duration(milliseconds: 300),
      height: 2,
      width: currentPageForYou == index ? 12 : 10,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: currentPageForYou == index
            ? ColorStyle.darkPurple.withOpacity(0.8)
            : Colors.grey.withOpacity(0.5),
      ),
    );
  }

  List<BannerModel> imagesForYou = [
    // 'assets/images/ilustrations/banner_how1.jpg',
    // 'assets/images/ilustrations/banner_how2.jpg',
    // 'assets/images/ilustrations/banner_how3.jpg',
    // 'assets/images/ilustrations/banner_how4.jpg',
    // 'assets/images/ilustrations/banner_how5.jpg',
  ];

  List<BannerModel> trendingImages = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabControllerSearched = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // await widget.userRepository.deleteToken();
      _searchBloc = BlocProvider.of<SearchBloc>(context);
      controllerSearch.addListener(() {
        setState(() {
          // try {
          futureSearch = ApiService().getSearch(controllerSearch.text);
          // } catch (e) {}
        });
      });

      loadBusiness();
      loadArticles();
      loadBanners();

      // _fetchUserProfile();
    });
  }

  Future<void> loadBusiness() async {
    try {
      final businessList = await ApiService().getAllBusiness();
      print(businessList);
      print("ssaaa");

      if (mounted) {
        setState(() {
          businesses = businessList;
          isLoading = false;
        });
      }
    } catch (e) {
      // Handle the error or set state to show an error message
      if (mounted) {
        showErrorSnackBar(context, e.toString());
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> loadBanners() async {
    try {
      // Suponiendo que getBanners() devuelve Map<String, List<BannerModel>>
      Map<String, List<BannerModel>> bannersBySection =
          await ApiService().getBanners();

      // Separando las secciones en listas individuales
      List<BannerModel> fyBanners = bannersBySection['FY'] ?? [];
      List<BannerModel> tdBanners = bannersBySection['TD'] ?? [];
      List<BannerModel> nwBanners = bannersBySection['NW'] ?? [];

      // Ahora puedes trabajar con las listas fyBanners, tdBanners, y nwBanners individualmente
      // Por ejemplo, imprimir los títulos de los banners de la sección FY
      fyBanners.sort((a, b) => a.indexPosition.compareTo(b.indexPosition));
      nwBanners.sort((a, b) => a.indexPosition.compareTo(b.indexPosition));
      tdBanners.sort((a, b) => a.indexPosition.compareTo(b.indexPosition));
      setState(() {
        imagesForYou = fyBanners;
        noticeImages = nwBanners;
        trendingImages = tdBanners;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> loadArticles() async {
    try {
      final articleList = await ApiService().getArticles();

      if (mounted) {
        setState(() {
          articles = articleList;
          isLoadingArticles = false;
        });
      }
    } catch (e) {
      // Handle the error or set state to show an error message
      if (mounted) {
        showErrorSnackBar(context, e.toString());
        setState(() {
          isLoadingArticles = false;
        });
      }
    }
  }

  UnderlineTabIndicator _customUnderlineIndicator() {
    return UnderlineTabIndicator(
      borderSide: const BorderSide(
          width: 3.0, color: Colors.purple), // Grosor y color del indicador
      borderRadius: BorderRadius.circular(2),
      insets: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0,
          0.0), // Ajusta el espacio a los lados y debajo del texto
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: SizedBox(
        height: double.maxFinite,
        width: double.maxFinite,
        child: Stack(
          children: [
            BlocBuilder<SearchBloc, SearchState>(builder: (context, state) {
              if (state is SearchEmpty) {
                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildForYou(),
                    _buisinessScreen(),
                    _noticeScreen(),
                    TrendingScreen(
                      banners: trendingImages,
                    )
                  ],
                );
              } else if (state is Searching) {
                return SingleChildScrollView(
                  physics:
                      const BouncingScrollPhysics(), //ClampingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 128, top: 200),
                  child: Column(
                    children: [
                      Container(
                        width: double.maxFinite,
                        decoration: const BoxDecoration(
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
                                      padding: const EdgeInsets.only(
                                          left: 16, right: 24),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              state.lastSearchs[index],
                                              style: const TextStyle(
                                                  fontFamily: 'Montserrat',
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                          ),
                                          const Icon(
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
                      const Divider(
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
                                      style: const TextStyle(
                                          fontFamily: 'Montserrat',
                                          color: ColorStyle.textGrey,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16),
                                    ),
                                  ));
                            } else if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return Padding(
                                padding: const EdgeInsets.only(
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
                                    child: const RoundedDotterRectangleBorder(
                                        height: 52,
                                        width: double.maxFinite,
                                        color: ColorStyle.darkPurple,
                                        borderWidth: 1,
                                        icon: SizedBox(
                                          width: double.maxFinite,
                                          height: double.maxFinite,
                                          child: Row(
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
                                                decoration:
                                                    const BoxDecoration(),
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
                                                              style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize: 14,
                                                                  fontFamily:
                                                                      'Montserrat'),
                                                            ),
                                                            Text(
                                                              '${snapshot.data![index].entity} • ${snapshot.data![index].city}',
                                                              style: const TextStyle(
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
                                                      decoration:
                                                          const BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
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
                                                padding: const EdgeInsets.only(
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
                                                        const RoundedDotterRectangleBorder(
                                                            height: 52,
                                                            width: double
                                                                .maxFinite,
                                                            color: ColorStyle
                                                                .darkPurple,
                                                            borderWidth: 1,
                                                            icon: SizedBox(
                                                              width: double
                                                                  .maxFinite,
                                                              height: double
                                                                  .maxFinite,
                                                              child: Row(
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
                                style: const TextStyle(
                                    fontFamily: 'Montserrat',
                                    color: ColorStyle.textGrey,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16),
                              ),
                            );
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'No encontramos un proyecto, empresa o sucursal que se llame "${state.searchSelection}"',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontFamily: 'Montserrat',
                                        color: ColorStyle.textGrey,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16),
                                  ),
                                  const SizedBox(
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
                              padding:
                                  const EdgeInsets.only(top: 184, bottom: 128),
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
                                                decoration:
                                                    const BoxDecoration(),
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
                                                              style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize: 14,
                                                                  fontFamily:
                                                                      'Montserrat'),
                                                            ),
                                                            Text(
                                                              '${snapshot.data![index].entity} • ${snapshot.data![index].city}',
                                                              style: const TextStyle(
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
                                                      decoration:
                                                          const BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
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
                                                padding: const EdgeInsets.only(
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
                                style: const TextStyle(
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
                                style: const TextStyle(
                                    fontFamily: 'Montserrat',
                                    color: ColorStyle.textGrey,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16),
                              ),
                            );
                          } else {
                            return SingleChildScrollView(
                                padding: const EdgeInsets.only(
                                    top: 184, bottom: 112),
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
                                            decoration: const BoxDecoration(),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                CircularAvatarW(
                                                  externalRadius:
                                                      const Offset(38, 38),
                                                  internalRadius:
                                                      const Offset(34, 34),
                                                  nameAvatar:
                                                      '${snapshot.data![index].name.substring(0, 1).toUpperCase()}${snapshot.data![index].lastName.substring(0, 1).toUpperCase()}',
                                                  isCompany: false,
                                                  sizeText: 16,
                                                ),
                                                const SizedBox(
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
                                                          style: const TextStyle(
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
                return const SizedBox.shrink();
              }
            }),
            BlocBuilder<SearchBloc, SearchState>(
              builder: (context, state) {
                return Container(
                  height:
                      state is SearchEmpty || state is Searched ? 176 : null,
                  width: double.maxFinite,
                  padding: const EdgeInsets.only(top: 56),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [ShadowStyle().dropComponentShadow]),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedPadding(
                        duration: const Duration(milliseconds: 100),
                        padding: const EdgeInsets.only(left: 24, bottom: 8),
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
                                  child: const Icon(FeatherIcons.x)),
                            ),
                            AnimatedPadding(
                              duration: const Duration(milliseconds: 100),
                              padding: EdgeInsets.only(
                                  left: state is Searching ? 8 : 0),
                              child: const Text(
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
                        margin: const EdgeInsets.only(
                            left: 24, right: 24, bottom: 16),
                        decoration: BoxDecoration(
                            color: const Color.fromRGBO(118, 118, 118, 0.12),
                            borderRadius: BorderRadius.circular(8)),
                        child: TextField(
                          controller: controllerSearch,
                          maxLines: 1,
                          focusNode: focusNodeSearch,
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Buscar por establecimiento/persona',
                            hintStyle: const TextStyle(
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
                            prefixIcon: const Icon(FeatherIcons.search,
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
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.only(left: 24),
                            unselectedLabelColor: Colors.grey,
                            indicator: _customUnderlineIndicator(),
                            indicatorColor: Colors.purple,
                            indicatorWeight: 4.0,
                            labelStyle: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w600),
                            tabs: const [
                              Tab(text: 'Para ti'),
                              Tab(text: 'Empresas'),
                              Tab(text: 'Noticias'),
                              Tab(text: 'Tendencias'),
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
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.only(left: 24),
                            unselectedLabelColor: Colors.grey,
                            indicator: _customUnderlineIndicator(),
                            indicatorColor: Colors.purple,
                            indicatorWeight: 4.0,
                            labelStyle: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w600),
                            tabs: const [
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
                                padding: const EdgeInsets.only(
                                    left: 32, bottom: 8, top: 8),
                                margin: const EdgeInsets.only(),
                                child: Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          FeatherIcons.search,
                                          color: ColorStyle.textGrey,
                                          size: 20,
                                        ),
                                        const SizedBox(
                                          width: 16,
                                        ),
                                        Expanded(
                                          child: Text(
                                            'Buscar "${controllerSearch.text}"',
                                            style: const TextStyle(
                                                fontFamily: 'Montserrat',
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                        const Icon(
                                          FeatherIcons.chevronRight,
                                          color: ColorStyle.textGrey,
                                          size: 20,
                                        ),
                                        const SizedBox(
                                          width: 24,
                                        ),
                                      ],
                                    ),
                                    Container(
                                      height: 0.5,
                                      width: double.maxFinite,
                                      color: ColorStyle.borderGrey,
                                      margin: const EdgeInsets.only(
                                          left: 32, top: 16),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : const SizedBox.shrink()
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

  Widget _noticeScreen() {
    return RefreshIndicator.adaptive(
        displacement: 48,
        edgeOffset: 176,
        color: ColorStyle.darkPurple,
        backgroundColor: ColorStyle.grey,
        onRefresh: () async {
          await loadArticles();
          Future.delayed(const Duration(milliseconds: 1000));
        },
        child: CustomScrollView(physics: BouncingScrollPhysics(), slivers: [
          SliverToBoxAdapter(
              child: Column(
            children: [
              Container(
                height: 256,
                margin: EdgeInsets.only(top: 162),
                width: double.maxFinite,
                child: PageView.builder(
                    onPageChanged: (value) {
                      setState(() {
                        currentPage = value;
                      });
                    },
                    controller: _boardController,
                    physics: ClampingScrollPhysics(),
                    itemCount: imagesForYou.length,
                    itemBuilder: (context, snapshot) {
                      var scale = currentPageForYou == snapshot ? 1.0 : 1.0;
                      return TweenAnimationBuilder(
                        duration: const Duration(milliseconds: 350),
                        tween: Tween(begin: scale, end: scale),
                        curve: Curves.ease,
                        builder: (BuildContext context, double value,
                            Widget? child) {
                          return Transform.scale(
                            scale: value,
                            child: child,
                          );
                        },
                        child: CachedNetworkImage(
                          imageUrl: noticeImages[snapshot].ad.imageUrl!,
                          fit: BoxFit.fitWidth,
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error_outline),
                        ),
                      );
                    }),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: List.generate(
                    noticeImages.length, (index) => doIndicator(index)),
              ),
            ],
          )),
          isLoadingArticles
              ? SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: 296),
                    child: Center(
                        child: CircularProgressIndicator.adaptive(
                      backgroundColor: ColorStyle.grey, // Fondo del indicador
                      valueColor:
                          AlwaysStoppedAnimation<Color>(ColorStyle.darkPurple),
                    )),
                  ),
                )
              : articles.isEmpty
                  ? SliverToBoxAdapter(
                      child: Padding(
                          padding: EdgeInsets.only(top: 296),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'No hay articulos',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontFamily: "Montserrat",
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400),
                              ),
                            ],
                          )),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.only(top: 24, bottom: 96),
                      sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                              childCount: articles
                                  .length, // número de items en la lista
                              (BuildContext context, int index) {
                        final article = articles[index];
                        return PressTransform(
                            onPressed: () {
                              Navigator.of(context, rootNavigator: true).push(
                                MaterialPageRoute(
                                  builder: (context) => NoticeDetailScreen(
                                    article: article,
                                    index: index,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              height: 112,
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    ShadowStyle().baseComponentShadow
                                  ]),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 128,
                                    height: 112,
                                    margin: const EdgeInsets.only(right: 16),
                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.horizontal(
                                            left: Radius.circular(8))),
                                    child: Hero(
                                        tag: index,
                                        child: article.imageUrl != null
                                            ? Image.network(
                                                article.imageUrl!,
                                                width: double.maxFinite,
                                                fit: BoxFit.cover,
                                              )
                                            : Image.asset(
                                                'assets/images/logos/Whistle.png',
                                                width: double.maxFinite,
                                              )),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          top: 8, bottom: 8, right: 8),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Text(
                                            article.title,
                                            maxLines: 2,
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontFamily: 'Montserrat',
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14),
                                          ),
                                          const SizedBox(
                                            height: 4,
                                          ),
                                          Text(
                                            article.subtitle,
                                            maxLines: 2,
                                            style: const TextStyle(
                                                fontFamily: 'Montserrat',
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400),
                                          ),
                                          Expanded(
                                            child: Align(
                                              alignment: Alignment.bottomLeft,
                                              child: Text(
                                                article.formatDate(),
                                                textAlign: TextAlign.right,
                                                style: const TextStyle(
                                                    color: ColorStyle.textGrey,
                                                    fontFamily: 'Montserrat',
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Markdown(
                                  //     shrinkWrap: true,
                                  //     physics:
                                  //         NeverScrollableScrollPhysics(),
                                  //     data:
                                  //         article.content),
                                ],
                              ),
                            ));
                      })))
        ]));
  }

  Widget _buisinessScreen() {
    return RefreshIndicator.adaptive(
        displacement: 48,
        edgeOffset: 176,
        color: ColorStyle.darkPurple,
        backgroundColor: ColorStyle.grey,
        onRefresh: () async {
          await loadBusiness();
          Future.delayed(const Duration(milliseconds: 1000));
          print("trunca");
        },
        child: CustomScrollView(physics: BouncingScrollPhysics(), slivers: [
          isLoading
              ? SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: 296),
                    child: Center(
                        child: CircularProgressIndicator.adaptive(
                      backgroundColor: ColorStyle.grey, // Fondo del indicador
                      valueColor:
                          AlwaysStoppedAnimation<Color>(ColorStyle.darkPurple),
                    )),
                  ),
                )
              : businesses.isEmpty
                  ? SliverToBoxAdapter(
                      child: Padding(
                          padding: EdgeInsets.only(top: 296),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sigue proyectos',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontFamily: "Montserrat",
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400),
                              ),
                            ],
                          )),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.only(top: 168, bottom: 80),
                      sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                              childCount: businesses
                                  .length, // número de items en la lista
                              (BuildContext context, int index) {
                        return BusinessWidget(
                          business: businesses[index],
                          onAddReview: () async {
                            final userBloc = BlocProvider.of<UserBloc>(context);

                            final userState = userBloc.state;
                            if (userState is UserLoaded) {
                              await showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  barrierColor:
                                      const Color.fromRGBO(0, 0, 0, 0.1),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(20.0),
                                      topRight: Radius.circular(20.0),
                                    ),
                                  ),
                                  builder: (context) => BackdropFilter(
                                      filter: ImageFilter.blur(
                                          sigmaX: 6, sigmaY: 6),
                                      child: CombinedBottomSheet(
                                        user: userState.user,
                                        business: businesses[index],
                                      )));
                            }
                          },
                        );
                      })))
        ]));
  }

  Widget _buildForYou() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 160),
      child: Column(
        children: [
          Container(
            height: 256,
            margin: EdgeInsets.only(top: 162),
            width: double.maxFinite,
            child: PageView.builder(
                onPageChanged: (value) {
                  setState(() {
                    currentPageForYou = value;
                  });
                },
                controller: _boardControllerForYou,
                physics: ClampingScrollPhysics(),
                itemCount: imagesForYou.length,
                itemBuilder: (context, snapshot) {
                  var scale = currentPageForYou == snapshot ? 1.0 : 1.0;
                  return TweenAnimationBuilder(
                    duration: const Duration(milliseconds: 350),
                    tween: Tween(begin: scale, end: scale),
                    curve: Curves.ease,
                    builder:
                        (BuildContext context, double value, Widget? child) {
                      return Transform.scale(
                        scale: value,
                        child: child,
                      );
                    },
                    child: CachedNetworkImage(
                      imageUrl: imagesForYou[snapshot].ad.imageUrl!,
                      fit: BoxFit.fitWidth,
                      errorWidget: (context, url, error) =>
                          Icon(Icons.error_outline),
                    ),
                  );
                }),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: List.generate(
                imagesForYou.length, (index) => doIndicatorForYou(index)),
          ),

          Column(
              children: List.generate(
            banners
                .where((element) => element.location == 'BS')
                .toList()
                .length,
            (index) => Container(
              height: 256,
              margin: EdgeInsets.only(top: 162),
              width: double.maxFinite,
              padding: const EdgeInsets.only(left: 24, bottom: 16),
              decoration: BoxDecoration(
                gradient: GradientStyle().grayGradient,
                // image: DecorationImage(
                //     image: NetworkImage(banners
                //         .where((element) => element.location == 'BS')
                //         .toList()[index]
                //         .ad
                //         .imageUrl))
              ),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        banners
                            .where((element) => element.location == 'BS')
                            .toList()[index]
                            .ad
                            .title,
                        style: TextStyle(
                            color: Colors.black.withOpacity(0.5),
                            fontFamily: 'Montserrat',
                            fontSize: 24,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  )
                ],
              ),
            ),
          )),

          Column(
            children: List.generate(
                0,
                (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: const Column(
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
                            "24 Me gusta • 6 comentarios",
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
          // const Divider(
          //   color: ColorStyle.midToneGrey,
          // ),
          // ReviewCardDefault(
          //     review: Review(
          //         idReview: '',
          //         content:
          //             'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud.',
          //         likes: 2,
          //         rating: 2.5,
          //         isLiked: true,
          //         isValid: true,
          //         createdAt: null,
          //         updatedAt: null,
          //         comments: 4,
          //         business: BusinessData(
          //             idBusiness: '',
          //             name: 'Starbucks',
          //             entity: 'Alsea',
          //             rating: 4,
          //             followed: true),
          //         user: UserData(
          //             idUser: '',
          //             name: 'Harold',
          //             lastName: 'Lancheros',
          //             followed: true)))
        ],
      ),
    );
  }
}


//class BusinessSearchScreen extends StatefulWidget {
//   final List<Business> business;
//   const BusinessSearchScreen({
//     super.key,
//     required this.business,
//   });

//   @override
//   State<BusinessSearchScreen> createState() => _BusinessSearchScreenState();
// }

// class _BusinessSearchScreenState extends State<BusinessSearchScreen> {
//   List<Business> businesses = [];
//   bool isLoading = true;

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//   }

//   Future<void> loadBusiness() async {
//     try {
//       final businessList = await ApiService().getAllBusiness();
//       print(businessList);
//       print("ssaaa");

//       if (mounted) {
//         setState(() {
//           businesses = businessList;
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       // Handle the error or set state to show an error message
//       if (mounted) {
//         showErrorSnackBar(context, e.toString());
//         setState(() {
//           isLoading = false;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return RefreshIndicator.adaptive(
//         displacement: 48,
//         edgeOffset: 176,
//         color: ColorStyle.darkPurple,
//         backgroundColor: ColorStyle.grey,
//         onRefresh: () async {
//           await loadBusiness();
//           Future.delayed(const Duration(milliseconds: 1000));
//           print("trunca");
//         },
//         child: CustomScrollView(physics: BouncingScrollPhysics(), slivers: [
//           isLoading
//               ? SliverToBoxAdapter(
//                   child: Padding(
//                     padding: EdgeInsets.only(top: 296),
//                     child: Center(
//                         child: CircularProgressIndicator.adaptive(
//                       backgroundColor: ColorStyle.grey, // Fondo del indicador
//                       valueColor:
//                           AlwaysStoppedAnimation<Color>(ColorStyle.darkPurple),
//                     )),
//                   ),
//                 )
//               : businesses.isEmpty
//                   ? SliverToBoxAdapter(
//                       child: Padding(
//                           padding: EdgeInsets.only(top: 296),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 'Sigue proyectos',
//                                 textAlign: TextAlign.center,
//                                 style: TextStyle(
//                                     fontFamily: "Montserrat",
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.w400),
//                               ),
//                             ],
//                           )),
//                     )
//                   : SliverPadding(
//                       padding: const EdgeInsets.only(top: 168, bottom: 80),
//                       sliver: SliverList(
//                           delegate: SliverChildBuilderDelegate(
//                               childCount: businesses
//                                   .length, // número de items en la lista
//                               (BuildContext context, int index) {
//                         return BusinessWidget(
//                           business: businesses[index],
//                           onAddReview: () async {
//                             final userBloc = BlocProvider.of<UserBloc>(context);

//                             final userState = userBloc.state;
//                             if (userState is UserLoaded) {
//                               await showModalBottomSheet(
//                                   context: context,
//                                   isScrollControlled: true,
//                                   barrierColor:
//                                       const Color.fromRGBO(0, 0, 0, 0.1),
//                                   shape: const RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.only(
//                                       topLeft: Radius.circular(20.0),
//                                       topRight: Radius.circular(20.0),
//                                     ),
//                                   ),
//                                   builder: (context) => BackdropFilter(
//                                       filter: ImageFilter.blur(
//                                           sigmaX: 6, sigmaY: 6),
//                                       child: CombinedBottomSheet(
//                                         user: userState.user,
//                                         business: businesses[index],
//                                       )));
//                             }
//                           },
//                         );
//                       })))
//         ]));
//   }
// }

// class NoticeScreen extends StatelessWidget {
//   const NoticeScreen({
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<List<Article>>(
//       future: ApiService().getArticles(),
//       builder: (context, snapshot) {
//         // Verificar si hay errores
//         if (snapshot.hasError) {
//           return Center(
//             child: Text(
//               "Error: ${snapshot.error}",
//               style: TextStyle(fontFamily: 'Montserrat'),
//             ),
//           );
//         }

//         // Esperando a que la Future se complete
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Center(child: CircularProgressIndicator.adaptive());
//         }

//         // Datos recibidos y sin errores
//         if (snapshot.connectionState == ConnectionState.done) {
//           // Verifica si la lista de artículos está vacía
//           if (snapshot.data?.isEmpty ?? true) {
//             return Center(
//               child: Text(
//                 "No hay artículos disponibles.",
//                 style: TextStyle(fontFamily: 'Montserrat'),
//               ),
//             );
//           }

//           // Datos existen y no están vacíos
//           return SingleChildScrollView(
//             child: Column(
//               children: List.generate(snapshot.data!.length, (index) {
//                 final article = snapshot.data![index];
//                 return PressTransform(
//                     onPressed: () {
//                       Navigator.of(context, rootNavigator: true).push(
//                         MaterialPageRoute(
//                           builder: (context) => NoticeDetailScreen(
//                             article: article,
//                             index: index,
//                           ),
//                         ),
//                       );
//                     },
//                     child: Container(
//                       margin: const EdgeInsets.symmetric(
//                           horizontal: 24, vertical: 8),
//                       padding: const EdgeInsets.symmetric(
//                           vertical: 10, horizontal: 10),
//                       decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(10)),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Container(
//                             width: double.maxFinite,
//                             margin: const EdgeInsets.only(bottom: 10),
//                             clipBehavior: Clip.antiAliasWithSaveLayer,
//                             decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(8)),
//                             child: Hero(
//                               tag: index,
//                               child: index == 0
//                                   ? Image.asset(
//                                       'assets/images/logos/Whistle.png',
//                                       width: double.maxFinite,
//                                     )
//                                   : Image.asset(
//                                       'assets/images/ilustrations/169.jpg',
//                                       width: double.maxFinite,
//                                     ),
//                             ),
//                           ),
//                           Text(
//                             snapshot.data![index].title,
//                             style: const TextStyle(
//                                 color: Colors.black,
//                                 fontFamily: 'Montserrat',
//                                 fontWeight: FontWeight.w600,
//                                 fontSize: 14),
//                           ),
//                           const SizedBox(
//                             height: 4,
//                           ),
//                           Markdown(
//                               shrinkWrap: true,
//                               data: snapshot.data![index].content),
//                           // Text(
//                           //   snapshot.data![index].content,
//                           //   maxLines: 4,
//                           //   style: const TextStyle(
//                           //       fontFamily: 'Montserrat',
//                           //       fontSize: 14,
//                           //       fontWeight: FontWeight.w400),
//                           // ),
//                           const SizedBox(
//                             height: 4,
//                           ),
//                           Align(
//                             alignment: Alignment.centerRight,
//                             child: Text(
//                               snapshot.data![index].formatDate(),
//                               textAlign: TextAlign.right,
//                               style: const TextStyle(
//                                   color: ColorStyle.textGrey,
//                                   fontFamily: 'Montserrat',
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.w500),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ));
//               }),
//             ),
//           );
//         }

//         // Si el Future aún no se ha iniciado o no hay otros estados definidos
//         return Center(
//           child: Text(
//             "Algo salió mal.",
//             style: TextStyle(fontFamily: 'Montserrat'),
//           ),
//         );
//       },
//     );
//   }
// }
