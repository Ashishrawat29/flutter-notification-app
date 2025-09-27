import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'alarm_model.dart';

class AlarmProvider extends ChangeNotifier {
  static const String storageKey = 'stored_alarms';

  List<Alarm> _alarms = [];

  List<Alarm> get alarms => List.unmodifiable(_alarms);

  AlarmProvider() {
    _loadAlarmsFromStorage();
  }

  Future<void> _loadAlarmsFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final storedData = prefs.getString(storageKey);
    if (storedData != null) {
      final List decoded = jsonDecode(storedData);
      _alarms = decoded
          .map((json) => Alarm.fromJson(json as Map<String, dynamic>))
          .toList();
      notifyListeners();
    }
  }

  Future<void> _saveAlarmsToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_alarms.map((a) => a.toJson()).toList());
    await prefs.setString(storageKey, encoded);
  }

  void addAlarm(Alarm alarm) {
    _alarms.insert(0, alarm);
    _saveAlarmsToStorage();
    notifyListeners();
  }

  void updateAlarm(Alarm alarm) {
    final index = _alarms.indexWhere((a) => a.id == alarm.id);
    if (index >= 0) {
      _alarms[index] = alarm;
      _saveAlarmsToStorage();
      notifyListeners();
    }
  }

  void removeAlarm(int id) {
    print('Removing alarm with ID: $id from provider.');
    _alarms.removeWhere((a) => a.id == id);
    _saveAlarmsToStorage();
    notifyListeners();
  }

  void removeAlarms(List<int> ids) {
    _alarms.removeWhere((a) => ids.contains(a.id));
    _saveAlarmsToStorage();
    notifyListeners();
  }

  void toggleAlarm(int id) {
    final index = _alarms.indexWhere((a) => a.id == id);
    if (index >= 0) {
      final current = _alarms[index];
      _alarms[index] = current.copyWith(enabled: !current.enabled);
      _saveAlarmsToStorage();
      notifyListeners();
    }
  }
}
