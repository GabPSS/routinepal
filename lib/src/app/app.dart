import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routinepal/src/app/bloc/app_bloc.dart';
import 'package:routinepal/src/first_time_setup/view/setup_screen.dart';
import 'package:routinepal/src/app/view/main_screen.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<AppBloc>(context).add(AppLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          colorSchemeSeed: Colors.cyan,
          textTheme: const TextTheme(
            bodyMedium: TextStyle(fontSize: 16.0),
          )),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 32, 0, 212),
          brightness: Brightness.dark,
        ),
      ),
      home: BlocBuilder<AppBloc, AppState>(
        builder: (context, state) {
          return switch (state) {
            AppInitial() => const Scaffold(),
            AppLoading() => const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
            AppSetup() => const SetupScreen(),
            AppReady() => const MainScreen()
          };
        },
      ),
    );
  }
}
