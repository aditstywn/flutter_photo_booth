import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../color/colors_app.dart';

class PhotoBoothTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      colorSchemeSeed: ColorsApp.primary,
      scaffoldBackgroundColor: Color(0xFFFAFAFA),
      brightness: Brightness.light,
      fontFamily: GoogleFonts.lato().fontFamily,
      appBarTheme: _appBarTheme,
      useMaterial3: true,
    );
  }

  static AppBarTheme get _appBarTheme {
    return AppBarTheme(
      backgroundColor: ColorsApp.white,
      foregroundColor: ColorsApp.primary,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: ColorsApp.primary,
      ),
      centerTitle: true,
    );
  }
}
