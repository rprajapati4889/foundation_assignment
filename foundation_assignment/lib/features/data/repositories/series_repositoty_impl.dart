import 'dart:async';

import 'package:foundation_assignment/features/domain/models/CharacterModel.dart';
import 'package:foundation_assignment/features/domain/models/EpisodeDetail.dart';
import 'package:foundation_assignment/features/domain/models/EpisodeModel.dart';
import 'package:foundation_assignment/features/domain/models/SeriesModel.dart';
import 'package:foundation_assignment/features/data/data_sources/remote/breakingbad_data_source.dart';
import 'package:foundation_assignment/features/domain/repository/seriesrepository.dart';

class SeriesRepositoryImpl implements SeriesRepository {
  final BreakingBadRemoteDataSource remoteDataSource;

  SeriesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<SeriesModel>> getAllSeries() async {
    return await remoteDataSource.getAllSeries();
  }

  @override
  Future<List<EpisodeModel>> getAllEpisodes(String seriesName) async {
    return await remoteDataSource.getAllEpisode(seriesName);
  }

  @override
  Future<List<EpisodeDetail>> getEpisodeDetails(String episodeId) async {
    return await remoteDataSource.getEpisodeDetails(episodeId);
  }

  @override
  Future<List<CharacterModel>> getAllCharacter() async {
    return await remoteDataSource.getCharacterDetail();
  }
}
