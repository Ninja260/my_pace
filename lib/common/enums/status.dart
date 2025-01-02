import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum Status {
  needStart,
  coding,
  shortBreak,
  longBreak;

  String get longText {
    switch (this) {
      case Status.needStart:
        return "Let's start coding!";
      case Status.coding:
        return 'Coding...';
      case Status.shortBreak:
        return 'Taking a break...';
      case Status.longBreak:
        return 'Taking a long break...';
    }
  }

  String get shortText {
    switch (this) {
      case Status.needStart:
        return 'Need Start';
      case Status.coding:
        return 'Coding';
      case Status.shortBreak:
        return 'Short Break';
      case Status.longBreak:
        return 'Long Break';
    }
  }
}