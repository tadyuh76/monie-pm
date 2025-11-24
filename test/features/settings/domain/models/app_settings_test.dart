import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monie/features/settings/domain/models/app_settings.dart';

void main() {
  group('AppSettings', () {
    test('should create AppSettings with default values', () {
      // Arrange & Act
      const settings = AppSettings();

      // Assert
      expect(settings.notificationsEnabled, true);
      expect(settings.themeMode, ThemeMode.dark);
      expect(settings.language, AppLanguage.english);
      expect(settings.dailyReminderTime, "22:10");
      expect(settings.timeFormat, TimeFormat.twentyFourHour);
      expect(settings.timezone, null);
    });

    test('should create AppSettings with custom values', () {
      // Arrange & Act
      const settings = AppSettings(
        notificationsEnabled: false,
        themeMode: ThemeMode.light,
        language: AppLanguage.vietnamese,
        dailyReminderTime: "08:00",
        timeFormat: TimeFormat.twelveHour,
        timezone: "Asia/Ho_Chi_Minh",
      );

      // Assert
      expect(settings.notificationsEnabled, false);
      expect(settings.themeMode, ThemeMode.light);
      expect(settings.language, AppLanguage.vietnamese);
      expect(settings.dailyReminderTime, "08:00");
      expect(settings.timeFormat, TimeFormat.twelveHour);
      expect(settings.timezone, "Asia/Ho_Chi_Minh");
    });

    test('should correctly copy with new values', () {
      // Arrange
      const originalSettings = AppSettings();

      // Act
      final newSettings = originalSettings.copyWith(
        dailyReminderTime: "09:30",
        timeFormat: TimeFormat.twelveHour,
      );

      // Assert
      expect(newSettings.dailyReminderTime, "09:30");
      expect(newSettings.timeFormat, TimeFormat.twelveHour);
      // Other values should remain the same
      expect(newSettings.notificationsEnabled, originalSettings.notificationsEnabled);
      expect(newSettings.themeMode, originalSettings.themeMode);
      expect(newSettings.language, originalSettings.language);
    });

    test('should serialize to JSON correctly', () {
      // Arrange
      const settings = AppSettings(
        notificationsEnabled: true,
        themeMode: ThemeMode.dark,
        language: AppLanguage.english,
        dailyReminderTime: "22:10",
        timeFormat: TimeFormat.twentyFourHour,
        timezone: "Asia/Ho_Chi_Minh",
      );

      // Act
      final json = settings.toJson();

      // Assert
      expect(json['notificationsEnabled'], true);
      expect(json['themeMode'], ThemeMode.dark.index);
      expect(json['language'], AppLanguage.english.index);
      expect(json['dailyReminderTime'], "22:10");
      expect(json['timeFormat'], TimeFormat.twentyFourHour.index);
      expect(json['timezone'], "Asia/Ho_Chi_Minh");
    });

    test('should deserialize from JSON correctly', () {
      // Arrange
      final json = {
        'notificationsEnabled': false,
        'themeMode': ThemeMode.light.index,
        'language': AppLanguage.vietnamese.index,
        'dailyReminderTime': "08:00",
        'timeFormat': TimeFormat.twelveHour.index,
        'timezone': "Asia/Ho_Chi_Minh",
      };

      // Act
      final settings = AppSettings.fromJson(json);

      // Assert
      expect(settings.notificationsEnabled, false);
      expect(settings.themeMode, ThemeMode.light);
      expect(settings.language, AppLanguage.vietnamese);
      expect(settings.dailyReminderTime, "08:00");
      expect(settings.timeFormat, TimeFormat.twelveHour);
      expect(settings.timezone, "Asia/Ho_Chi_Minh");
    });

    test('should use default values when deserializing from incomplete JSON', () {
      // Arrange
      final json = <String, dynamic>{};

      // Act
      final settings = AppSettings.fromJson(json);

      // Assert
      expect(settings.notificationsEnabled, true);
      expect(settings.themeMode, ThemeMode.dark);
      expect(settings.language, AppLanguage.english);
      expect(settings.dailyReminderTime, "22:10");
      expect(settings.timeFormat, TimeFormat.twentyFourHour);
    });

    test('should correctly handle different time formats', () {
      // Arrange
      const settings12h = AppSettings(timeFormat: TimeFormat.twelveHour);
      const settings24h = AppSettings(timeFormat: TimeFormat.twentyFourHour);

      // Assert
      expect(settings12h.timeFormat, TimeFormat.twelveHour);
      expect(settings24h.timeFormat, TimeFormat.twentyFourHour);
    });

    test('should validate reminder time format', () {
      // Arrange & Act
      const morning = AppSettings(dailyReminderTime: "08:30");
      const afternoon = AppSettings(dailyReminderTime: "14:45");
      const evening = AppSettings(dailyReminderTime: "22:10");

      // Assert
      expect(morning.dailyReminderTime, matches(r'^\d{2}:\d{2}$'));
      expect(afternoon.dailyReminderTime, matches(r'^\d{2}:\d{2}$'));
      expect(evening.dailyReminderTime, matches(r'^\d{2}:\d{2}$'));
    });
  });
}


