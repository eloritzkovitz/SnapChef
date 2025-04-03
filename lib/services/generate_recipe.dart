import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GenerateRecipe extends StatefulWidget {
  
  const GenerateRecipe({super.key});

  @override
  _RecipeGeneratorState createState() => _RecipeGeneratorState();
}

class _RecipeGeneratorState extends State<GenerateRecipe> {
  final TextEditingController _ingredientsController = TextEditingController();
  bool isLoading = false;
  String _recipe = '';

  Future<void> _generateRecipe() async {
    setState(() {
      isLoading = true;
      _recipe = "";
    });

    if (_ingredientsController.text.trim().isEmpty) {
      setState(() {
        _recipe = "Please enter at least one ingredient.";
        isLoading = false;
      });
      return;
    }

    final String? serverUrl = dotenv.env['SERVER_IP'];
    if (serverUrl == null) {
      setState(() {
        _recipe = "Server URL not configured properly.";
        isLoading = false;
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse("$serverUrl/api/recipes/generate"),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'ingredients': _ingredientsController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _recipe = data['recipe'];
        });
      } else {
        setState(() {
          _recipe = 'Failed to generate recipe.';
        });
      }
    } catch (error) {
      setState(() {
        _recipe = 'Failed to generate recipe: $error';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _ingredientsController,
            decoration: const InputDecoration(
              labelText: 'Enter ingredients (comma-separated)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: isLoading ? null : _generateRecipe,
            child: isLoading
                ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                : const Text('Generate'),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_recipe.isNotEmpty)
                    const Text("Recipe:",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(_recipe),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}