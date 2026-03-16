import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          Consumer<SettingsProvider>(
            builder: (context, settings, child) {
              return ListTile(
                title: const Text('Theme'),
                subtitle: Text(
                  settings.themeMode.toString().split('.').last.toUpperCase(),
                ),
                trailing: DropdownButton<ThemeMode>(
                  value: settings.themeMode,
                  onChanged: (ThemeMode? newValue) {
                    if (newValue != null) {
                      settings.setTheme(newValue);
                    }
                  },
                  items: const [
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Text('System Default'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text('Light Theme'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text('Dark Theme'),
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(),
          const ListTile(
            title: Text('About'),
            subtitle: Text('Vehicle Log App v 0.0.0'),
          ),
        ],
      ),
    );
  }
}
