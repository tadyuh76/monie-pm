import 'package:flutter/material.dart';

enum AppLanguage {
  english,
  vietnamese,
}

enum TimeFormat {
  twelveHour,
  twentyFourHour,
}

class AppSettings {
  final bool notificationsEnabled;
  final ThemeMode themeMode;
  final AppLanguage language;
  final String dailyReminderTime; // Format: "HH:mm" (24-hour format)
  final TimeFormat timeFormat;
  final String? timezone; // Device timezone (e.g., "Asia/Ho_Chi_Minh")

  const AppSettings({
    this.notificationsEnabled = true,
    this.themeMode = ThemeMode.dark,
    this.language = AppLanguage.english,
    this.dailyReminderTime = "22:10",
    this.timeFormat = TimeFormat.twentyFourHour,
    this.timezone,
  });

  AppSettings copyWith({
    bool? notificationsEnabled,
    ThemeMode? themeMode,
    AppLanguage? language,
    String? dailyReminderTime,
    TimeFormat? timeFormat,
    String? timezone,
  }) {
    return AppSettings(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      dailyReminderTime: dailyReminderTime ?? this.dailyReminderTime,
      timeFormat: timeFormat ?? this.timeFormat,
      timezone: timezone ?? this.timezone,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'themeMode': themeMode.index,
      'language': language.index,
      'dailyReminderTime': dailyReminderTime,
      'timeFormat': timeFormat.index,
      'timezone': timezone,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      themeMode: ThemeMode.values[json['themeMode'] ?? 2],
      language: AppLanguage.values[json['language'] ?? 0],
      dailyReminderTime: json['dailyReminderTime'] ?? "22:10",
      timeFormat: TimeFormat.values[json['timeFormat'] ?? 1],
      timezone: json['timezone'],
    );
  }
} 