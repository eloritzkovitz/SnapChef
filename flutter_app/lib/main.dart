import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/viewmodels/ingredient_viewmodel.dart';
import '/views/ingredient_view.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => IngredientViewModel(),
      child: MaterialApp(
        home: IngredientListView(),
      ),
    );
  }
}