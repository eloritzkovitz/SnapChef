import 'package:flutter/material.dart';
import 'package:snapchef/models/user.dart';
import 'package:snapchef/viewmodels/user_viewmodel.dart';
import 'package:snapchef/providers/connectivity_provider.dart';

import 'mock_connectivity_provider.dart';

class MockUserViewModel extends ChangeNotifier implements UserViewModel {
  @override
  ConnectivityProvider get connectivityProvider => MockConnectivityProvider();

  @override
  bool get isLoading => false;

  User? _user = User(
    id: 'test_user',
    firstName: 'Test',
    lastName: 'User',
    email: 'test@example.com',
    fridgeId: 'test_fridge_id',
    cookbookId: 'test_cookbook_id',
  );

  @override
  User? get user => _user;

  void setUser(User? value) {
    _user = value;
    notifyListeners();
  }

  @override
  String? get fridgeId => _user?.fridgeId;

  @override
  String? get cookbookId => _user?.cookbookId;

  String? get userId => _user?.id;

  String? get email => _user?.email;

  String? get name =>
      _user == null ? null : '${_user!.firstName} ${_user!.lastName}';

  @override
  Future<void> fetchUserData() async {}

  // Add missing method for FCM token refresh
  @override
  void listenForFcmTokenRefresh() {}

  @override
  Map<String, dynamic>? get userStats => {};

  // Add any other required methods or properties here as needed

  // Fallback for any other interface requirements
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
