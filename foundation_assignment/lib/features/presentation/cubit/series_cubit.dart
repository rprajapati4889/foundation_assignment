import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:foundation_assignment/features/domain/models/SeriesModel.dart';
import 'package:meta/meta.dart';

import '../../domain/usecases/get_all_series_usecase.dart';

part 'series_state.dart';

class SeriesCubit extends Cubit<SeriesState> {
  final GetAllSeriesUseCase getAllSeriesUseCase;
  SeriesCubit({required this.getAllSeriesUseCase}) : super(SeriesInitial());

  getSeries() async {
    emit(SeriesLoading());
    try {
      final allSeries = await getAllSeriesUseCase.call();
      emit(SeriesSucess(seriesModel: allSeries));
    } catch (e) {
      emit(SeriesFailure("Failed to load series"));
    }
  }
}
