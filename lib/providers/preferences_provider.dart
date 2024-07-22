import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesProvider with ChangeNotifier {
  bool _isDarkMode = false;
  String _sortOrder = 'title';

  bool get isDarkMode => _isDarkMode;
  String get sortOrder => _sortOrder;

  PreferencesProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _sortOrder = prefs.getString('sortOrder') ?? 'title';
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
    notifyListeners();
  }

  Future<void> setSortOrder(String value) async {
    _sortOrder = value;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('sortOrder', value);
    notifyListeners();
  }
}
