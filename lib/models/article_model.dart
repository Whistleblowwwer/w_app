import 'dart:convert';
import 'dart:typed_data';

import 'package:intl/intl.dart';

class Article {
  String id;
  String title;
  String subtitle;
  String content;
  DateTime? publishedAt;
  bool isPublished;
  String? idCategory; // Puede ser nulo
  Uint8List? imageUrl; // Puede ser nulo o no estar en el JSON
  String authorName;
  String authorEmail;

  Article({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.content,
    required this.publishedAt,
    required this.isPublished,
    this.idCategory, // Puede ser nulo
    this.imageUrl, // Puede ser nulo
    required this.authorName,
    required this.authorEmail,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['_id_article'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      content: json['content'] ?? '',
      publishedAt: json['published_at'] != null
          ? DateTime.parse(json['published_at'])
          : null,
      isPublished: json['is_published'],
      idCategory: json['_id_category'],
      imageUrl: extractFirstImage(json),
      authorName: json['Author']?['name'] ?? '',
      authorEmail: json['Author']?['email'] ?? '',
    );
  }

  String formatDate() {
    final DateFormat formatter = DateFormat('MMM dd, yyyy');
    return publishedAt != null ? formatter.format(publishedAt!) : '';
  }
}

Uint8List? extractFirstImage(Map<String, dynamic> jsonData) {
  // Parse JSON data

  // Extract content field
  String content = jsonData['content'];

  // Find all matches for base64 images
  RegExp regExp = RegExp(r'\(data:image\/[a-zA-Z]*;base64,[^)]+\)');
  Iterable<RegExpMatch> matches = regExp.allMatches(content);

  if (matches.isNotEmpty) {
    // Get the first match
    String firstMatch = matches.first.group(0) ?? '';

    // Extract Base64 part
    String base64String = firstMatch.split(',')[1].split(')')[0];

    // Return the Base64 string, decode it if necessary
    return base64Decode(base64String);
  } else {
    // Return an empty string or handle the case where no image is found
    return null;
  }
}
