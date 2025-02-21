import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:routinepal/src/app/view/dialogs/fulfillment_confirmation_dialog.dart';

class TimerFulfillmentWidget extends StatefulWidget {
  final int? minDurationMinutes;
  final int? maxDurationMinutes;
  final Function()? onFulfillmentSuccessful;
  final Function()? onFulfillmentFailed;
  final Function()? onTimerStarted;

  const TimerFulfillmentWidget({
    required this.minDurationMinutes,
    required this.maxDurationMinutes,
    this.onFulfillmentFailed,
    this.onFulfillmentSuccessful,
    this.onTimerStarted,
    super.key,
  });

  @override
  State<TimerFulfillmentWidget> createState() => _TimerFulfillmentWidgetState();
}

class _TimerFulfillmentWidgetState extends State<TimerFulfillmentWidget> {
  int totalSecondsElapsed = 0;

  int maxWithTolerance = 0;
  int maxSeconds = 0;
  int minWithTolerance = 0;
  int minSeconds = 0;

  bool get isFulfillable => totalSecondsElapsed >= minWithTolerance;
  bool get isBeyondMax =>
      maxSeconds != 0 ? totalSecondsElapsed >= maxSeconds : false;

  int getTolerance(int value) => switch (value) {
        <= 120 => 30,
        <= 300 => 60,
        <= 600 => 120,
        <= 1800 => 300,
        _ => 600
      };

  String get timeText =>
      "${totalSecondsElapsed ~/ 60}:${(totalSecondsElapsed % 60).toString().padLeft(2, '0')}";
  late double Function(int) getProgress;

  Timer? timer;
  bool get isRunning => timer != null;

  @override
  void initState() {
    super.initState();
    if (widget.minDurationMinutes != null) {
      minSeconds = widget.minDurationMinutes! * 60;
      getProgress = (totalSeconds) => totalSeconds / minSeconds;
      minWithTolerance = minSeconds - getTolerance(minSeconds);
    }
    if (widget.maxDurationMinutes != null) {
      maxSeconds = widget.maxDurationMinutes! * 60;
      getProgress = (totalSeconds) => totalSeconds / maxSeconds;
      maxWithTolerance = maxSeconds + getTolerance(maxSeconds);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Text("Timer:"),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: min(MediaQuery.of(context).size.width - 128, 350),
                height: min(MediaQuery.of(context).size.width - 128, 350),
                child: CircularProgressIndicator(
                  strokeWidth: 5,
                  strokeCap: StrokeCap.round,
                  value: isRunning ? getProgress(totalSecondsElapsed) : 1,
                  color: isRunning ? getColor() : Colors.grey,
                  backgroundColor: Colors.grey[300],
                ),
              ),
              Text(
                timeText,
                textScaler: const TextScaler.linear(3),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            spacing: 8,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!isRunning)
                FilledButton.icon(
                  onPressed: startTimer,
                  icon: const Icon(Icons.directions_run),
                  label:
                      const Text('Start', textScaler: TextScaler.linear(1.5)),
                ),
              if (isRunning)
                FilledButton.tonalIcon(
                  onPressed: cancelTimer,
                  icon: const Icon(Icons.cancel),
                  label:
                      const Text("Cancel", textScaler: TextScaler.linear(1.5)),
                ),
              if (isRunning && isFulfillable)
                FilledButton.icon(
                  onPressed: fulfilTask,
                  icon: const Icon(Icons.check),
                  label:
                      const Text("Fulfill", textScaler: TextScaler.linear(1.5)),
                ),
            ],
          ),
        ),
      ],
    );
  }

  void startTimer() {
    if (!isRunning) {
      timer = Timer.periodic(const Duration(seconds: 1),
          maxSeconds != 0 ? tickWhenMaxIsSet : tickWhenMaxIsNotSet);
    }
    setState(() {});
    widget.onTimerStarted?.call();
  }

  void tickWhenMaxIsSet(timer) {
    if (totalSecondsElapsed >= maxWithTolerance) {
      timer.cancel();
      this.timer = null;
      widget.onFulfillmentFailed?.call();
    } else {
      totalSecondsElapsed++;
    }
    setState(() {});
  }

  void tickWhenMaxIsNotSet(Timer timer) {
    totalSecondsElapsed++;
    setState(() {});
  }

  Future<void> cancelTimer() async {
    bool isCancelConfirmed = await showFulfillmentAlertDialog(context,
            isFulfillmentAttempted: false) ??
        false;
    if (isCancelConfirmed) {
      timer?.cancel();
      timer = null;
      totalSecondsElapsed = 0;
      widget.onFulfillmentFailed?.call();
      setState(() {});
    }
  }

  void fulfilTask() async {
    if (await showFulfillmentAlertDialog(context) == true) {
      timer?.cancel();
      timer = null;
      totalSecondsElapsed = 0;
      widget.onFulfillmentSuccessful?.call();
      setState(() {});
    }
  }

  Color getColor() {
    if (isBeyondMax) return Colors.red;
    if (isFulfillable) return Colors.green;
    return Colors.blue;
  }
}
