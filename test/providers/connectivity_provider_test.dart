import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:snapchef/providers/sync_provider.dart';
import 'package:snapchef/viewmodels/auth_viewmodel.dart';

import '../mocks/mock_connectivity_provider.dart';

class MockSyncProvider extends Fake implements SyncProvider {}
class MockAuthViewModel extends Fake implements AuthViewModel {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockConnectivityProvider provider;
  late MockSyncProvider mockSyncProvider;
  late MockAuthViewModel mockAuthViewModel;

  setUp(() {
    mockSyncProvider = MockSyncProvider();
    mockAuthViewModel = MockAuthViewModel();

    GetIt.I.reset();
    GetIt.I.registerSingleton<SyncProvider>(mockSyncProvider);
    GetIt.I.registerSingleton<AuthViewModel>(mockAuthViewModel);

    provider = MockConnectivityProvider();
  });

  tearDown(() {
    provider.dispose();
    GetIt.I.reset();
  });

  test('Initial state is not offline', () {
    expect(provider.isOffline, isFalse);
  });

  test('Goes offline when connectivity is none', () async {
    // Directly simulate offline state using the mock provider
    await provider.checkInternetAndServer(offline: true);
    expect(provider.isOffline, isTrue);
  });
}