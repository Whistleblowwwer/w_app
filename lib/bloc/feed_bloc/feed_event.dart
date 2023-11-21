import 'package:equatable/equatable.dart';
import 'package:w_app/models/review_model.dart';

// User Events
abstract class FeedBlocEvent extends Equatable {}

class FetchFeedReviews extends FeedBlocEvent {
  FetchFeedReviews();

  @override
  List<Object> get props => [];
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

class AddComment extends FeedBlocEvent {
  final String reviewId;
  final String content;

  AddComment({required this.reviewId, required this.content});

  @override
  List<Object> get props => [reviewId, content];
}
