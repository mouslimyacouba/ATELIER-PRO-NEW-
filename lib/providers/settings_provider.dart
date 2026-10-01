import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  static const String _notifKey = 'notifications_enabled';

  bool _notificationsEnabled = true;

  SettingsProvider() {
    _loadSettings();
  }

  bool get notificationsEnabled => _notificationsEnabled;

  Future<void> setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notifKey, value);
    notifyListeners();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _notificationsEnabled = prefs.getBool(_notifKey) ?? true;
    notifyListeners();
  }
}
