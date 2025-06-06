import 'package:flutter/material.dart';

// Define app colors
const Color primaryColor = Color(0xffff794e);
const Color secondaryColor = Color(0xffff5722);
const Color splashColor = Color(0xFFF47851);

const Color disabledColor = Color(0xff9e9e9e);
const Color disabledSecondaryColor = Color(0xffbdbdbd);

// Define a MaterialColor for the primary color
const MaterialColor primarySwatch = MaterialColor(
  0xffff5722, // Base color
  <int, Color>{
    50: Color(0xffff6838),  // 10%
    100: Color(0xffff794e), // 20%
    200: Color(0xffff8964), // 30%
    300: Color(0xffff9a7a), // 40%
    400: Color(0xffffab91), // 50%
    500: Color(0xffffbca7), // 60%
    600: Color(0xffffcdbd), // 70%
    700: Color(0xffffddd3), // 80%
    800: Color(0xffffeee9), // 90%
    900: Color(0xffffffff), // 100%
  },
);