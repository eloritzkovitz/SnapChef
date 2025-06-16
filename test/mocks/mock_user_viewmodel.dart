import 'package:flutter/material.dart';
import 'package:snapchef/viewmodels/user_viewmodel.dart';

class MockUserViewModel extends ChangeNotifier implements UserViewModel {  

  @override
  Future<void> fetchUserData() async {}

  @override
  // Add other UserViewModel methods as needed for your tests.
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}