import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routinepal/src/app/bloc/app_bloc.dart';
import 'package:routinepal/src/app/view/main_screen.dart';
import 'package:routinepal/src/first_time_setup/model/first_time_setup_info.dart';
import 'package:routinepal/src/first_time_setup/view/pages/name_page.dart';
import 'package:routinepal/src/first_time_setup/view/pages/sleep_cycle_page.dart';
import 'package:routinepal/src/first_time_setup/view/pages/thank_you_page.dart';
import 'package:routinepal/src/first_time_setup/view/pages/welcome_page.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  int _currentPage = 0;
  static const int _maxPages = 3;
  final FirstTimeSetupInfo _setupInfo = FirstTimeSetupInfo();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _currentPage != 0
          ? AppBar(
              centerTitle: true,
              title: SizedBox(
                width: 200,
                child: LinearProgressIndicator(
                  value: _currentPage / _maxPages,
                ),
              ),
            )
          : null,
      body: PopScope(
        canPop: _currentPage == 0,
        onPopInvokedWithResult: (didPop, result) {
          setState(() {
            if (_currentPage > 0) _currentPage--;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              Expanded(
                child: switch (_currentPage) {
                  0 => WelcomePage(onNext: _nextPage),
                  1 => NamePage(
                      initialName: _setupInfo.name,
                      onNext: (name) {
                        _setupInfo.name = name;
                        _nextPage();
                      },
                    ),
                  2 => SleepCyclePage(
                      initialSleepTime: _setupInfo.sleepTime,
                      initialWakeUpTime: _setupInfo.wakeUpTime,
                      onNext: (wakeUpTime, sleepTime) {
                        _setupInfo.wakeUpTime = wakeUpTime;
                        _setupInfo.sleepTime = sleepTime;
                        _nextPage();
                      },
                    ),
                  _ => ThankYouPage(onNext: _finishSetup),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _nextPage() {
    setState(() {
      _currentPage++;
    });
  }

  void _finishSetup() {
    BlocProvider.of<AppBloc>(context).add(AppSetupFinished(_setupInfo));
  }
}
