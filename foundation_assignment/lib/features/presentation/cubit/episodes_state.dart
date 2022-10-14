part of 'episodes_cubit.dart';

@immutable
abstract class EpisodesState extends Equatable {
  const EpisodesState();

  @override
  List<Object?> get props => [];
}

class EpisodesInitial extends EpisodesState {}

class EpisodeLoading extends EpisodesState {}

class EpisodeLoaded extends EpisodesState {
  final List<EpisodeModel> episodeModel;

  EpisodeLoaded({required this.episodeModel});

  @override
  List<Object> get props => [episodeModel];
}

class EpisodeFailure extends EpisodesState {
  final String error;

  EpisodeFailure(this.error);

  @override
  List<Object> get props => [error];
}
