import 'dart:io';
import 'controller.dart';

import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:system_tray/system_tray.dart';
import 'package:window_manager/window_manager.dart';

/*on retrieval of a new call this function should be used to update the corresponding incoming number from telavox:
mgrController.updatePhoneNumber('test');*/
const WindowOptions windowOptions = WindowOptions(
  size: Size(800, 600),
  center: false,
  backgroundColor: Colors.transparent,
  skipTaskbar: true,
  titleBarStyle: TitleBarStyle.hidden,
  alwaysOnTop: true,
);

// Create a global controller instance
final mgrController = MGRCallerController(
  phoneNumber: '07912345678',
  mgrUuid: 'your-mgr-uuid',
  onShow: () async {
    await windowManager.show();
    print('Showing popup');
  },
  onClose: () async {
    await windowManager.hide();
    print('Hiding popup');
  },
);

Future<void> initWindow() async {
  await windowManager.ensureInitialized();
  await Window.initialize();
  await Window.setEffect(
    effect: WindowEffect.mica, // Apply Mica effect
    dark: false, // Use light theme
  );
  showPop();
}

Future<void> showPop() async {
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setAsFrameless();
    await windowManager.setAlignment(Alignment.bottomRight);
    await windowManager.show();
    mgrController.showPopup();
  });
}

// Building the system tray options
Future<SystemTray> buildSystemTray() async {
  final SystemTray systemTray = SystemTray();
  await systemTray.initSystemTray(
    title: "MGR Caller",
    iconPath: 'assets/app_icon.ico', // Replace with out logo
  );

  // Build context menu for the systemtray
  final Menu menu = Menu();
  await menu.buildFrom([
    MenuItemLabel(
      label: 'Show last call',
      onClicked: (_) async {
        await showPop();
      },
    ),
    MenuItemLabel(
      label: 'Exit',
      onClicked: (_) async {
        mgrController.hidePopup();
        await windowManager.destroy();
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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initWindow();
  buildSystemTray();
  runApp(fluentApp(mgrController));
}
