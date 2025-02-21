import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routinepal/src/completion_history/bloc/completion_history_bloc.dart';
import 'package:routinepal/src/completion_history/view/history_chart.dart';
import 'package:routinepal_manager/routinepal_manager.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late final CompletionHistoryBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = CompletionHistoryBloc(
        RepositoryProvider.of<RoutinepalManager>(context));
  }

  @override
  Widget build(BuildContext context) {
    _bloc.add(CompletionHistoryLoadRequested());

    return BlocBuilder<CompletionHistoryBloc, CompletionHistoryState>(
      bloc: _bloc,
      builder: (context, state) {
        switch (state) {
          case CompletionHistoryInitial():
            return Container();
          case CompletionHistoryLoading():
            return const Center(child: CircularProgressIndicator());
          case CompletionHistoryLoaded():
            return ListView(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: HistoryChart(
                    taskCompletionsByDate: state.completions,
                    tasks: state.allTaskNames,
                  ),
                ),
              ],
            );
        }
      },
    );
  }
}
