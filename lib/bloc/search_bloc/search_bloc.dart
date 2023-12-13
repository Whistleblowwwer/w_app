// Implementar el Bloc
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:w_app/bloc/search_bloc/search_event.dart';
import 'package:w_app/bloc/search_bloc/search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc() : super(SearchEmpty()) {
    on<SearchTextChanged>((event, emit) {
      if (event.searchText.isEmpty) {
        emit(SearchEmpty());
      } else {
        List<String> cacheSearchs = [
          "Starbucks",
          "Corral",
          "Starb",
          "Sta",
          "Start",
          "Apple"
        ];
        final searchTextLowerTrimmed = event.searchText.toLowerCase().trim();
        final cacheSuggestions = cacheSearchs
            .where((element) =>
                element.toLowerCase().trim().contains(searchTextLowerTrimmed))
            .toList();

        emit(Searching(event.searchText, cacheSuggestions));
      }
    });

    on<SearchCompleted>((event, emit) {
      if (event.searchText.isEmpty) {
        emit(SearchEmpty());
      } else {
        final searchTextLowerTrimmed = event.searchText.toLowerCase().trim();

        emit(Searched(searchTextLowerTrimmed));
      }
    });
  }
}
