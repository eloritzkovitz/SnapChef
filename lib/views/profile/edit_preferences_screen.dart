import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/snapchef_appbar.dart';
import '../../constants/dietary_preferences.dart';
import '../../theme/colors.dart';
import '../../viewmodels/user_viewmodel.dart';

class EditPreferencesScreen extends StatefulWidget {
  const EditPreferencesScreen({super.key});

  @override
  State<EditPreferencesScreen> createState() => _EditPreferencesScreenState();
}

class _EditPreferencesScreenState extends State<EditPreferencesScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _newAllergyController;

  List<String> _allergies = [];
  Map<String, bool> _dietaryPreferences = {};

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _newAllergyController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userViewModel = Provider.of<UserViewModel>(context, listen: false);
      final user = userViewModel.user;

      setState(() {
        _allergies = List<String>.from(user?.preferences?.allergies ?? []);
        _dietaryPreferences = {
          for (final key in allDietaryKeys) key: false,
        };
        final userDiet = user?.preferences?.dietaryPreferences ?? {};
        // Map backend keys to UI keys
        userDiet.forEach((backendKey, value) {
          final uiKey = backendToUiDietaryKeyMap[backendKey];
          if (uiKey != null && value == true) {
            _dietaryPreferences[uiKey] = true;
          }
        });
        _loading = false;
      });
    });
  }

  @override
  void dispose() {
    _newAllergyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userViewModel = Provider.of<UserViewModel>(context);

    // Show loading indicator if data not loaded yet
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: SnapChefAppBar(
        title: const Text('Edit Preferences',
            style: TextStyle(fontWeight: FontWeight.bold)),               
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Allergies Section
                  const Text(
                    'Allergies',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  // List of allergies
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: _allergies.map((allergy) {
                      return Chip(
                        label: Text(
                          allergy,
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: primarySwatch[200],
                        side: BorderSide(color: primarySwatch[200]!),
                        deleteIcon: const Icon(Icons.close, color: Colors.white),
                        onDeleted: () {
                          setState(() {
                            _allergies.remove(allergy);
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Add new allergy input
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _newAllergyController,
                          decoration: InputDecoration(
                            labelText: 'Add Allergy',
                            labelStyle: const TextStyle(color: Colors.grey),
                            filled: true,
                            fillColor: Colors.grey[200],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.add, color: Colors.white),
                          onPressed: () {
                            final newAllergy = _newAllergyController.text.trim();
                            if (newAllergy.isNotEmpty &&
                                !_allergies.contains(newAllergy)) {
                              setState(() {
                                _allergies.add(newAllergy);
                                _newAllergyController.clear();
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Dietary Preferences Section
                  const Text(
                    'Dietary Preferences',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ..._dietaryPreferences.keys.map((preference) {
                    return CheckboxListTile(
                      title: Text(preference),
                      value: _dietaryPreferences[preference],
                      onChanged: (value) {
                        setState(() {
                          _dietaryPreferences[preference] = value ?? false;

                          // Handle conflicts
                          if (preference == 'Vegetarian' && value == true) {
                            _dietaryPreferences['Carnivore'] = false;
                            _dietaryPreferences['Pescatarian'] = false;
                          } else if (preference == 'Carnivore' && value == true) {
                            _dietaryPreferences['Vegetarian'] = false;
                            _dietaryPreferences['Vegan'] = false;
                          } else if (preference == 'Vegan' && value == true) {
                            _dietaryPreferences['Carnivore'] = false;
                            _dietaryPreferences['Vegetarian'] = false;
                            _dietaryPreferences['Pescatarian'] = false;
                          }
                        });
                      },
                      activeColor: primaryColor,
                    );
                  }),

                  const SizedBox(height: 32),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );

                          try {
                            // Map UI keys to backend keys before saving
                            final backendDietaryPreferences = {
                              for (final entry in _dietaryPreferences.entries)
                                dietaryKeyMap[entry.key]!: entry.value
                            };
                            await userViewModel.updateUserPreferences(
                              allergies: _allergies,
                              dietaryPreferences: backendDietaryPreferences,
                            );
                            if (context.mounted) {
                              Navigator.pop(
                                  context); // Close the loading indicator
                            }
                            if (context.mounted) {
                              Navigator.pop(context); // Go back
                            }
                          } catch (e) {
                            if (context.mounted) Navigator.pop(context);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text('Failed to update preferences: $e')),
                              );
                            }
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}