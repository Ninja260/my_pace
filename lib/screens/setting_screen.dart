import 'package:flutter/material.dart';
import 'package:my_pace/stores/setting.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _codingDurationController =
      TextEditingController();
  final TextEditingController _shortBreakDurationController =
      TextEditingController();
  final TextEditingController _shortBreaksBeforeLongBreakController =
      TextEditingController();
  final TextEditingController _longBreakDurationController =
      TextEditingController();

  @override
  void initState() {
    super.initState();

    _loadInitialVales();
  }

  Future<void> _loadInitialVales() async {
    int codingDuration = await Setting.getCodingDuration();
    int shortBreakDuration = await Setting.getShortBreakDuration();
    int shortBreaksBeforeLongBreak =
        await Setting.getShortBreaksBeforeLongBreak();
    int longBreakDuration = await Setting.getLongBreakDuration();

    _codingDurationController.text = codingDuration.toString();
    _shortBreakDurationController.text = shortBreakDuration.toString();
    _shortBreaksBeforeLongBreakController.text =
        shortBreaksBeforeLongBreak.toString();
    _longBreakDurationController.text = longBreakDuration.toString();
  }

  Future<void> _saveSetting() async {
    await Setting.setCodingDuration(int.parse(_codingDurationController.text));
    await Setting.setShortBreakDuration(
        int.parse(_shortBreakDurationController.text));
    await Setting.setShortBreaksBeforeLongBreak(
        int.parse(_shortBreaksBeforeLongBreakController.text));
    await Setting.setLongBreakDuration(
        int.parse(_longBreakDurationController.text));
  }

  @override
  void dispose() {
    _codingDurationController.dispose();
    _shortBreakDurationController.dispose();
    _shortBreaksBeforeLongBreakController.dispose();
    _longBreakDurationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inputSpacer = const SizedBox(height: 8.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Setting'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.always,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _codingDurationController,
                  decoration: const InputDecoration(
                    labelText: 'Coding Duration (minutes)',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a value';
                    }
                    return null;
                  },
                ),
                inputSpacer,
                TextFormField(
                  controller: _shortBreakDurationController,
                  decoration: const InputDecoration(
                    labelText: 'Short Break Duration (minutes)',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a value';
                    }
                    return null;
                  },
                ),
                inputSpacer,
                TextFormField(
                  controller: _shortBreaksBeforeLongBreakController,
                  decoration: const InputDecoration(
                    labelText: 'Numbers of Short Breaks Before Long Break',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a value';
                    }
                    return null;
                  },
                ),
                inputSpacer,
                TextFormField(
                  controller: _longBreakDurationController,
                  decoration: const InputDecoration(
                    labelText: 'Long Break Duration (minutes)',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a value';
                    }
                    return null;
                  },
                ),
                inputSpacer,
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await _saveSetting();
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
