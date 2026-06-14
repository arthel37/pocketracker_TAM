import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import '../main.dart'; // import appSettings

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final List<MaterialColor> colors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.purple,
    Colors.orange,
  ];

  void _updateColor(MaterialColor color) {
    final box = Hive.box('settings');
    box.put('color', color.toARGB32());
    appSettings.value = ThemeSettings(color, appSettings.value.fontSize);
  }

  void _updateFontSize(double size) {
    final box = Hive.box('settings');
    box.put('fontSize', size);
    appSettings.value = ThemeSettings(appSettings.value.color, size);
  }

  @override
  Widget build(BuildContext context) {
    final currentSettings = appSettings.value;

    return Scaffold(
      appBar: AppBar(title: const Text("Ustawienia")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            "Kolor wiodący aplikacji",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 15,
            children: colors
                .map(
                  (color) => GestureDetector(
                    onTap: () => _updateColor(color),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: currentSettings.color == color
                              ? Colors.black
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const Divider(height: 40),
          Text(
            "Rozmiar czcionki: ${currentSettings.fontSize.toInt()}",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Slider(
            value: currentSettings.fontSize,
            min: 10.0,
            max: 24.0,
            divisions: 14,
            label: currentSettings.fontSize.round().toString(),
            onChanged: _updateFontSize,
          ),
        ],
      ),
    );
  }
}
