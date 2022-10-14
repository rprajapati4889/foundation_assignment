import 'package:foundation_assignment/features/domain/models/CharacterModel.dart';
import 'package:foundation_assignment/features/domain/repository/seriesrepository.dart';

class GetAllCharactersDetailsUseCase {
  final SeriesRepository repository;

  GetAllCharactersDetailsUseCase({required this.repository});

  Future<List<CharacterModel>> call() async {
    return await repository.getAllCharacter();
  }
}
