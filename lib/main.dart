import 'package:flutter/material.dart';
import 'screens/setting_screen.dart';
// void main() {
//   runApp(BoxingTimerApp());
// }
//
// class BoxingTimerApp extends StatelessWidget {
//   const BoxingTimerApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//         debugShowCheckedModeBanner: false,
//         theme: ThemeData.dark().copyWith(
//           scaffoldBackgroundColor: Color(0xFF0A0E21),
//           appBarTheme: AppBarTheme(
//             backgroundColor: Color(0xFF0A0E21),
//             elevation: 0,
//             centerTitle: true,
//             titleTextStyle: TextStyle(
//               color: Colors.white,
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//             ),
//           )
//         ),
//         title: 'Boxing Time',
//         home: SettingScreen());
//   }
// }


void main() {
  runApp(BoxingTimerApp());
}

class BoxingTimerApp extends StatelessWidget {
  const BoxingTimerApp({super.key});

  @override
  Widget build(BuildContext context) {
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
      title: 'Boxing Timer',
      home: SettingScreen(),
    );
  }
}