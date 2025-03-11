import 'package:flutter/material.dart';

class NintendoTheme {
  // Nintendo Switch colors
  static const Color neonRed = Color(0xFFE60012);
  static const Color neonBlue = Color(0xFF0AB9E6);
  static const Color neonYellow = Color(0xFFE6E600);
  static const Color nintendoGray = Color(0xFF585858);
  static const Color nintendoLightGray = Color(0xFFE6E6E6);
  static const Color nintendoDarkGray = Color(0xFF1A1A1A);
  static const Color marioBrown = Color(0xFF8B4513);
  static const Color luigiGreen = Color(0xFF39B54A);
  static const Color peachPink = Color(0xFFFFB6C1);
  static const Color yoshiGreen = Color(0xFF00FF00);
  static const Color bowserOrange = Color(0xFFFF8C00);
  
  // Text styles
  static const TextStyle headingStyle = TextStyle(
    fontFamily: 'NintendoFont',
    fontWeight: FontWeight.bold,
    fontSize: 24,
    letterSpacing: 1.2,
  );
  
  static const TextStyle bodyStyle = TextStyle(
    fontFamily: 'NintendoFont',
    fontSize: 16,
    letterSpacing: 0.5,
  );
  
  static const TextStyle buttonStyle = TextStyle(
    fontFamily: 'NintendoFont',
    fontWeight: FontWeight.bold,
    fontSize: 16,
    letterSpacing: 1.0,
  );
  
  // Button styles
  static final ButtonStyle redButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: neonRed,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30),
    ),
    elevation: 5,
  );
  
  static final ButtonStyle blueButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: neonBlue,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30),
    ),
    elevation: 5,
  );
  
  // Card style
  static BoxDecoration cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.2),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
    border: Border.all(
      color: nintendoGray.withOpacity(0.3),
      width: 2,
    ),
  );
  
  // App bar theme
  static AppBarTheme appBarTheme = AppBarTheme(
    backgroundColor: neonRed,
    foregroundColor: Colors.white,
    elevation: 8,
    shadowColor: neonRed.withOpacity(0.5),
    centerTitle: true,
    titleTextStyle: headingStyle.copyWith(
      color: Colors.white,
      fontSize: 22,
      shadows: [
        Shadow(
          color: Colors.black.withOpacity(0.5),
          offset: const Offset(2, 2),
          blurRadius: 4,
        ),
      ],
    ),
    toolbarHeight: 60,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
    ),
  );
  
  // Theme data
  static ThemeData lightTheme = ThemeData(
    primaryColor: neonRed,
    scaffoldBackgroundColor: nintendoLightGray,
    appBarTheme: appBarTheme,
    textTheme: TextTheme(
      displayLarge: headingStyle,
      bodyLarge: bodyStyle,
      labelLarge: buttonStyle,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: redButtonStyle,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: neonBlue,
        textStyle: buttonStyle,
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return neonBlue;
        }
        return nintendoGray;
      }),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: nintendoGray,
      thickness: 2,
    ),
    colorScheme: ColorScheme.fromSwatch().copyWith(
      primary: neonRed,
      secondary: neonBlue,
      tertiary: neonYellow,
    ),
  );
  
  static ThemeData darkTheme = ThemeData.dark().copyWith(
    primaryColor: neonRed,
    scaffoldBackgroundColor: nintendoDarkGray,
    appBarTheme: appBarTheme.copyWith(
      backgroundColor: nintendoDarkGray,
    ),
    textTheme: TextTheme(
      displayLarge: headingStyle.copyWith(color: Colors.white),
      bodyLarge: bodyStyle.copyWith(color: Colors.white),
      labelLarge: buttonStyle.copyWith(color: Colors.white),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: redButtonStyle,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: neonBlue,
        textStyle: buttonStyle,
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return neonBlue;
        }
        return nintendoLightGray;
      }),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: nintendoLightGray,
      thickness: 2,
    ),
    colorScheme: ColorScheme.fromSwatch().copyWith(
      primary: neonRed,
      secondary: neonBlue,
      tertiary: neonYellow,
      brightness: Brightness.dark,
    ),
  );
}
