import 'package:flutter/material.dart';

class BaseViewModel extends ChangeNotifier {
  bool _busy = false;
  bool get busy => _busy;

  void setBusy(bool value) {
    _busy = value;
    notifyListeners();
  }

  void init() {
    // Override this method in subclasses to initialize data
  }

  @override
  void dispose() {
    super.dispose();
  }
}
