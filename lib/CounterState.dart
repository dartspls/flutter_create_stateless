import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CounterState with ChangeNotifier {
  static const _sharedPrefsKey = 'counterState';

  int _value;
  int get value => _value;

  // transient state - will not be stored when app is not running.
  // internal-only readiness and error-status
  bool _isWaiting = true;
  bool _hasError = false;

  // read-only status indicators
  bool get isWaiting => _isWaiting;
  bool get hasError => _hasError;

  /// Create a new CounterState instance and load value from storage
  CounterState() {
    _load();
  }

  void _setValue(int newValue) {
    _value = newValue;
    _save();
  }

  /// Increment value by 1
  void increment() => _setValue(_value + 1);
  /// Reset value to 0
  void reset() => _setValue(0);

  void _store({bool load = false}) async {
    _hasError = false;
    _isWaiting = true;
    notifyListeners();

    // artificial delay to allow us to see the UI changes
    await Future.delayed(Duration(milliseconds: 500));

    try {
      final prefs = await SharedPreferences.getInstance();
      if (load) {
        _value = prefs.getInt(_sharedPrefsKey) ?? 0;
      } else {
        // save
        // uncomment to simulate error during save
        // if (_value > 3) throw Exception("Artificial Error");
        await prefs.setInt(_sharedPrefsKey, _value);
      }
      _hasError = false;
    } catch (error) {
      _hasError = true;
    }
    _isWaiting = false;
    notifyListeners();
  }

  void _load() => _store(load: true);
  void _save() => _store();
}
