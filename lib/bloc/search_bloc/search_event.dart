// Definir eventos
import 'package:equatable/equatable.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object> get props => [];
}

class SearchTextChanged extends SearchEvent {
  final String searchText;

  const SearchTextChanged(this.searchText);

  @override
  List<Object> get props => [searchText];
}

class SearchCompleted extends SearchEvent {
  final String searchText;
  const SearchCompleted(this.searchText);
  @override
  List<Object> get props => [searchText];
}
