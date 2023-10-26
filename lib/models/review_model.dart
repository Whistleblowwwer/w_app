class Review {
  final String author;
  final String content;
  final List<Comment> comments;

  Review({required this.author, required this.content, required this.comments});

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      author: json['review']['author'],
      content: json['review']['content'],
      comments:
          (json['comments'] as List).map((c) => Comment.fromJson(c)).toList(),
    );
  }
}

class Comment {
  final String author;
  final String content;
  final List<Comment>? children;

  Comment({required this.author, required this.content, this.children});

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      author: json['author'],
      content: json['content'],
      children: json['children'] != null
          ? (json['children'] as List).map((c) => Comment.fromJson(c)).toList()
          : null,
    );
  }
}
