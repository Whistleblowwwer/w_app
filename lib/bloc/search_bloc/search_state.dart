// Definir estados
import 'package:equatable/equatable.dart';

abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object> get props => [];
}

class SearchEmpty extends SearchState {}

class Searching extends SearchState {
  final String searchText;
  final List<String> lastSearchs;

  const Searching(this.searchText, this.lastSearchs);

  @override
  List<Object> get props => [searchText, lastSearchs];
}

class Searched extends SearchState {
  final String searchSelection;

  const Searched(this.searchSelection);

  @override
  List<Object> get props => [searchSelection];
}

class SearchError extends SearchState {
  final String error;

  const SearchError(this.error);

  @override
  List<Object> get props => [error];
}
