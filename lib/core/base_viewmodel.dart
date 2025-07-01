import 'package:flutter/foundation.dart';

abstract class BaseViewModel extends ChangeNotifier {  
  bool _isLoading = false;
  bool _isLoggingOut = false;
  String? _errorMessage;  

  bool get isLoading => _isLoading; 
  bool get isLoggingOut => _isLoggingOut; 
  String? get errorMessage => _errorMessage;  

  /// Sets the loading state and notifies listeners.
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }  

  /// Sets the logging out state and notifies listeners.
  void setLoggingOut(bool value) {
    _isLoggingOut = value;
    notifyListeners();
  } 

  /// Sets an error message and notifies listeners.
  void setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// Clears the error message and notifies listeners.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Clears the current state of the ViewModel.
  /// This method should be overridden in subclasses to reset any specific state.
  void clear();  
}