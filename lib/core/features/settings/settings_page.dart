import 'package:flutter/material.dart';
import 'package:inktome/navigation/nav_bar_notifier.dart';
import 'package:provider/provider.dart';

/// INKTOME SETTINGS PAGE
///
/// App preferences — backup, export, display options, about.
///
/// Contextual pill: none — settings has no primary action.
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('settings')),
      body: Center(
        child: Text('Settings Page', style: textTheme.displayMedium),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<NavBarNotifier>().clearAction();
    });
  }
}
