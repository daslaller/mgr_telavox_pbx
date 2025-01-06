import 'dart:io';
import 'controller.dart';

import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:system_tray/system_tray.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:math' as math;

/*on retrieval of a new call this function should be used to update the corresponding incoming number from Telavox:
mgrController.updatePhoneNumber('test');*/
const WindowOptions windowOptions = WindowOptions(
  center: false,
  backgroundColor: Colors.transparent,
  skipTaskbar: true,
  titleBarStyle: TitleBarStyle.hidden,
  alwaysOnTop: true,
);

// Create a global controller instance, its accessible outside of the package
final mgrController = MGRCallerController(
  phoneNumber: generatePhoneNumber(),
  mgrUuid: 'your-mgr-uuid',
  onShow: () async {
    await updateWindowState(visible: true);
    print('Showing popup');
  },
  onClose: () async {
    //await windowManager.hide();
    await updateWindowState(visible: false);
    //await windowManager.destroy();
    print('Hiding popup');
  },
);

Future<void> initWindow() async {
  await windowManager.ensureInitialized();
  await Window.initialize();
  await Window.setEffect(
      effect: WindowEffect.mica, // Apply Mica effect
      //color: Colors.transparent,
      dark: false // Use light theme
      );
  updateWindowState();
  //showPop();
}

updateWindowState({visible}) async {
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setAlignment(Alignment.bottomRight);
    await windowManager.setAsFrameless();
    if (visible != null && visible == true) {
      await windowManager.show();
      await windowManager.setIgnoreMouseEvents(true);
    } else {
      await windowManager.hide();
    }
  });
}

// Building the system tray options
Future<SystemTray> buildSystemTray() async {
  final SystemTray systemTray = SystemTray();
  await systemTray.initSystemTray(
    title: "MGR Caller",
    iconPath: 'assets/app_icon.ico', // Replace with out logo
  );

  // Build context menu for the system tray
  final Menu menu = Menu();
  await menu.buildFrom([
    MenuItemLabel(
      label: 'Show last call',
      onClicked: (_) async {
        mgrController.showPopup();
      },
    ),
    MenuItemLabel(
      label: 'Exit',
      onClicked: (_) async {
        mgrController.hidePopup();
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

// Test function for a phone-number
String generatePhoneNumber() {
  final random = math.Random();
  return '07${random.nextInt(100).toString().padLeft(2, '0')} '
      '${random.nextInt(1000).toString().padLeft(3, '0')} '
      '${random.nextInt(1000).toString().padLeft(3, '0')}';
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initWindow();
  await buildSystemTray();
  runApp(fluentApp(mgrController));
  mgrController.updatePhoneNumber('123');
  mgrController.updatePhoneNumber('121');
}
