import 'package:flutter/material.dart';
import 'package:w_app/models/review_model.dart';

class ReviewExtendedWidget extends StatelessWidget {
  final Review review;

  ReviewExtendedWidget({required this.review});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ReviewCard(author: review.author, content: review.content),
        Divider(),
        for (var comment in review.comments) CommentWidget(comment: comment),
      ],
    );
  }
}

class ReviewCard extends StatelessWidget {
  final String author;
  final String content;

  ReviewCard({required this.author, required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(author),
        subtitle: Text(content),
      ),
    );
  }
}

class CommentWidget extends StatelessWidget {
  final Comment comment;

  CommentWidget({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(comment.author),
          subtitle: Text(comment.content),
        ),
        if (comment.children != null)
          for (var childComment in comment.children!)
            Padding(
              padding: EdgeInsets.only(left: 30),
              child: CommentWidget(comment: childComment),
            ),
      ],
    );
  }
}
