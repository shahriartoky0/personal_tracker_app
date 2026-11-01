import 'package:flutter/material.dart';

import 'settings_screen.dart';

/// Settings as its own page (opened from the app bar gear).
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: const SettingsScreen(),
      );
}
