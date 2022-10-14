import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foundation_assignment/features/presentation/cubit/series_cubit.dart';
import 'package:foundation_assignment/injection_container.dart' as di;

import '../../domain/models/SeriesModel.dart';
import 'episode_list_page.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text("BreakingBad"),
          ),
          body: BlocProvider(
            create: (_) => di.sl<SeriesCubit>(),
            child: BlocBuilder<SeriesCubit, SeriesState>(
                builder: (context, state) {
              if (state is SeriesInitial) {
                BlocProvider.of<SeriesCubit>(context).getSeries();
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (state is SeriesLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (state is SeriesSucess) {
                // var series = state.seriesModel;
                return _buildSeriesView(state.seriesModel);
              } else {
                print(state.toString());
                return const Center(
                  child: Text("Couldn't load data"),
                );
              }
            }),
          )),
    );
  }

  Widget _buildSeriesView(List<SeriesModel> series) {
    return GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, mainAxisSpacing: 10, crossAxisSpacing: 10),
        itemCount: series.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EpisodeListPage(
                            seriesName: series[index].series!,
                          )));
            },
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(series[index].series!,
                        style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 20,
                            fontWeight: FontWeight.w400)),
                    Text('Season - ${series[index].season}'),
                    Text(
                      'Date - ${series[index].airDate!}',
                      style:
                          const TextStyle(color: Colors.blueGrey, fontSize: 15),
                    ),
                    Text('Title - ${series[index].title!}')
                  ]),
            ),
          );
        });
  }
}
