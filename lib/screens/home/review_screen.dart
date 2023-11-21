import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:w_app/bloc/feed_bloc/feed_bloc.dart';
import 'package:w_app/bloc/feed_bloc/feed_state.dart';
import 'package:w_app/models/review_model.dart';
import 'package:w_app/screens/home/widgets/review_extended_widget.dart';

class ReviewPage extends StatelessWidget {
  final Review review;
  final VoidCallback onLike;
  final Future Function() onComment;
  final VoidCallback onFollowUser;
  const ReviewPage(
      {super.key,
      required this.review,
      required this.onLike,
      required this.onComment,
      required this.onFollowUser});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeedBloc, FeedState>(
      buildWhen: (previous, current) {
        // Solo reconstruir si el estado es FeedLoaded y la reseña relevante ha cambiado.
        if (previous is FeedLoaded && current is FeedLoaded) {
          final previousReviewIndex =
              previous.reviews.indexWhere((r) => r.idReview == review.idReview);
          final currentReviewIndex =
              current.reviews.indexWhere((r) => r.idReview == review.idReview);

          // Si alguna de las reseñas no se encuentra, no reconstruir.
          if (previousReviewIndex == -1 || currentReviewIndex == -1) {
            return false;
          }

          // Comprobar si las propiedades relevantes han cambiado.
          return previous.reviews[previousReviewIndex].isLiked !=
                  current.reviews[currentReviewIndex].isLiked ||
              previous.reviews[previousReviewIndex].user.followed !=
                  current.reviews[currentReviewIndex].user.followed ||
              previous.reviews[previousReviewIndex].comments !=
                  current.reviews[currentReviewIndex].comments;
        }
        return false;
      },
      builder: (context, state) {
        // Encontrar la reseña actualizada o usar la original.
        final currentReview = state is FeedLoaded
            ? state.reviews.firstWhere(
                (r) => r.idReview == review.idReview,
                orElse: () =>
                    review, // Usa la reseña original si no se encuentra.
              )
            : review;

        return Scaffold(
          body: Container(
              width: double.maxFinite,
              height: double.maxFinite,
              child: Stack(
                children: [
                  ReviewExtendedWidget(
                    review: currentReview,
                    onLike: onLike,
                    onComment: onComment,
                    onFollowUser: onFollowUser,
                  ),
                  Container(
                    width: double.maxFinite,
                    height: 96,
                    padding: EdgeInsets.only(top: 32),
                    decoration: BoxDecoration(color: Colors.white),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 16, right: 8),
                            child: Icon(FeatherIcons.arrowLeft),
                          ),
                          Text(
                            "Hilo",
                            style: TextStyle(fontFamily: 'Montserrat'),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              )),
        );
      },
    );
  }
}
