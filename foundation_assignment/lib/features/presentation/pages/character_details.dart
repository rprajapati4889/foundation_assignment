import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foundation_assignment/features/domain/models/CharacterModel.dart';
import '../../../injection_container.dart' as di;
import '../cubit/character_details_cubit.dart';

class CharacterDetailsPage extends StatelessWidget {
  CharacterDetailsPage({Key? key, required this.episodeId}) : super(key: key);
  final String episodeId;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text('CharactersDetail'),
          ),
          body: BlocProvider(
              create: (_) => di.sl<CharacterDetailsCubit>(),
              child: BlocBuilder<CharacterDetailsCubit, CharacterDetailsState>(
                  builder: (context, state) {
                if (state is CharacterDetailsInitial) {
                  BlocProvider.of<CharacterDetailsCubit>(context)
                      .getCharactersDetails(episodeId);
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (state is CharacterDetailsLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (state is CharacterDetailsLoaded) {
                  var character = state.characterModel;
                  return _buildCharacterList(character);
                } else {
                  return const Center(
                    child: Text("Couldn't load data"),
                  );
                }
              }))),
    );
  }

  Widget _buildCharacterList(List<CharacterModel> character) {
    return GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, mainAxisSpacing: 10, crossAxisSpacing: 10),
        itemCount: character.length,
        itemBuilder: (context, index) {
          return Container(
            padding: const EdgeInsets.only(left: 10),
            decoration: BoxDecoration(
                color: Colors.blueGrey,
                borderRadius: BorderRadius.circular(15)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  'Name - ${character[index].name!}',
                  style: const TextStyle(color: Colors.black54, fontSize: 15),
                ),
                Text('Birthdate - ${character[index].birthday!}'),
                Text('NickName - ${character[index].nickname}'),
                Text('Status - ${character[index].status}'),
                Text('Occupation - ${character[index].occupation}')
              ],
            ),
          );
        });
  }
}
