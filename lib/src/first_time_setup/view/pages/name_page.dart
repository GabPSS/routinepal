import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:routinepal/src/first_time_setup/view/next_button.dart';

class NamePage extends StatefulWidget {
  final String initialName;

  final Function(String name) onNext;

  const NamePage({required this.onNext, super.key, required this.initialName});

  @override
  State<NamePage> createState() => _NamePageState();
}

class _NamePageState extends State<NamePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late String _name;

  @override
  void initState() {
    super.initState();
    _name = widget.initialName;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          Text('What is your name?',
              style: Theme.of(context).textTheme.headlineLarge),
          TextFormField(
            initialValue: _name,
            inputFormatters: [
              FilteringTextInputFormatter.deny(RegExp(r'\s')),
            ],
            maxLength: 50,
            validator: (value) =>
                value?.isNotEmpty ?? false ? null : 'Please enter your name',
            onFieldSubmitted: (name) {
              if (_formKey.currentState?.validate() ?? false) {
                widget.onNext(name);
              }
            },
            onChanged: (newName) {
              _name = newName;
            },
            decoration: InputDecoration(
              hintText: "John",
              helperText:
                  "Use your first name, we'll call you this in the app.",
            ),
          ),
          Spacer(),
          if (widget.initialName.isNotEmpty)
            NextButton(
              onNext: () {
                if (_formKey.currentState?.validate() ?? false) {
                  widget.onNext(_name);
                }
              },
            )
        ],
      ),
    );
  }
}
