import 'dart:convert';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:system_tray/system_tray.dart';
import '../pages/config/config.dart';
import 'package:window_manager_plus/window_manager_plus.dart';
import 'dart:math' as math;

import '../pages/popup/callerPopup.dart';

const Size callerPopupSize = Size(400, 200); // Width, Height
const Size configSize = Size(800, 600);
FluentThemeData appGeneralTheme = FluentThemeData(
  brightness: Brightness.light,
  accentColor: Colors.purple,
);
WindowOptions configWindowOptions = WindowOptions(
  size: configSize,
  center: true,
  backgroundColor: Colors.transparent,
  skipTaskbar: true,
  titleBarStyle: TitleBarStyle.hidden,
  alwaysOnTop: true,
);
WindowOptions popupWindowOptions = WindowOptions(
  size: callerPopupSize,
  center: false,
  backgroundColor: Colors.transparent,
  skipTaskbar: true,
  titleBarStyle: TitleBarStyle.hidden,
  alwaysOnTop: true,
);
// ResourceDictionary resources = ResourceDictionary.dark();
FluentApp callerPopupApp = FluentApp(
    title: 'MobilX Call Handler',
    home: MGRCallerPopup(),
    theme: appGeneralTheme);

FluentApp configApp = FluentApp(
  title: 'Settings',
  home: ConfigScreen(),
  theme: appGeneralTheme,
);

// Test function for a phone-number
String generatePhoneNumber() {
  final random = math.Random();
  return '07${random.nextInt(100).toString().padLeft(2, '0')} '
      '${random.nextInt(1000).toString().padLeft(3, '0')} '
      '${random.nextInt(1000).toString().padLeft(3, '0')}';
}

Map<String, WindowManagerPlus> wmpList = {};

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await WindowManagerPlus.ensureInitialized(
      args.isEmpty ? 0 : int.tryParse(args.first) ?? 0);
  switch (args) {
    case []:
      await createPopup();
    case [_, var b]:
      {
        switch (jsonDecode(b) as Map<String, dynamic>) {
          case {'window_name': 'popup'}:
            await createPopup();
          case {'window_name': 'configScreen'}:
            createConfig();
        }
      }
    default:
      throw ArgumentError('Unknown window configuration: $args');
  }
  _buildSystemTray();
}

createPopup() => runSpecified(
    name: 'popup',
    widget: callerPopupApp,
    alignment: Alignment.bottomRight,
    options: popupWindowOptions);

createConfig() => runSpecified(
    name: 'configScreen',
    widget: configApp,
    alignment: Alignment.center,
    options: configWindowOptions);

void runSpecified(
    {String name = 'Unspecified',
    required WindowOptions options,
    Alignment alignment = Alignment.center,
    required Widget widget}) async {
  await WindowManagerPlus.current.waitUntilReadyToShow(options, () async {
    await WindowManagerPlus.current.setAlignment(alignment);
    await WindowManagerPlus.current.setAsFrameless();
    await WindowManagerPlus.current.show();
  });
  wmpList[name] = WindowManagerPlus.current;
  runApp(widget);
}

// Building the system tray options
Future<SystemTray> _buildSystemTray() async {
  final SystemTray systemTray = SystemTray();
  await systemTray.initSystemTray(
    title: "MGR Caller",
    iconPath: 'assets/app_icon.ico', // Replace with out logo
  );
  print('initiated systemtray');
  // Build context menu for the system tray
  final Menu menu = Menu();
  await menu.buildFrom([
    MenuItemLabel(
      label: 'Show last call',
      onClicked: (_) async {
        WindowManagerPlus tempWmp = wmpList['popup']!;
        if (!await tempWmp.isVisible() || await tempWmp.isMinimized()) {
          await tempWmp.show(); // Isminimized is checked in the show method
        }
      },
    ),
    MenuItemLabel(label: 'Open config', onClicked: (_) {}),
    MenuItemLabel(
      label: 'Exit',
      onClicked: (_) async {
        exit(0);
      },
    ),
  ]);

  systemTray.registerSystemTrayEventHandler((eventName) {
    if (eventName.contains(kSystemTrayEventRightClick)) {
      systemTray.popUpContextMenu();
    }
  });

  await systemTray.setContextMenu(menu);
  return systemTray;
}
