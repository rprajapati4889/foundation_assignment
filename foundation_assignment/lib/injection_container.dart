import 'package:dio/dio.dart';
import 'package:foundation_assignment/features/data/repositories/series_repositoty_impl.dart';
import 'package:foundation_assignment/features/domain/repository/seriesrepository.dart';
import 'package:foundation_assignment/features/domain/usecases/get_all_charcacter_detail.dart';
import 'package:foundation_assignment/features/domain/usecases/get_all_episode_details.dart';
import 'package:foundation_assignment/features/domain/usecases/get_all_episode_usecase.dart';
import 'package:foundation_assignment/features/presentation/cubit/episodes_cubit.dart';
import 'package:foundation_assignment/features/presentation/cubit/series_cubit.dart';
import 'package:get_it/get_it.dart';

import 'features/data/data_sources/remote/breakingbad_data_source.dart';
import 'features/data/data_sources/remote/breakingbad_data_source_impl.dart';
import 'features/domain/usecases/get_all_series_usecase.dart';
import 'features/presentation/cubit/character_details_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // cubit
  sl.registerFactory<SeriesCubit>(() => SeriesCubit(
        getAllSeriesUseCase: sl.call(),
      ));
  sl.registerFactory<EpisodesCubit>(
      () => EpisodesCubit(getAllEpisodeUseCase: sl.call()));
  sl.registerFactory<CharacterDetailsCubit>(() => CharacterDetailsCubit(
      getAllEpisodesDetailsUseCase: sl.call(),
      getAllCharactersDetailsUseCase: sl.call()));

  //usecases
  sl.registerLazySingleton<GetAllSeriesUseCase>(
      () => GetAllSeriesUseCase(repository: sl.call()));
  sl.registerLazySingleton<GetAllEpisodeUseCase>(
      () => GetAllEpisodeUseCase(repository: sl.call()));
  sl.registerLazySingleton<GetAllEpisodesDetailsUseCase>(
      () => GetAllEpisodesDetailsUseCase(repository: sl.call()));
  sl.registerLazySingleton<GetAllCharactersDetailsUseCase>(
      () => GetAllCharactersDetailsUseCase(repository: sl.call()));

  //repository
  sl.registerLazySingleton<SeriesRepository>(
      () => SeriesRepositoryImpl(remoteDataSource: sl.call()));

  //data source
  sl.registerLazySingleton<BreakingBadRemoteDataSource>(
      () => BreakingBadRemoteDataSourceImpl());
}
