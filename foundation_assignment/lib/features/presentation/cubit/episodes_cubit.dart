import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:foundation_assignment/features/domain/models/EpisodeModel.dart';
import 'package:foundation_assignment/features/domain/usecases/get_all_episode_usecase.dart';
import 'package:meta/meta.dart';

part 'episodes_state.dart';

class EpisodesCubit extends Cubit<EpisodesState> {
  final GetAllEpisodeUseCase getAllEpisodeUseCase;

  EpisodesCubit({required this.getAllEpisodeUseCase})
      : super(EpisodesInitial());

  getAllEpisode(String seriesName) async {
    emit(EpisodeLoading());
    try {
      var allEpisode = await getAllEpisodeUseCase.call(seriesName);
      emit(EpisodeLoaded(episodeModel: allEpisode));
    } catch (e) {
      emit(EpisodeFailure("Failed to load Episode"));
    }
  }
}
