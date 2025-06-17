import 'package:flutter/material.dart';
import 'package:snapchef/models/user.dart';
import 'package:snapchef/viewmodels/user_viewmodel.dart';

class MockUserViewModel extends ChangeNotifier implements UserViewModel {  
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
  String? get fridgeId => 'test_fridge_id';

  @override
  String? get cookbookId => null;

  String? get userId => null;

  String? get email => null;

  String? get name => null;

  @override
  Future<void> fetchUserData() async {}

  // Add this to satisfy any other interface requirements
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}