import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:snapchef/viewmodels/main_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

@GenerateNiceMocks([
  MockSpec<SharedPreferences>(),
])
class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class DummyContext extends Mock implements BuildContext {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MainViewModel', () {
    late MainViewModel vm;

    setUp(() {
      vm = MainViewModel();
    });

    test('initial selectedIndex is 0', () {
      expect(vm.selectedIndex, 0);
    });

    test('currentScreen and appBarTitle match selectedIndex', () {
      expect(vm.appBarTitle, 'Home');
      expect(vm.currentScreen.runtimeType.toString(), contains('HomeScreen'));
      vm.onItemTapped(1);
      expect(vm.appBarTitle, 'Fridge');
      expect(vm.currentScreen.runtimeType.toString(), contains('FridgeScreen'));
      vm.onItemTapped(2);
      expect(vm.appBarTitle, 'Cookbook');
      expect(
          vm.currentScreen.runtimeType.toString(), contains('CookbookScreen'));
      vm.onItemTapped(3);
      expect(vm.appBarTitle, 'Profile');
      expect(
          vm.currentScreen.runtimeType.toString(), contains('ProfileScreen'));
      vm.onItemTapped(4);
      expect(vm.appBarTitle, 'Notifications');
      expect(vm.currentScreen.runtimeType.toString(),
          contains('NotificationsScreen'));
    });

    test('onItemTapped updates selectedIndex and notifies listeners', () {
      var notified = false;
      vm.addListener(() {
        notified = true;
      });
      vm.onItemTapped(2);
      expect(vm.selectedIndex, 2);
      expect(notified, isTrue);
    });

    test('clear resets selectedIndex and notifies listeners', () {
      vm.onItemTapped(3);
      expect(vm.selectedIndex, 3);

      var notified = false;
      vm.addListener(() {
        notified = true;
      });

      vm.clear();
      expect(vm.selectedIndex, 0);
      expect(notified, isTrue);
    });
  });
}
