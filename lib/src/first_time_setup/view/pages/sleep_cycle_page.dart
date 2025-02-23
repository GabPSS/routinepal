import 'package:flutter/material.dart';
import 'package:routinepal/src/first_time_setup/view/next_button.dart';

class SleepCyclePage extends StatefulWidget {
  final TimeOfDay initialWakeUpTime;
  final TimeOfDay initialSleepTime;

  final void Function(TimeOfDay wakeUpTime, TimeOfDay sleepTime) onNext;

  const SleepCyclePage(
      {required this.onNext,
      required this.initialSleepTime,
      required this.initialWakeUpTime,
      super.key});

  @override
  State<SleepCyclePage> createState() => _SleepCyclePageState();
}

class _SleepCyclePageState extends State<SleepCyclePage> {
  late TimeOfDay _wakeUpTime;
  late TimeOfDay _sleepTime;

  @override
  void initState() {
    super.initState();
    _wakeUpTime = widget.initialWakeUpTime;
    _sleepTime = widget.initialSleepTime;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        Text("What are your sleep times?",
            style: Theme.of(context).textTheme.headlineLarge),
        RoutineCard(
          leading: const Icon(Icons.light_mode_outlined),
          title: "Wake up time",
          time: _wakeUpTime,
          onTimeChanged: (newTime) {
            setState(() {
              _wakeUpTime = newTime;
            });
          },
        ),
        RoutineCard(
          leading: const Icon(Icons.bedtime_outlined),
          title: "Sleep time",
          time: _sleepTime,
          onTimeChanged: (newTime) {
            setState(() {
              _sleepTime = newTime;
            });
          },
        ),
        const Spacer(),
        NextButton(onNext: () {
          widget.onNext(_wakeUpTime, _sleepTime);
        }),
      ],
    );
  }
}

class RoutineCard extends StatelessWidget {
  final Widget leading;
  final String title;
  final TimeOfDay time;
  final Function(TimeOfDay newTime) onTimeChanged;

  const RoutineCard({
    required this.leading,
    required this.title,
    required this.time,
    required this.onTimeChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        TimeOfDay? newTime =
            await showTimePicker(context: context, initialTime: time);
        if (newTime != null) {
          onTimeChanged(newTime);
        }
      },
      child: Card.outlined(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListTile(
            leading: leading,
            title: Text(title),
            trailing: Text(time.format(context)),
          ),
        ),
      ),
    );
  }
}
