import 'package:fluent_ui/fluent_ui.dart';
import '../pages/config/config.dart';
import '../pages/home/home_page.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:math' as math;

const Size windowSize = Size(400, 200); // Width, Height

WindowOptions windowOptions = WindowOptions(
  size: windowSize,
  center: false,
  backgroundColor: Colors.transparent,
  skipTaskbar: true,
  titleBarStyle: TitleBarStyle.hidden,
  alwaysOnTop: true,
);
ResourceDictionary resources = ResourceDictionary.dark();
FluentApp fluentMainApp = FluentApp(
    title: 'MobilX Call Handler',
    initialRoute: '/home.page',
    routes: {
      '/home.page': (context) => MGRCallerPopup(
            onClose: () async {
              await windowManager.hide();
              print('Closing window ${await windowManager.isVisible()}');
            },
            onShow: () async {
              windowManager.show;
              print('Showing window ${await windowManager.isVisible()}');
            },
            size: windowSize,
            phoneNumber: generatePhoneNumber(),
            mgrUuid: " ",
          ),
      '/config.page': (context) => ConfigScreen(),
    },
    theme: FluentThemeData(
      brightness: Brightness.light,
      accentColor: Colors.blue,
    ));
// Test function for a phone-number
String generatePhoneNumber() {
  final random = math.Random();
  return '07${random.nextInt(100).toString().padLeft(2, '0')} '
      '${random.nextInt(1000).toString().padLeft(3, '0')} '
      '${random.nextInt(1000).toString().padLeft(3, '0')}';
}

/*on retrieval of a new call this function should be used to update the corresponding incoming number from Telavox:
mgrController.updatePhoneNumber('test');*/
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  await Window.initialize();
  await Window.setEffect(
    effect: WindowEffect.mica, // Apply Mica effect
  );
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setAlignment(Alignment.bottomRight);
    await windowManager.setAsFrameless();
  });
  runApp(fluentMainApp);
}
