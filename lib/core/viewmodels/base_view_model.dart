import 'package:flutter/material.dart';

class BaseViewModel extends ChangeNotifier {
  bool _busy = false;
  String? _errorMessage;
  
  bool get busy => _busy;
  String? get errorMessage => _errorMessage;

  void setBusy(bool value) {
    _busy = value;
    notifyListeners();
  }

  void setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
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
