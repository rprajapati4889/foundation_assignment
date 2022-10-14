import 'package:foundation_assignment/features/domain/models/EpisodeDetail.dart';
import 'package:foundation_assignment/features/domain/repository/seriesrepository.dart';

class GetAllEpisodesDetailsUseCase {
  final SeriesRepository repository;

  GetAllEpisodesDetailsUseCase({required this.repository});

  Future<List<EpisodeDetail>> call(String episodeId) async {
    return await repository.getEpisodeDetails(episodeId);
  }
}
