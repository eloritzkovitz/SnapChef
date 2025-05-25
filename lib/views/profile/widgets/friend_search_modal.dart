import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/friend_viewmodel.dart';
import '../../../models/user.dart';

class FriendSearchModal extends StatefulWidget {
  const FriendSearchModal({super.key});

  @override
  State<FriendSearchModal> createState() => _FriendSearchModalState();
}

class _FriendSearchModalState extends State<FriendSearchModal> {
  String _searchQuery = '';
  bool _isLoading = false;
  List<User> _results = [];
  String? _error;

  Future<void> _search(BuildContext context) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final users = await Provider.of<FriendViewModel>(context, listen: false)
          .searchUsers(_searchQuery);
      setState(() {
        _results = users;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to search users';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendRequest(BuildContext context, String userId) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final message = await Provider.of<FriendViewModel>(context, listen: false)
        .sendFriendRequest(userId);
    setState(() {
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message ?? 'Request sent!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Search users',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _search(context),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              onSubmitted: (_) => _search(context),
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
          if (!_isLoading && _results.isNotEmpty)
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _results.length,
                itemBuilder: (context, index) {
                  final user = _results[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: user.profilePicture != null
                          ? NetworkImage(user.profilePicture!)
                          : const AssetImage('assets/images/default_profile.png')
                              as ImageProvider,
                    ),
                    title: Text(user.fullName),
                    subtitle: Text(user.email),
                    trailing: ElevatedButton(
                      child: const Text('Add'),
                      onPressed: () => _sendRequest(context, user.id),
                    ),
                  );
                },
              ),
            ),
          if (!_isLoading && _results.isEmpty && _searchQuery.isNotEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No users found.'),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}