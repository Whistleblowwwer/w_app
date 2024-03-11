import 'package:w_app/models/company_model.dart';
import 'package:w_app/models/review_model.dart';

class Ad {
  final String? idReview;
  final String idAd;
  final String title;
  final String description;
  final String? imageUrl;
  final String startCampaignDate;
  final String endCampaignDate;
  final int? durationDays;
  final String clickUrl;
  final String status;
  final bool isValid;
  final String idUser;
  final String idBusiness;
  final String type;
  final String createdAt;
  final String updatedAt;
  final UserData? user;
  final BusinessData? business;

  Ad({
    this.idReview,
    required this.idAd,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.startCampaignDate,
    required this.endCampaignDate,
    this.durationDays,
    required this.clickUrl,
    required this.status,
    required this.isValid,
    required this.idUser,
    required this.idBusiness,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.business,
  });

  factory Ad.fromJson(Map<String, dynamic> json) {
    return Ad(
      idReview: json['_id_review'],
      idAd: json['_id_ad'],
      title: json['title'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      startCampaignDate: json['start_campaign_date'],
      endCampaignDate: json['end_campaign_date'],
      durationDays: json['duration_days'],
      clickUrl: json['clickUrl'],
      status: json['status'],
      isValid: json['is_valid'],
      idUser: json['_id_user'],
      idBusiness: json['_id_business'],
      type: json['type'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      user: json['User'] != null ? UserData.fromJson(json['User']) : null,
      business: json['Business'] != null
          ? BusinessData.fromJson(json['Business'])
          : null,
    );
  }
}
