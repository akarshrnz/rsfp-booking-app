import 'package:flutter/material.dart';
import 'package:innerspace_booking_app/core/color_constant.dart';

class AppTheme {
    static ThemeData get lightTheme {
    return ThemeData(
      scaffoldBackgroundColor: background,
      primaryColor: buttonBackground,
      colorScheme:  ColorScheme.light(
        primary: primaryColor,
        secondary: secondary,
      ),
      iconTheme: IconThemeData(color: iconGrey),
    );
  }
  
}