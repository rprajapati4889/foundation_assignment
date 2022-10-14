import 'package:foundation_assignment/features/domain/models/SeriesModel.dart';
import 'package:foundation_assignment/features/domain/repository/seriesrepository.dart';

class GetAllSeriesUseCase {
  final SeriesRepository repository;

  GetAllSeriesUseCase({required this.repository});

  Future<List<SeriesModel>> call() async {
    return await repository.getAllSeries();
  }
}
