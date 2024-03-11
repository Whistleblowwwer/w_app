import 'package:w_app/models/ad_model.dart';

class BannerModel {
  final String idBanner;
  final String location;
  final int indexPosition;
  final bool isValid;
  final String createdAt;
  final String updatedAt;
  final String idAd;
  final Ad ad;

  BannerModel({
    required this.idBanner,
    required this.location,
    required this.indexPosition,
    required this.isValid,
    required this.createdAt,
    required this.updatedAt,
    required this.idAd,
    required this.ad,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      idBanner: json["_id_banner"],
      location: json["location"],
      indexPosition: json["index_position"],
      isValid: json["is_valid"],
      createdAt: json["createdAt"],
      updatedAt: json["updatedAt"],
      idAd: json["_id_ad"],
      ad: Ad.fromJson(json["Ad"]),
    );
  }
}
