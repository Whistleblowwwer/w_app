import 'package:flutter/material.dart';
import 'package:w_app/models/review_model.dart';
import 'package:w_app/screens/home/widgets/review_extended_widget.dart';

class ReviewPage extends StatefulWidget {
  const ReviewPage({super.key});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  Review? review;
  Map<String, dynamic> reviewJson = {
    "review": {
      "author": "Jorge Ancer",
      "content": "Lorem ipsum dolor sit amet, consectetur adipiscing elit..."
    },
    "comments": [
      {
        "author": "Aristoteles Onasis",
        "content": "Este es un comentario sobre la reseña...",
        "children": [
          {
            "author": "Poncho Cifuentes",
            "content": "Este es un comentario hijo de Aristoteles Onasis..."
          },
          {
            "author": "Maria Perez",
            "content": "Otro comentario hijo de Aristoteles Onasis..."
          }
        ]
      },
      {
        "author": "Julia Ocampo",
        "content": "Otro comentario principal sobre la reseña..."
      }
    ]
  };

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          width: double.maxFinite,
          height: double.maxFinite,
          child: ReviewExtendedWidget(review: Review.fromJson(reviewJson))),
    );
  }
}
