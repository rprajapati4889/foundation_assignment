import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:foundation_assignment/features/domain/usecases/get_all_charcacter_detail.dart';
import 'package:foundation_assignment/features/domain/usecases/get_all_episode_details.dart';

import '../../domain/models/CharacterModel.dart';

part 'character_details_state.dart';

class CharacterDetailsCubit extends Cubit<CharacterDetailsState> {
  final GetAllEpisodesDetailsUseCase getAllEpisodesDetailsUseCase;
  final GetAllCharactersDetailsUseCase getAllCharactersDetailsUseCase;

  CharacterDetailsCubit(
      {required this.getAllEpisodesDetailsUseCase,
      required this.getAllCharactersDetailsUseCase})
      : super(CharacterDetailsInitial());

  getCharactersDetails(String episodeId) async {
    emit(CharacterDetailsLoading());
    try {
      var episodeDetailList =
          await getAllEpisodesDetailsUseCase.call(episodeId);
      var allCharList = await getAllCharactersDetailsUseCase.call();
      List<String> charNameList = [];
      List<CharacterModel> finalList = [];
      for (var element in episodeDetailList) {
        for (var element in element.characters!) {
          charNameList.add(element);
        }
      }

      for (var element in allCharList) {
        for (var name in charNameList) {
          if (name == element.name) {
            finalList.add(CharacterModel(
                name: element.name,
                birthday: element.birthday,
                status: element.status,
                nickname: element.nickname,
                category: element.category,
                occupation: element.occupation));
          }
        }
      }

      emit(CharacterDetailsLoaded(characterModel: finalList));
    } catch (e) {
      emit(CharacterDetailsFailure("Failed to load Episode"));
    }
  }
}
