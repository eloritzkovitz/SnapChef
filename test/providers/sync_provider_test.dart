import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snapchef/providers/sync_provider.dart';
import 'package:snapchef/providers/connectivity_provider.dart';
import 'package:mockito/mockito.dart';

class MockConnectivityProvider extends Mock implements ConnectivityProvider {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  late SyncProvider syncProvider;

  setUp(() {
    syncProvider = SyncProvider();
  });

  test('addPendingAction adds to queue', () {
    syncProvider.addPendingAction('fridge', {'action': 'add'});
    expect(syncProvider.pendingActionQueues['fridge']!.length, 1);
  });

  test('clearSyncQueue clears all queues', () {
    syncProvider.addPendingAction('fridge', {'action': 'add'});
    syncProvider.clearSyncQueue();
    expect(syncProvider.pendingActionQueues.isEmpty, isTrue);
  });  
}