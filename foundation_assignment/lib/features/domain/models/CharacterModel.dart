import 'dart:convert';

/// char_id : 1
/// name : "Walter White"
/// birthday : "09-07-1958"
/// occupation : ["High School Chemistry Teacher","Meth King Pin"]
/// img : "https://images.amcnetworks.com/amc.com/wp-content/uploads/2015/04/cast_bb_700x1000_walter-white-lg.jpg"
/// status : "Presumed dead"
/// nickname : "Heisenberg"
/// appearance : [1,2,3,4,5]
/// portrayed : "Bryan Cranston"
/// category : "Breaking Bad"
/// better_call_saul_appearance : []

CharacterModel characterModelFromJson(String str) =>
    CharacterModel.fromJson(json.decode(str));
String characterModelToJson(CharacterModel data) => json.encode(data.toJson());

class CharacterModel {
  CharacterModel({
    this.charId,
    this.name,
    this.birthday,
    this.occupation,
    this.img,
    this.status,
    this.nickname,
    this.appearance,
    this.portrayed,
    this.category,
  });

  CharacterModel.fromJson(dynamic json) {
    charId = json['char_id'];
    name = json['name'];
    birthday = json['birthday'];
    occupation =
        json['occupation'] != null ? json['occupation'].cast<String>() : [];
    img = json['img'];
    status = json['status'];
    nickname = json['nickname'];
    appearance =
        json['appearance'] != null ? json['appearance'].cast<int>() : [];
    portrayed = json['portrayed'];
    category = json['category'];
  }
  int? charId;
  String? name;
  String? birthday;
  List<String>? occupation;
  String? img;
  String? status;
  String? nickname;
  List<int>? appearance;
  String? portrayed;
  String? category;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['char_id'] = charId;
    map['name'] = name;
    map['birthday'] = birthday;
    map['occupation'] = occupation;
    map['img'] = img;
    map['status'] = status;
    map['nickname'] = nickname;
    map['appearance'] = appearance;
    map['portrayed'] = portrayed;
    map['category'] = category;
    return map;
  }
}
