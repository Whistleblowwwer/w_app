import 'package:equatable/equatable.dart';
import 'package:w_app/models/comment_model.dart';
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

  // Método para añadir una nueva reseña
  void addReview(Review review) {
    reviews.add(review); // Agregar la reseña directamente a la lista existente
  }

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
    // Verificamos si el usuario en la reseña actualizada está siendo seguido o no
    bool isFollowing = updatedReview.user.followed;

    // Actualizamos todas las reseñas que pertenecen al mismo usuario
    return reviews.map((review) {
      if (review.user.idUser == updatedReview.user.idUser) {
        // Si el usuario coincide, cambiamos el estado de 'followed'
        return review.copyWith(
            user: review.user.copyWith(followed: !isFollowing));
      }
      return review;
    }).toList();
  }

  List<Review> followBusiness(String idBusiness) {
    // Verificamos si el negocio en la reseña actualizada está siendo seguido o no

    // Actualizamos todas las reseñas que pertenecen al mismo negocio
    return reviews.map((review) {
      if (review.business?.idBusiness == idBusiness) {
        // Si el negocio coincide, cambiamos el estado de 'followed'
        return review.copyWith(
            business: review.business!
                .copyWith(followed: !review.business!.followed));
      }
      return review;
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

  List<Review> deleteReview(String reviewId) {
    // Filtramos las reseñas para excluir la que queremos eliminar
    return reviews.where((review) => review.idReview != reviewId).toList();
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
