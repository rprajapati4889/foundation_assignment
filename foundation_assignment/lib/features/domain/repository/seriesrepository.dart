import 'package:foundation_assignment/features/domain/models/CharacterModel.dart';
import 'package:foundation_assignment/features/domain/models/EpisodeDetail.dart';
import 'package:foundation_assignment/features/domain/models/EpisodeModel.dart';
import 'package:foundation_assignment/features/domain/models/SeriesModel.dart';

abstract class SeriesRepository {
  Future<List<SeriesModel>> getAllSeries();

  Future<List<EpisodeModel>> getAllEpisodes(String seriesName);

  Future<List<EpisodeDetail>> getEpisodeDetails(String episodeId);

  Future<List<CharacterModel>> getAllCharacter();
}
