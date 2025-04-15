import 'dart:convert';

import 'package:fluent_ui/fluent_ui.dart';
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

WindowOptions windowOptions = WindowOptions(
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

/*on retrieval of a new call this function should be used to update the corresponding incoming number from Telavox:
mgrController.updatePhoneNumber('test');*/
Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  switch (args) {
    case []:
      {
        await WindowManagerPlus.ensureInitialized(0);
        WindowManagerPlus.current.setAsFrameless();
        WindowManagerPlus.current.waitUntilReadyToShow(windowOptions, () {
          WindowManagerPlus.current.minimize();
          WindowManagerPlus.createWindow([
            jsonEncode({'window_name': 'popup'}),
          ]);
        });
      }
    case [_, var b]:
      {
        switch (jsonDecode(b) as Map<String, dynamic>) {
          case {'window_name': 'popup'}:
            runApp(callerPopupApp);
          case {'window_name': 'configScreen'}:
            runApp(configApp);
        }
      }
  }
}
