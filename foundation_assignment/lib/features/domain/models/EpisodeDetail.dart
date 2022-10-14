import 'dart:convert';

/// episode_id : 1
/// title : "Pilot"
/// season : "1"
/// air_date : "01-20-2008"
/// characters : ["Walter White","Jesse Pinkman","Skyler White","Hank Schrader","Marie Schrader","Walter White Jr.","Krazy-8","Bogdan Wolynetz"]
/// episode : "1"
/// series : "Breaking Bad"

EpisodeDetail episodeDetailFromJson(String str) =>
    EpisodeDetail.fromJson(json.decode(str));
String episodeDetailToJson(EpisodeDetail data) => json.encode(data.toJson());

class EpisodeDetail {
  EpisodeDetail({
    this.episodeId,
    this.title,
    this.season,
    this.airDate,
    this.characters,
    this.episode,
    this.series,
  });

  EpisodeDetail.fromJson(dynamic json) {
    episodeId = json['episode_id'];
    title = json['title'];
    season = json['season'];
    airDate = json['air_date'];
    characters =
        json['characters'] != null ? json['characters'].cast<String>() : [];
    episode = json['episode'];
    series = json['series'];
  }
  int? episodeId;
  String? title;
  String? season;
  String? airDate;
  List<String>? characters;
  String? episode;
  String? series;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['episode_id'] = episodeId;
    map['title'] = title;
    map['season'] = season;
    map['air_date'] = airDate;
    map['characters'] = characters;
    map['episode'] = episode;
    map['series'] = series;
    return map;
  }
}
