import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../models/shared_recipe.dart';
import '../providers/connectivity_provider.dart';
import '../providers/sync_provider.dart';
import '../repositories/shared_recipe_repository.dart';
import '../services/sync_service.dart';

class SharedRecipeViewModel extends ChangeNotifier {
  List<SharedRecipe>? sharedWithMeRecipes = [];
  List<SharedRecipe>? sharedByMeRecipes = [];

  final ConnectivityProvider connectivityProvider =
      GetIt.I<ConnectivityProvider>();
  final SharedRecipeRepository sharedRecipeRepository =
      GetIt.I<SharedRecipeRepository>();
  final SyncProvider syncProvider = GetIt.I<SyncProvider>();
  final SyncManager syncManager = GetIt.I<SyncManager>();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  @override
  void dispose() {
    syncProvider.disposeSync();
    syncManager.unregister(syncProvider.syncPendingActions);
    super.dispose();
  }

  SharedRecipeViewModel() {
    syncManager.register(syncProvider.syncPendingActions);
    syncProvider.initSync(connectivityProvider);
    syncProvider.loadPendingActions();
  }

  /// Fetches recipes shared with the user.
  Future<void> fetchSharedRecipes(String cookbookId, String userId) async {
    _isLoading = true;
    notifyListeners();

    final isOffline = connectivityProvider.isOffline;

    if (isOffline) {
      // Load from local DB
      final localShared =
          await sharedRecipeRepository.fetchSharedRecipesLocal(userId);
      sharedWithMeRecipes =
          localShared.where((r) => r.toUser == userId).toList();
      sharedByMeRecipes =
          localShared.where((r) => r.fromUser == userId).toList();
      notifyListeners();
      return;
    }

    // Sync pending actions before fetching remote data
    await syncProvider.syncPendingActions();

    // Fetch from remote and cache locally
    final result =
        await sharedRecipeRepository.fetchSharedRecipesRemote(cookbookId);

    // Store both lists locally
    final allShared = [
      ...(result['sharedWithMe'] != null
          ? List<SharedRecipe>.from(result['sharedWithMe']!)
          : <SharedRecipe>[]),
      ...(result['sharedByMe'] != null
          ? List<SharedRecipe>.from(result['sharedByMe']!)
          : <SharedRecipe>[]),
    ];
    if (allShared.isNotEmpty) {
      await sharedRecipeRepository.storeSharedRecipesLocal(allShared);
    }

    // Merge pending remove actions
    final pendingActions = await syncProvider.getPendingActions('sharedRecipe');
    List<SharedRecipe> mergedWithMe = List.from(result['sharedWithMe'] ?? []);
    List<SharedRecipe> mergedByMe = List.from(result['sharedByMe'] ?? []);

    for (final action in pendingActions) {
      if (action['action'] == 'removeShared') {
        final id = action['sharedRecipeId'];
        if (action['isSharedByMe'] == true) {
          mergedByMe.removeWhere((r) => r.id == id);
        } else {
          mergedWithMe.removeWhere((r) => r.id == id);
        }
      }      
    }

    sharedWithMeRecipes = result['sharedWithMe'] ?? [];
    sharedByMeRecipes = result['sharedByMe'] ?? [];
    _isLoading = false;
    notifyListeners();
  }

  /// Removes a shared recipe.
  Future<void> removeSharedRecipe(String cookbookId, String sharedRecipeId,
      {required bool isSharedByMe}) async {
    try {
      final isOffline = connectivityProvider.isOffline;
      if (isOffline) {
        // Remove locally and queue for sync
        await sharedRecipeRepository.removeSharedRecipeLocal(sharedRecipeId);
        syncProvider.addPendingAction('cookbook', {
          'action': 'removeShared',
          'cookbookId': cookbookId,
          'sharedRecipeId': sharedRecipeId,
          'isSharedByMe': isSharedByMe,
        });
        await syncProvider.savePendingActions();

        // Remove from the correct list
        if (isSharedByMe) {
          sharedByMeRecipes?.removeWhere((r) => r.id == sharedRecipeId);
        } else {
          sharedWithMeRecipes?.removeWhere((r) => r.id == sharedRecipeId);
        }
        notifyListeners();
        return;
      }

      // Call the repository to delete the shared recipe remotely
      await sharedRecipeRepository.removeSharedRecipeRemote(
          cookbookId, sharedRecipeId);

      // Also remove locally to keep local DB in sync
      await sharedRecipeRepository.removeSharedRecipeLocal(sharedRecipeId);

      // Remove from the correct list
      if (isSharedByMe) {
        sharedByMeRecipes?.removeWhere((r) => r.id == sharedRecipeId);
      } else {
        sharedWithMeRecipes?.removeWhere((r) => r.id == sharedRecipeId);
      }
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
