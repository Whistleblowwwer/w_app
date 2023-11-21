import 'package:equatable/equatable.dart';
import 'package:w_app/models/review_model.dart';

// Feed States
abstract class FeedState extends Equatable {}

class FeedLoading extends FeedState {
  @override
  List<Object> get props => [];
}

class FeedLoaded extends FeedState {
  final List<Review> reviews;

  FeedLoaded(this.reviews);

  // Método para actualizar una reseña en la lista
  List<Review> like(Review updatedReview) {
    // Implementamos el método updateReview para actualizar la lista de reseñas.
    return reviews.map((review) {
      return review.idReview == updatedReview.idReview
          ? updatedReview.copyWith(
              isLiked: !review.isLiked,
              likes: review.isLiked ? review.likes - 1 : review.likes + 1,
            )
          : review;
    }).toList();
  }

  List<Review> followUser(Review updatedReview) {
    // Implementamos el método updateReview para actualizar la lista de reseñas.
    return reviews.map((review) {
      return review.idReview == updatedReview.idReview
          ? updatedReview.copyWith(
              user: review.user.copyWith(followed: !review.user.followed))
          : review;
    }).toList();
  }

  List<Review> addCommentToReview(String reviewId, Comment comment) {
    return reviews.map((review) {
      if (review.idReview == reviewId) {
        final updatedCommentsList = List<Comment>.from(review.children ?? [])
          ..add(comment);
        return review.copyWith(
          children: updatedCommentsList,
          comments: review.comments + 1,
        );
      }
      return review;
    }).toList();
  }

  @override
  List<Object> get props => [reviews];
}

class FeedError extends FeedState {
  final String error;

  FeedError(this.error);

  @override
  List<Object> get props => [error];
}

class FeedTokenError extends FeedState {
  final String error;

  FeedTokenError(this.error);
  @override
  List<Object> get props => [error];
}
