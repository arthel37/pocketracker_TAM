import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'screens/main_navigation_screen.dart';

final ValueNotifier<ThemeSettings> appSettings = ValueNotifier(
  ThemeSettings(Colors.blue, 14.0),
);

class ThemeSettings {
  final MaterialColor color;
  final double fontSize;
  ThemeSettings(this.color, this.fontSize);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('caught_pokemon');
  await Hive.openBox('settings');
  final settingsBox = Hive.box('settings');
  int colorVal = settingsBox.get('color', defaultValue: Colors.blue.toARGB32());
  double fontSize = settingsBox.get('fontSize', defaultValue: 14.0);

  appSettings.value = ThemeSettings(
    Colors.primaries.firstWhere(
      (c) => c.toARGB32() == colorVal,
      orElse: () => Colors.blue,
    ),
    fontSize,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeSettings>(
      valueListenable: appSettings,
      builder: (context, settings, child) {
        return MaterialApp(
          title: 'PokeTrack',
          theme: ThemeData(
            primarySwatch: settings.color,
            textTheme: TextTheme(
              bodyMedium: TextStyle(fontSize: settings.fontSize),
              bodyLarge: TextStyle(fontSize: settings.fontSize + 2),
              titleLarge: TextStyle(
                fontSize: settings.fontSize + 6,
                fontWeight: FontWeight.bold,
              ),
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: settings.color,
              foregroundColor: Colors.white,
            ),
          ),
          home: const MainNavigationScreen(),
        );
      },
    );
  }
}
