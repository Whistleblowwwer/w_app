import 'package:flutter/material.dart';
import 'package:w_app/models/banner_model.dart';
import 'package:w_app/services/api/api_service.dart';
import 'package:w_app/styles/color_style.dart';

class TrendingScreen extends StatefulWidget {
  final List<BannerModel> banners;
  const TrendingScreen({
    super.key,
    required this.banners,
  });

  @override
  State<TrendingScreen> createState() => _TrendingScreenState();
}

class _TrendingScreenState extends State<TrendingScreen>
    with AutomaticKeepAliveClientMixin<TrendingScreen> {
  @override
  bool get wantKeepAlive => true;

  int currentPage = 0;
  List<BannerModel> trendingImages = [];

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

  Future<void> loadBanners() async {
    try {
      // Suponiendo que getBanners() devuelve Map<String, List<BannerModel>>
      Map<String, List<BannerModel>> bannersBySection =
          await ApiService().getBanners();

      List<BannerModel> tdBanners = bannersBySection['TD'] ?? [];

      tdBanners.sort((a, b) => a.indexPosition.compareTo(b.indexPosition));
      setState(() {
        trendingImages = tdBanners;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadBanners();
    print("jodaaa");
  }

  @override
  Widget build(BuildContext context) {
    super.build;
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
                physics: ClampingScrollPhysics(),
                onPageChanged: (value) {
                  setState(() {
                    currentPage = value;
                  });
                },
                controller: _boardController,
                itemCount: trendingImages.length,
                itemBuilder: (context, snapshot) {
                  var scale = currentPage == snapshot ? 1.0 : 1.0;
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
                    child: Image.network(
                      trendingImages[snapshot].ad.imageUrl!,
                      fit: BoxFit.fitWidth,
                    ),
                  );
                }),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: List.generate(
                trendingImages.length, (index) => doIndicator(index)),
          ),

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
