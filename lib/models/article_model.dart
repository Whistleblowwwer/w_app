import 'package:intl/intl.dart';

class Article {
  String id;
  String title;
  String content;
  DateTime publishedAt;
  bool isPublished;
  String idCategory;
  String imageUrl;

  Article({
    required this.id,
    required this.title,
    required this.content,
    required this.publishedAt,
    required this.isPublished,
    required this.idCategory,
    required this.imageUrl,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
        id: json['_id'],
        title: json['title'],
        content: json['content'],
        publishedAt: DateTime.parse(json['published_at']),
        isPublished: json['is_published'],
        idCategory: json['_id_category'],
        imageUrl: '');
  }
  String formatDate() {
    final DateFormat formatter = DateFormat('MMM dd, yyyy');
    return formatter.format(publishedAt);
  }
}
