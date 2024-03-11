import 'package:equatable/equatable.dart';
import 'package:w_app/models/ad_model.dart';
import 'package:w_app/models/comment_model.dart';
import 'package:w_app/models/review_model.dart';

// Feed States
abstract class FeedState extends Equatable {}

class FeedLoading extends FeedState {
  @override
  List<Object> get props => [];
}

class FeedLoaded extends FeedState {
  final List<dynamic> reviews;

  FeedLoaded(this.reviews);

  // Método para añadir una nueva reseña
  void addReview(dynamic review) {
    if (review is Review) {
      reviews.add(review); // Agregar la reseña solo si es del tipo Review
    } else {
      // Manejar el caso en que el objeto no sea del tipo Review
      print("El objeto no es una instancia de Review");
    }
  }

  // Método para actualizar una reseña en la lista
  List<dynamic> like(dynamic updatedReview) {
    if (updatedReview is Review) {
      return reviews.map((review) {
        if (review is Review) {
          // Solo actuar sobre elementos que son instancias de Review
          return review.idReview == updatedReview.idReview
              ? updatedReview.copyWith(
                  isLiked: !review.isLiked,
                  likes: review.isLiked ? review.likes - 1 : review.likes + 1,
                )
              : review;
        } else {
          return review; // Devolver el elemento sin cambios si no es Review
        }
      }).toList();
    } else {
      // Manejar el caso en que updatedReview no sea del tipo Review
      print("El objeto actualizado no es una instancia de Review");
      return reviews; // Devolver la lista original sin cambios
    }
  }

  List<dynamic> followUser(String idUser) {
    return reviews.map((review) {
      if (review is Review && review.user.idUser == idUser) {
        // Comprobación de tipo agregada aquí
        return review.copyWith(
            user: review.user.copyWith(followed: !review.user.followed));
      }
      return review;
    }).toList();
  }

  List<dynamic> followBusiness(String idBusiness) {
    return reviews.map((review) {
      if (review is Review && review.business?.idBusiness == idBusiness) {
        // Comprobación de tipo agregada aquí
        return review.copyWith(
            business: review.business!
                .copyWith(followed: !review.business!.followed));
      }
      return review;
    }).toList();
  }

  List<dynamic> addCommentToReview(String reviewId, Comment comment) {
    return reviews.map((review) {
      if (review is Review && review.idReview == reviewId) {
        // Comprobación de tipo agregada aquí
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

  List<dynamic> deleteReview(String reviewId) {
    return reviews
        .where((review) => review is Review && review.idReview != reviewId)
        .toList();
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
