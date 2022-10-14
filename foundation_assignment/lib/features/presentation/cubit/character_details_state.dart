part of 'character_details_cubit.dart';

abstract class CharacterDetailsState extends Equatable {
  const CharacterDetailsState();

  @override
  List<Object> get props => [];
}

class CharacterDetailsInitial extends CharacterDetailsState {}

class CharacterDetailsLoading extends CharacterDetailsState {}

class CharacterDetailsLoaded extends CharacterDetailsState {
  final List<CharacterModel> characterModel;

  const CharacterDetailsLoaded({required this.characterModel});

  @override
  List<Object> get props => [characterModel];
}

class CharacterDetailsFailure extends CharacterDetailsState {
  final String error;

  CharacterDetailsFailure(this.error);

  @override
  List<Object> get props => [error];
}
