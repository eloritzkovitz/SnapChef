import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';

class EditPreferencesScreen extends StatefulWidget {
  const EditPreferencesScreen({super.key});

  @override
  State<EditPreferencesScreen> createState() => _EditPreferencesScreenState();
}

class _EditPreferencesScreenState extends State<EditPreferencesScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _allergiesController;

  // Dietary preferences
  final Map<String, bool> _dietaryPreferences = {
    'Vegan': false,
    'Vegetarian': false,
    'Pescatarian': false,
    'Carnivore': false,
    'Ketogenic': false,
    'Paleo': false,
    'Low-Carb': false,
    'Low-Fat': false,
    'Gluten-Free': false,
    'Dairy-Free': false,
    'Kosher': false,
    'Halal': false,
  };

  @override
  void initState() {
    super.initState();
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    // Initialize allergies and dietary preferences with current user data
    _allergiesController = TextEditingController(text: 'Peanuts, Lactose');
  }

  @override
  void dispose() {
    _allergiesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Preferences',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Allergies Field
                const Text(
                  'Allergies',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _allergiesController,
                  decoration: InputDecoration(                    
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.warning, color: Colors.grey),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your allergies or leave it blank if none';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Dietary Preferences List
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
                      });
                    },
                    activeColor: primaryColor,
                  );
                }).toList(),

                const SizedBox(height: 32),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        // Show a loading indicator while updating preferences
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );

                        try {
                          // Update user preferences
                          await authViewModel.updateUserPreferences(
                            allergies: _allergiesController.text,
                            dietaryPreferences: _dietaryPreferences,
                          );

                          Navigator.pop(context); // Close the loading indicator
                          Navigator.pop(
                              context); // Go back to the previous screen after successful update
                        } catch (e) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Failed to update preferences: $e')),
                          );
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
    );
  }
}