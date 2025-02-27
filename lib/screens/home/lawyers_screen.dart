import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:w_app/models/attorney_model.dart';
import 'package:w_app/services/api/api_service.dart';
import 'package:w_app/styles/color_style.dart';
import 'package:w_app/widgets/snackbar.dart';

class LawyersScreen extends StatefulWidget {
  const LawyersScreen({super.key});

  @override
  LawyersScreenState createState() => LawyersScreenState();
}

class LawyersScreenState extends State<LawyersScreen> {
  int currentPage = 0;
  int itemCountBoard = 2;
  List<Attorney> attorney = [];
  bool isLoadingAttorney = true;
  final PageController _boardController =
      PageController(initialPage: 0, viewportFraction: 1);
  AnimatedContainer doIndicator(index) {
    return AnimatedContainer(
      margin: const EdgeInsets.only(right: 4, left: 4),
      duration: const Duration(milliseconds: 300),
      height: 8,
      width: currentPage == index ? 8 : 12,
      decoration: BoxDecoration(
        color: currentPage == index
            ? ColorStyle.darkPurple.withOpacity(0.8)
            : Colors.white.withOpacity(0.8),
        shape: BoxShape.circle,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    loadAttorney();
    WidgetsBinding.instance.addPostFrameCallback((_) async {});
  }

  List images = [
    'assets/images/ilustrations/banner_abogado1.jpg',
    'assets/images/ilustrations/banner_abogado2.jpg',
  ];

  Future<void> loadAttorney() async {
    try {
      final articleList = await ApiService().getAttorneys();

      if (mounted) {
        setState(() {
          attorney = articleList;
          isLoadingAttorney = false;
        });
      }
    } catch (e) {
      // Handle the error or set state to show an error message
      if (mounted) {
        showErrorSnackBar(context, e.toString());
        setState(() {
          isLoadingAttorney = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          height: double.maxFinite,
          width: double.maxFinite,
          child: Stack(
            children: [
              Positioned.fill(
                top: 48,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 80),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.maxFinite,
                        height: 256,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Positioned.fill(
                              child: PageView.builder(
                                  onPageChanged: (value) {
                                    setState(() {
                                      currentPage = value;
                                    });
                                  },
                                  controller: _boardController,
                                  itemCount: itemCountBoard,
                                  itemBuilder: (context, snapshot) {
                                    var scale =
                                        currentPage == snapshot ? 1.0 : 1.0;
                                    return TweenAnimationBuilder(
                                      duration:
                                          const Duration(milliseconds: 350),
                                      tween: Tween(begin: scale, end: scale),
                                      curve: Curves.ease,
                                      builder: (BuildContext context,
                                          double value, Widget? child) {
                                        return Transform.scale(
                                          scale: value,
                                          child: child,
                                        );
                                      },
                                      child: Image.asset(
                                        images[snapshot],
                                        fit: BoxFit.fitWidth,
                                      ),
                                    );
                                  }),
                            ),
                            Positioned(
                              bottom: 32,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: List.generate(itemCountBoard,
                                    (index) => doIndicator(index)),
                              ),
                            )
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(
                            left: 16, right: 16, bottom: 16, top: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Consigue ayuda ¡hoy!",
                              style: TextStyle(
                                  color: ColorStyle.darkPurple,
                                  fontSize: 16,
                                  fontFamily: 'Montserrat'),
                            ),
                            Text(
                              "",
                              style: TextStyle(
                                  color: ColorStyle.textGrey,
                                  fontSize: 16,
                                  fontFamily: 'Montserrat'),
                            ),
                          ],
                        ),
                      ),
                      if (isLoadingAttorney)
                        const Padding(
                          padding: EdgeInsets.only(top: 56),
                          child: Center(
                              child: CircularProgressIndicator.adaptive(
                            backgroundColor:
                                ColorStyle.grey, // Fondo del indicador
                            valueColor: AlwaysStoppedAnimation<Color>(
                                ColorStyle.darkPurple),
                          )),
                        )
                      else
                        attorney.isEmpty
                            ? Padding(
                                padding: EdgeInsets.only(top: 40, bottom: 24),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'No hay abogados disponibles',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontFamily: "Montserrat",
                                          fontSize: 18,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ],
                                ))
                            : Column(
                                children: List.generate(
                                    attorney.length,
                                    (index) => Container(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                        clipBehavior:
                                            Clip.antiAliasWithSaveLayer,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        child: attorney[index].imgUrl == null
                                            ? null
                                            : CachedNetworkImage(
                                                imageUrl:
                                                    attorney[index].imgUrl!,
                                                fit: images.length == 1
                                                    ? BoxFit.fitWidth
                                                    : BoxFit.cover,
                                                placeholder: (context, url) =>
                                                    const SizedBox(
                                                      height: 200,
                                                      child: Center(
                                                        child:
                                                            CircularProgressIndicator
                                                                .adaptive(
                                                          backgroundColor:
                                                              ColorStyle
                                                                  .grey, // Fondo del indicador
                                                          valueColor:
                                                              AlwaysStoppedAnimation<
                                                                      Color>(
                                                                  ColorStyle
                                                                      .darkPurple),
                                                        ),
                                                      ),
                                                    ),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Icon(Icons.error)))),
                              ),

                      Container(
                        margin: const EdgeInsets.only(
                            left: 24, right: 24, top: 24, bottom: 8),
                        padding: const EdgeInsets.only(
                            left: 16, top: 10, bottom: 10, right: 16),
                        width: double.maxFinite,
                        decoration: BoxDecoration(
                            color: ColorStyle.textGrey,
                            borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "¿Quieres ofrecer tu ayuda?",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  const Text(
                                    "Sigamos rompiendo barreras.",
                                    maxLines: 2,
                                    style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 10),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(top: 10),
                                    padding: const EdgeInsets.only(
                                      top: 8,
                                      bottom: 8,
                                    ),
                                    width: 108,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        color: const Color.fromRGBO(
                                            170, 50, 155, 1),
                                        borderRadius: BorderRadius.circular(5)),
                                    child: const Text(
                                      "¡Me interesa!",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Montserrat'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Image.asset('assets/images/ilustrations/help.png'),
                          ],
                        ),
                      ),

                      // Column(
                      //   children: List.generate(
                      //     2,
                      //     (index) => index != 1
                      //         ? Stack(
                      //             alignment: Alignment.bottomLeft,
                      //             children: [
                      //               Container(
                      //                 margin: const EdgeInsets.only(
                      //                     left: 24,
                      //                     right: 24,
                      //                     top: 8,
                      //                     bottom: 8),
                      //                 padding: const EdgeInsets.only(
                      //                     left: 108,
                      //                     top: 10,
                      //                     bottom: 10,
                      //                     right: 16),
                      //                 width: double.maxFinite,
                      //                 decoration: BoxDecoration(
                      //                     color: const Color.fromRGBO(
                      //                         164, 187, 255, 1),
                      //                     borderRadius:
                      //                         BorderRadius.circular(12)),
                      //                 child: Column(
                      //                   crossAxisAlignment:
                      //                       CrossAxisAlignment.start,
                      //                   children: [
                      //                     const Text(
                      //                       "Nombre Abogado",
                      //                       maxLines: 1,
                      //                       overflow: TextOverflow.ellipsis,
                      //                       style: TextStyle(
                      //                           fontFamily: 'Montserrat',
                      //                           color: Colors.white,
                      //                           fontWeight: FontWeight.w700),
                      //                     ),
                      //                     const Row(
                      //                       children: [
                      //                         Flexible(
                      //                           child: Text(
                      //                             "Especialidad en demandas inmobiliarias",
                      //                             maxLines: 2,
                      //                             style: TextStyle(
                      //                                 fontFamily: 'Montserrat',
                      //                                 color: Colors.white,
                      //                                 fontSize: 12),
                      //                           ),
                      //                         ),
                      //                         Text(
                      //                           "5",
                      //                           style: TextStyle(
                      //                               fontFamily: 'Montserrat',
                      //                               color: Colors.white,
                      //                               fontSize: 14),
                      //                         ),
                      //                         Icon(
                      //                           Icons.star_rounded,
                      //                           color: Colors.white,
                      //                           size: 18,
                      //                         )
                      //                       ],
                      //                     ),
                      //                     Container(
                      //                       margin: const EdgeInsets.only(
                      //                           left: 0, right: 0, top: 10),
                      //                       padding: const EdgeInsets.only(
                      //                           left: 8, top: 8, bottom: 8),
                      //                       width: double.maxFinite,
                      //                       alignment: Alignment.centerLeft,
                      //                       decoration: BoxDecoration(
                      //                           color: ColorStyle.lightGrey,
                      //                           borderRadius:
                      //                               BorderRadius.circular(5)),
                      //                       child: const Text(
                      //                         "¿Cómo te puedo ayudar?",
                      //                         style: TextStyle(
                      //                             color: ColorStyle.textGrey,
                      //                             fontFamily: 'Montserrat'),
                      //                       ),
                      //                     ),
                      //                   ],
                      //                 ),
                      //               ),
                      //               Padding(
                      //                 padding: const EdgeInsets.only(
                      //                     left: 24, bottom: 8),
                      //                 child: Image.asset(
                      //                     'assets/images/ilustrations/abogado.png'),
                      //               )
                      //             ],
                      //           )
                      //         : Container(
                      //             margin: const EdgeInsets.only(
                      //                 left: 24, right: 24, top: 24, bottom: 8),
                      //             padding: const EdgeInsets.only(
                      //                 left: 16, top: 10, bottom: 10, right: 16),
                      //             width: double.maxFinite,
                      //             decoration: BoxDecoration(
                      //                 color: ColorStyle.textGrey,
                      //                 borderRadius: BorderRadius.circular(12)),
                      //             child: Row(
                      //               mainAxisAlignment:
                      //                   MainAxisAlignment.spaceBetween,
                      //               children: [
                      //                 Flexible(
                      //                   child: Column(
                      //                     crossAxisAlignment:
                      //                         CrossAxisAlignment.start,
                      //                     children: [
                      //                       const Text(
                      //                         "¿Quieres ofrecer tu ayuda?",
                      //                         maxLines: 1,
                      //                         overflow: TextOverflow.ellipsis,
                      //                         style: TextStyle(
                      //                             fontFamily: 'Montserrat',
                      //                             fontSize: 16,
                      //                             color: Colors.white,
                      //                             fontWeight: FontWeight.w700),
                      //                       ),
                      //                       const Text(
                      //                         "Sigamos rompiendo barreras.",
                      //                         maxLines: 2,
                      //                         style: TextStyle(
                      //                             fontFamily: 'Montserrat',
                      //                             color: Colors.white,
                      //                             fontWeight: FontWeight.w500,
                      //                             fontSize: 10),
                      //                       ),
                      //                       Container(
                      //                         margin: const EdgeInsets.only(
                      //                             top: 10),
                      //                         padding: const EdgeInsets.only(
                      //                           top: 8,
                      //                           bottom: 8,
                      //                         ),
                      //                         width: 108,
                      //                         alignment: Alignment.center,
                      //                         decoration: BoxDecoration(
                      //                             color: const Color.fromRGBO(
                      //                                 170, 50, 155, 1),
                      //                             borderRadius:
                      //                                 BorderRadius.circular(5)),
                      //                         child: const Text(
                      //                           "¡Me interesa!",
                      //                           style: TextStyle(
                      //                               color: Colors.white,
                      //                               fontFamily: 'Montserrat'),
                      //                         ),
                      //                       ),
                      //                     ],
                      //                   ),
                      //                 ),
                      //                 Image.asset(
                      //                     'assets/images/ilustrations/help.png'),
                      //               ],
                      //             ),
                      //           ),
                      //   ),
                      // )
                    ],
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 32),
                height: 56,
                width: double.maxFinite,
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: Colors.white),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: const Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(left: 16, right: 8),
                          child: Icon(FeatherIcons.arrowLeft),
                        ),
                      ),
                    ),
                    const Text(
                      "Abogados",
                      style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold),
                    ),
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
