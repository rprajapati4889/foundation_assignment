import 'dart:convert';

import 'package:foundation_assignment/features/domain/models/CharacterModel.dart';
import 'package:foundation_assignment/features/domain/models/EpisodeDetail.dart';
import 'package:foundation_assignment/features/domain/models/EpisodeModel.dart';
import 'package:foundation_assignment/features/domain/models/SeriesModel.dart';

import 'package:http/http.dart' as http;

import 'breakingbad_data_source.dart';

class BreakingBadRemoteDataSourceImpl implements BreakingBadRemoteDataSource {
  @override
  Future<List<SeriesModel>> getAllSeries() async {
    try {
      final response = await http
          .get(Uri.parse('https://breakingbadapi.com/api/episodes?series'));

      if (response.statusCode == 200) {
        List<SeriesModel> list = [];
        var res = jsonDecode(response.body);
        res.forEach((element) {
          list.add(SeriesModel.fromJson(element));
        });
        return list;
      }
      return Future.error("Error to display series");
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<List<EpisodeModel>> getAllEpisode(String seriesName) async {
    try {
      final response = await http.get(
          Uri.parse("https://breakingbadapi.com/api/episodes")
              .replace(queryParameters: {"series": seriesName}));

      if (response.statusCode == 200) {
        List<EpisodeModel> episodeList = [];
        var res = jsonDecode(response.body);
        res.forEach((element) {
          episodeList.add(EpisodeModel.fromJson(element));
        });
        return episodeList;
      }
      return Future.error("Error to display episode");
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<List<EpisodeDetail>> getEpisodeDetails(String episodeId) async {
    try {
      final response = await http.get(
          Uri.parse("https://www.breakingbadapi.com/api/episodes")
              .replace(queryParameters: {"": episodeId}));

      if (response.statusCode == 200) {
        List<EpisodeDetail> result = [];
        var res = jsonDecode(response.body);
        res.forEach((element) {
          result.add(EpisodeDetail.fromJson(element));
        });
        return result;
      }
      return Future.error("Error to display episode details");
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<List<CharacterModel>> getCharacterDetail() async {
    try {
      final response = await http
          .get(Uri.parse("https://breakingbadapi.com/api/characters"));

      if (response.statusCode == 200) {
        List<CharacterModel> rsult = [];
        var res = jsonDecode(response.body);
        res.forEach((element) {
          rsult.add(CharacterModel.fromJson(element));
        });
        return rsult;
      }
      return Future.error("Error to display characters details");
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
