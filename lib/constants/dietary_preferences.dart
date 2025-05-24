// This file defines constants related to dietary preferences used in the application.

// Default preferences in case user has none
  const List<String> allDietaryKeys = [
    'Vegan',
    'Vegetarian',
    'Pescatarian',
    'Carnivore',
    'Ketogenic',
    'Paleo',
    'Low-Carb',
    'Low-Fat',
    'Gluten-Free',
    'Dairy-Free',
    'Kosher',
    'Halal',
  ];

  // Mapping UI keys to backend keys
  const Map<String, String> dietaryKeyMap = {
    'Vegan': 'vegan',
    'Vegetarian': 'vegetarian',
    'Pescatarian': 'pescatarian',
    'Carnivore': 'carnivore',
    'Ketogenic': 'ketogenic',
    'Paleo': 'paleo',
    'Low-Carb': 'lowCarb',
    'Low-Fat': 'lowFat',
    'Gluten-Free': 'glutenFree',
    'Dairy-Free': 'dairyFree',
    'Kosher': 'kosher',
    'Halal': 'halal',
  };

  // Reverse mapping for backend -> UI
  const Map<String, String> backendToUiDietaryKeyMap = {
    'vegan': 'Vegan',
    'vegetarian': 'Vegetarian',
    'pescatarian': 'Pescatarian',
    'carnivore': 'Carnivore',
    'ketogenic': 'Ketogenic',
    'paleo': 'Paleo',
    'lowCarb': 'Low-Carb',
    'lowFat': 'Low-Fat',
    'glutenFree': 'Gluten-Free',
    'dairyFree': 'Dairy-Free',
    'kosher': 'Kosher',
    'halal': 'Halal',
  };