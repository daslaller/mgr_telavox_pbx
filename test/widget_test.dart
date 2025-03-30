// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.


import 'package:fluent_ui/fluent_ui.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:mgr_telavox_pbx/pages/config/config.dart';
//import 'package:mgr_telavox_pbx/widgets.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    ConfigScreen dynamicConfigWidget = ConfigScreen();

    await tester.pumpWidget(FluentApp(home: dynamicConfigWidget,));
  });
}
