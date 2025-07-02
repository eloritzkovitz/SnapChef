import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:snapchef/providers/sync_actions/shared_recipe_sync_actions.dart';
import 'package:snapchef/repositories/shared_recipe_repository.dart';

class MockSharedRecipeRepository extends Mock implements SharedRecipeRepository {}

void main() {
  late MockSharedRecipeRepository mockRepository;
  late SharedRecipeSyncActions actions;

  setUp(() {
    mockRepository = MockSharedRecipeRepository();
    actions = SharedRecipeSyncActions(mockRepository);

    when(mockRepository.removeSharedRecipeRemote('c1', 's1')).thenAnswer((_) async {});
    when(mockRepository.removeSharedRecipeLocal('s1')).thenAnswer((_) async {});
  });

  test('handleSharedRecipeAction removeShared calls removeSharedRecipeRemote and removeSharedRecipeLocal', () async {
    final action = {
      'action': 'removeShared',
      'cookbookId': 'c1',
      'sharedRecipeId': 's1',
    };

    await actions.handleSharedRecipeAction(action);

    verify(mockRepository.removeSharedRecipeRemote('c1', 's1')).called(1);
    verify(mockRepository.removeSharedRecipeLocal('s1')).called(1);
  }, skip: true);
}