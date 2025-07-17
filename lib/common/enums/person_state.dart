import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum PersonState {
  needStart,
  coding,
  shortBreak,
  longBreak;

  String get longText {
    switch (this) {
      case PersonState.needStart:
        return "Let's start coding!";
      case PersonState.coding:
        return 'Coding';
      case PersonState.shortBreak:
        return 'Taking a break';
      case PersonState.longBreak:
        return 'Taking a long break';
    }
  }

  String get shortText {
    switch (this) {
      case PersonState.needStart:
        return 'Need Start';
      case PersonState.coding:
        return 'Coding';
      case PersonState.shortBreak:
        return 'Short Break';
      case PersonState.longBreak:
        return 'Long Break';
    }
  }
}
