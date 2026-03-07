import 'package:flutter/material.dart';
import 'core/style/theme/photo_booth_theme.dart';
import 'features/home/presentatio/pages/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Photo Booth',
      theme: PhotoBoothTheme.lightTheme,
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }
}
