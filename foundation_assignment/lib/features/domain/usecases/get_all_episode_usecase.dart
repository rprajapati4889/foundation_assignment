import 'package:foundation_assignment/features/domain/models/EpisodeModel.dart';
import 'package:foundation_assignment/features/domain/repository/seriesrepository.dart';

class GetAllEpisodeUseCase {
  final SeriesRepository repository;

  GetAllEpisodeUseCase({required this.repository});

  Future<List<EpisodeModel>> call(String seriesName) async {
    return await repository.getAllEpisodes(seriesName);
  }
}
