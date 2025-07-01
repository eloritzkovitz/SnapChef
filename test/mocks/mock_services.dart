import 'package:mockito/mockito.dart';
import 'package:snapchef/services/cookbook_service.dart';
import 'package:snapchef/services/fridge_service.dart';
import 'package:snapchef/services/friend_service.dart';
import 'package:snapchef/services/ingredient_service.dart';
import 'package:snapchef/services/shared_recipe_service.dart';
import 'package:snapchef/services/socket_service.dart';
import 'package:snapchef/services/sync_service.dart';
import 'package:snapchef/services/user_service.dart';

class MockCookbookService extends Mock implements CookbookService {}
class MockFridgeService extends Mock implements FridgeService {}
class MockFriendService extends Mock implements FriendService {}
class MockIngredientService extends Mock implements IngredientService {}
class MockSharedRecipeService extends Mock implements SharedRecipeService {}
class MockSocketService extends Mock implements SocketService {}
class MockSyncManager extends Mock implements SyncManager {}
class MockUserService extends Mock implements UserService {}