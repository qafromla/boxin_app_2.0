import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/home_screen.dart';
import 'services/app_settings.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  await AppSettings.load(); // theme, sound and last workout setup
  runApp(const BoxingTimerApp());
}

class BoxingTimerApp extends StatelessWidget {
  const BoxingTimerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppSettings.themeMode,
      builder: (context, mode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Boxing Timer',
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: mode,
          // Status bar icons follow the current theme (also on screens
          // without an AppBar).
          builder:
              (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
                value: AppTheme.overlayFor(Theme.of(context).brightness),
                child: child!,
              ),
          home: const HomeScreen(),
        );
      },
    );
  }
}
