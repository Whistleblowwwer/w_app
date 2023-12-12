import 'package:equatable/equatable.dart';
import 'package:w_app/models/comment_model.dart';
import 'package:w_app/models/review_model.dart';

// User Events
abstract class FeedBlocEvent extends Equatable {}

class InitialFeedReviews extends FeedBlocEvent {
  InitialFeedReviews();

  @override
  List<Object> get props => [];
}

class FetchFeedReviews extends FeedBlocEvent {
  FetchFeedReviews();

  @override
  List<Object> get props => [];
}

class AddReview extends FeedBlocEvent {
  final Review review;

  AddReview(this.review);

  @override
  List<Object> get props => [review];
}

class DeleteReview extends FeedBlocEvent {
  final String reviewId;

  DeleteReview(this.reviewId);

  @override
  List<Object?> get props => [reviewId];
}

class LikeReview extends FeedBlocEvent {
  final Review review;

  LikeReview(this.review);

  @override
  List<Object> get props => [review];
}

class FollowUser extends FeedBlocEvent {
  final Review review;

  FollowUser(this.review);

  @override
  List<Object> get props => [review];
}

class FollowBusiness extends FeedBlocEvent {
  final String idBusiness;

  FollowBusiness(this.idBusiness);

  @override
  List<Object> get props => [idBusiness];
}

class AddComment extends FeedBlocEvent {
  final String reviewId;
  final Comment comment;

  AddComment({required this.reviewId, required this.comment});

  @override
  List<Object> get props => [reviewId, comment];
}
