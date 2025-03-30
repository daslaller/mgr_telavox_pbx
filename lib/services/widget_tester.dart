import 'package:fluent_ui/fluent_ui.dart';
import 'package:mgr_telavox_pbx/pages/config/config.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ConfigScreen configScreen = ConfigScreen();
  runApp(FluentApp(
    home: configScreen,
    theme: FluentThemeData(
      brightness: Brightness.light,
      accentColor: Colors.blue,
      micaBackgroundColor: Colors.white,
    ),
    color: Colors.white,

  ));
}
