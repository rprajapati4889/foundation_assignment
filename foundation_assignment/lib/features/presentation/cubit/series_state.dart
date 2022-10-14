part of 'series_cubit.dart';

@immutable
abstract class SeriesState extends Equatable {
  const SeriesState();

  @override
  List<Object?> get props => [];
}

class SeriesInitial extends SeriesState {}

class SeriesLoading extends SeriesState {}

class SeriesSucess extends SeriesState {
  final List<SeriesModel> seriesModel;

  SeriesSucess({required this.seriesModel});

  @override
  List<Object> get props => [seriesModel];
}

class SeriesFailure extends SeriesState {
  final String error;

  SeriesFailure(this.error);

  @override
  List<Object> get props => [error];
}
