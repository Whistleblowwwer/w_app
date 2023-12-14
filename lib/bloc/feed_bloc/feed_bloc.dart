import 'dart:async';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:w_app/bloc/feed_bloc/feed_event.dart';
import 'package:w_app/bloc/feed_bloc/feed_side_effects.dart';
import 'package:w_app/bloc/feed_bloc/feed_state.dart';
import 'package:w_app/models/comment_model.dart';
import 'package:w_app/models/review_model.dart';
import 'package:w_app/services/api/api_service.dart';

class FeedBloc extends Bloc<FeedBlocEvent, FeedState> {
  final ApiService apiService;
  final sideEffects = StreamController<FeedSideEffect>();

  FeedBloc(this.apiService) : super(FeedLoading()) {
    on<InitialFeedReviews>(_onInitialFeedReviews);
    on<FetchFeedReviews>(_onFetchFeedReviews);
    on<LikeReview>(_onLikeReview);
    on<AddComment>(_onAddComment);
    on<FollowUser>(_onFollowUser);
    on<FollowBusiness>(_onFollowBusiness);
    on<AddReview>(_onAddReview);
    on<DeleteReview>(_onDeleteReview);
  }

  FutureOr<void> _onAddReview(AddReview event, Emitter<FeedState> emit) async {
    final currentState = state;
    if (currentState is FeedLoaded) {
      try {
        final updatedReviews = List<Review>.from(currentState.reviews)
          ..insert(0, event.review);

        print(event.review);
        print(updatedReviews);
        emit(FeedLoaded(updatedReviews));
      } catch (e) {
        emit(FeedError('Failed to add review: ${e.toString()}'));
      }
    }
  }

  FutureOr<void> _onDeleteReview(
      DeleteReview event, Emitter<FeedState> emit) async {
    final currentState = state;
    if (currentState is FeedLoaded) {
      try {
        final updatedReviews = currentState.deleteReview(event.reviewId);
        emit(FeedLoaded(updatedReviews));
      } catch (e) {
        emit(FeedError('Failed to delete review: ${e.toString()}'));
      }
    }
  }

  FutureOr<void> _onInitialFeedReviews(
      InitialFeedReviews event, Emitter<FeedState> emit) async {
    emit(FeedLoading());
    try {
      print("aa");
      final response = await apiService.getReviews();
      emit(FeedLoaded(response));
    } catch (e) {
      if (e.toString().contains('Token is invalid or expired')) {
        print("eeee");
        emit(FeedError(e.toString()));
      } else {
        emit(FeedError(e.toString()));
      }
    }
  }

  FutureOr<void> _onFetchFeedReviews(
      FetchFeedReviews event, Emitter<FeedState> emit) async {
    try {
      print("aa");
      final response = await apiService.getReviews();
      emit(FeedLoaded(response));
    } catch (e) {
      if (e.toString().contains('Token is invalid or expired')) {
        print("eeee");
        emit(FeedError(e.toString()));
      } else {
        emit(FeedError(e.toString()));
      }
    }
  }

  FutureOr<void> _onLikeReview(
      LikeReview event, Emitter<FeedState> emit) async {
    final currentState = state;
    if (currentState is FeedLoaded) {
      final updatedReview = currentState.like(event.review);
      emit(FeedLoaded(updatedReview));
      try {
        final responseCode =
            await apiService.likeReview(idReview: event.review.idReview);

        if (responseCode != 200 && responseCode != 201) {
          emit(FeedLoaded(currentState.reviews));
        }
      } catch (e) {
        emit(FeedLoaded(currentState.reviews));
        // emit(FeedError('Failed to like review: ${e.toString()}'));
      }
    }
  }

  FutureOr<void> _onFollowUser(
      FollowUser event, Emitter<FeedState> emit) async {
    final currentState = state;

    try {
      if (currentState is FeedLoaded) {
        final updatedReview = currentState.followUser(event.review);
        emit(FeedLoaded(updatedReview));
      }
      final responseCode =
          await apiService.followUser(idFollowed: event.review.user.idUser);

      if (responseCode != 200 && responseCode != 201) {
        if (currentState is FeedLoaded) {
          emit(FeedLoaded(currentState.reviews));
        }
      }
    } catch (e) {
      if (currentState is FeedLoaded) {
        emit(FeedLoaded(currentState.reviews));
      }
      // emit(FeedError('Failed to like review: ${e.toString()}'));
    }
  }

  FutureOr<void> _onFollowBusiness(
      FollowBusiness event, Emitter<FeedState> emit) async {
    final currentState = state;
    if (currentState is FeedLoaded) {
      final updatedReview = currentState.followBusiness(event.idBusiness);
      emit(FeedLoaded(updatedReview));
      try {
        final responseCode =
            await apiService.followBusiness(idBusiness: event.idBusiness);

        if (responseCode != 200 && responseCode != 201) {
          emit(FeedLoaded(currentState.reviews));
        }
      } catch (e) {
        emit(FeedLoaded(currentState.reviews));
        // emit(FeedError('Failed to like review: ${e.toString()}'));
      }
    }
  }

  FutureOr<void> _onAddComment(
    AddComment event,
    Emitter<FeedState> emit,
  ) async {
    final currentState = state;

    try {
      if (currentState is FeedLoaded) {
        final updatedReviews =
            currentState.addCommentToReview(event.reviewId, event.comment);
        emit(FeedLoaded(updatedReviews));
      }

      sideEffects.add(AddCommentSideEffect('Comment added!'));
    } catch (e) {
      sideEffects
          .add(AddCommentSideEffect('Unexpected error: ${e.toString()}'));
    }
  }

  // Asegúrate de cerrar el StreamController
  @override
  Future<void> close() {
    sideEffects.close();
    return super.close();
  }
}
