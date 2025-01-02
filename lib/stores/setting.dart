import 'package:shared_preferences/shared_preferences.dart';

class Setting {
  static final SharedPreferencesAsync _asyncPrefs = SharedPreferencesAsync();

  static Future<int> getCodingDuration() async {
    return await _asyncPrefs.getInt('coding_duration') ?? 25;
  }

  static Future<void> setCodingDuration(int value) async {
    await _asyncPrefs.setInt('coding_duration', value);
  }

  static Future<int> getShortBreakDuration() async {
    return await _asyncPrefs.getInt('short_break_duration') ?? 5;
  }

  static Future<void> setShortBreakDuration(int value) async {
    await _asyncPrefs.setInt('short_break_duration', value);
  }

  static Future<int> getLongBreakDuration() async {
    return await _asyncPrefs.getInt('long_break_duration') ?? 15;
  }

  static Future<void> setLongBreakDuration(int value) async {
    await _asyncPrefs.setInt('long_break_duration', value);
  }

  static Future<int> getShortBreaksBeforeLongBreak() async {
    return await _asyncPrefs.getInt('short_breaks_before_long_break') ?? 3;
  }

  static Future<void> setShortBreaksBeforeLongBreak(int value) async {
    await _asyncPrefs.setInt('short_breaks_before_long_break', value);
  }
}
