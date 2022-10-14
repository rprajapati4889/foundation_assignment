import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foundation_assignment/features/data/data_sources/remote/breakingbad_data_source_impl.dart';
import 'package:foundation_assignment/features/domain/models/EpisodeModel.dart';
import 'package:foundation_assignment/features/presentation/cubit/episodes_cubit.dart';
import 'package:foundation_assignment/features/presentation/pages/character_details.dart';

import '../../../injection_container.dart' as di;

class EpisodeListPage extends StatelessWidget {
  EpisodeListPage({Key? key, required this.seriesName}) : super(key: key);
  final String seriesName;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text('EpisodeList'),
          ),
          body: BlocProvider(
              create: (_) => di.sl<EpisodesCubit>(),
              child: BlocBuilder<EpisodesCubit, EpisodesState>(
                  builder: (context, state) {
                if (state is EpisodesInitial) {
                  BlocProvider.of<EpisodesCubit>(context)
                      .getAllEpisode(seriesName);
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (state is EpisodeLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (state is EpisodeLoaded) {
                  var episodes = state.episodeModel;
                  return _buildEpisodeList(episodes);
                } else {
                  print(state.toString());
                  return const Center(child: Text("Couldn't load data"));
                }
              }))),
    );
  }

  Widget _buildEpisodeList(List<EpisodeModel> episodes) {
    return GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, mainAxisSpacing: 10, crossAxisSpacing: 10),
        itemCount: episodes.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CharacterDetailsPage(
                          episodeId: episodes[index].episodeId.toString())));
            },
            child: Container(
              padding: const EdgeInsets.only(left: 10),
              decoration: BoxDecoration(
                  color: Colors.blueGrey,
                  borderRadius: BorderRadius.circular(15)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(episodes[index].series!,
                      style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 20,
                          fontWeight: FontWeight.w400)),
                  Text('Episode - ${episodes[index].episode!}'),
                  Text('title - ${episodes[index].title}'),
                  Text('StarCast - ${episodes[index].characters}')
                ],
              ),
            ),
          );
        });
  }
}
