import 'package:flutter/material.dart'; 

class Palette { 
  static const MaterialColor kToLight = const MaterialColor( 
    0xffff5722, // 0% comes in here, this will be color picked if no shade is selected when defining a Color property which doesn’t require a swatch. 
    const <int, Color>{ 
      50: const Color(0xff6838),//10% 
      100: const Color(0xff794e),//20% 
      200: const Color(0xff8964),//30% 
      300: const Color(0xff9a7a),//40% 
      400: const Color(0xffab91),//50% 
      500: const Color(0xffbca7),//60% 
      600: const Color(0xffcdbd),//70% 
      700: const Color(0xffddd3),//80% 
      800: const Color(0xffeee9),//90% 
      900: const Color(0xffffff),//100% 
    }, 
  ); 
}