import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart' hide Colors;
import 'package:system_theme/system_theme.dart';
import 'package:window_manager/window_manager.dart';

import 'screens/main.dart';
import 'screens/config_screen.dart';
import 'services/config_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize window management
  await windowManager.ensureInitialized();
  WindowOptions windowOptions = WindowOptions(
    size: Size(1200, 800),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  // Initialize system theme
  await SystemTheme.accentColor.load();

  runApp(TelavoxMonitorApp());
}

class TelavoxMonitorApp extends StatefulWidget {
  @override
  _TelavoxMonitorAppState createState() => _TelavoxMonitorAppState();
}

class _TelavoxMonitorAppState extends State<TelavoxMonitorApp> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      title: 'Telavox Monitor',
      themeMode: ThemeMode.system,
      theme: FluentThemeData(
        accentColor: SystemTheme.accentColor.accent.toAccentColor(),
        brightness: Brightness.light,
      ),
      darkTheme: FluentThemeData(
        accentColor: SystemTheme.accentColor.accent.toAccentColor(),
        brightness: Brightness.dark,
      ),
      home: FluentApp(
        home: NavigationView(
          appBar: NavigationAppBar(
            title: Text('Telavox Monitor'),
            leading: Icon(FluentIcons.phone_transition),
          ),
          pane: NavigationPane(
            selected: _currentIndex,
            onChanged: (index) => setState(() => _currentIndex = index),
            displayMode: PaneDisplayMode.top,
            items: [
              PaneItem(
                icon: Icon(FluentIcons.home),
                title: Text('Home'),
                body: HomeScreen(),
              ),
              PaneItem(
                icon: Icon(FluentIcons.settings),
                title: Text('Configuration'),
                body: ConfigScreen(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
