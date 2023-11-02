import 'package:flutter/material.dart';
import 'package:w_app/models/review_model.dart';
import 'package:w_app/screens/home/widgets/review_card.dart';

class ReviewExtendedWidget extends StatelessWidget {
  final Review review;

  ReviewExtendedWidget({required this.review});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(top: 102, bottom: 96),
      child: Column(
        children: [
          ReviewCard(
            isThread: true,
            review: review,
          ),
          // ReviewIntoCard(author: review.author, content: review.content),

          for (Comment comment in []) CommentWidget(comment: comment),
        ],
      ),
    );
  }
}

class ReviewIntoCard extends StatelessWidget {
  final String author;
  final String content;

  const ReviewIntoCard({required this.author, required this.content});

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

  const CommentWidget({required this.comment});

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
              padding: const EdgeInsets.only(left: 30),
              child: CommentWidget(comment: childComment),
            ),
      ],
    );
  }
}
