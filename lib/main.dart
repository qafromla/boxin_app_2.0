import 'package:flutter/material.dart';
import 'screens/setting_screen.dart';

// Add a ValueNotifier to manage the theme mode
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() {
  runApp(BoxingTimerApp());
}

class BoxingTimerApp extends StatelessWidget {
  const BoxingTimerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentTheme, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light().copyWith(
            scaffoldBackgroundColor: Color(0xFFBDBDBD), // background
            appBarTheme: AppBarTheme(
              backgroundColor: Color(0xFFA4A4A4), // app bar
              elevation: 0,
              centerTitle: true,
              titleTextStyle: TextStyle(
                color: Colors.black87, // dark gray title
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              iconTheme: IconThemeData(color: Colors.black87),
            ),
            textTheme: ThemeData.light().textTheme.apply(
              bodyColor: Colors.black87,
              displayColor: Colors.black87,
            ),
          ),
          darkTheme: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: Color(0xFF0A0E21), // background
            appBarTheme: AppBarTheme(
              backgroundColor: Color(0xFF0A0E21), // app bar
              elevation: 0,
              centerTitle: true,
              titleTextStyle: TextStyle(
                color: Colors.white, // white title
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              iconTheme: IconThemeData(color: Colors.white),
            ),
            textTheme: ThemeData.dark().textTheme.apply(
              bodyColor: Colors.white,
              displayColor: Colors.white,
            ),
          ),
          themeMode: currentTheme, // Use the current theme mode
          title: 'Boxing Timer',
          home: SettingScreen(),
        );
      },
    );
  }
}
