// lib/monitor_app.dart - This is the system tray application that launches the config
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart' hide Colors;
import 'package:system_tray/system_tray.dart';
import 'package:path/path.dart' as path;
import 'package:process_run/process_run.dart';
import 'package:logging/logging.dart';
import '../telavox_monitor.dart';
import '../v2/config_service.dart';

class _MonitorAppState {
  final ConfigService _configService = ConfigService();
  TelavoxMonitor? _monitor;
  bool _isMonitoring = false;
  final _callLogs = <CallData>[];
  final _logger = Logger('TelavoxMonitor');
  SystemTray systemTray = SystemTray();

  _MonitorAppState(this.systemTray) {
    _initializeTray();
    _initializeMonitor();
  }

  void dispose() {
    _monitor?.dispose();
  }

  //Construct a handling tree for the telavox monitor
  Future<Menu> _initializeTray({Menu? menu}) async {
    menu ?? Menu();

    await menu?.buildFrom([
      MenuItemLabel(
        label: 'Status: ${_isMonitoring ? 'Running' : 'Stopped'}',
        enabled: false,
      ),
      MenuItemLabel(
        label: 'Start Monitoring',
        onClicked: (_) => _startMonitoring,
        enabled:
            !_isMonitoring, // Only enable button if the program is not monitoring
      ),
      MenuItemLabel(
        label: 'Stop Monitoring',
        onClicked: (_) => _stopMonitoring,
        enabled:
            _isMonitoring, // Only enable button if the program is monitoring
      ),
      MenuItemLabel(
        label: 'Open Configuration',
        onClicked: (_) => _openConfigApp,
      ),
      MenuItemLabel(
        label: 'Quit',
        onClicked: (_) => _quitApp,
      ),
    ]);
    return menu ?? Menu();
  }

  // Start the telavox monitor to check for incoming calls
  Future<void> _initializeMonitor() async {
    final config = await _configService.loadConfig();

    // Setup logging
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      print('${record.level.name}: ${record.time}: ${record.message}');
      final logDir = Directory(path.join(
          Platform.environment['HOME'] ??
              Platform.environment['USERPROFILE'] ??
              '.',
          '.telavox-monitor'));

      if (!logDir.existsSync()) {
        logDir.createSync(recursive: true);
      }

      File(path.join(logDir.path, 'monitor.log')).writeAsStringSync(
          '${record.time}: ${record.message}\n',
          mode: FileMode.append);
    });

    _monitor = TelavoxMonitor(
      config: config,
      logger: _logger,
    );

    _monitor?.events.listen((event) async {
      if (event.containsKey(TelavoxEvent.newCall)) {
        final callData = event[TelavoxEvent.newCall] as CallData;
        _callLogs.add(callData);
        systemTray.setContextMenu(await _initializeTray());
      } else if (event.containsKey(TelavoxEvent.statusUpdate)) {
        if (event[TelavoxEvent.statusUpdate] == 'Monitoring started') {
          () => _isMonitoring = true;
        } else if (event[TelavoxEvent.statusUpdate] == 'Monitoring stopped') {
          () => _isMonitoring = false;
        }
        systemTray.setContextMenu(await _initializeTray());
      }
    });
  }

  void _startMonitoring() {
    _monitor?.startMonitoring();
  }

  void _stopMonitoring() {
    _monitor?.stopMonitoring();
  }

  Future<void> _openConfigApp() async {
    // In a real app, you'd launch the config app executable
    // For development, you can use:
    var shell = Shell();
    await shell.run('flutter run -d windows lib/config_app.dart');

    // In production, you would use:
    // await Process.start('telavox_config.exe', []);
  }

  void _quitApp() {
    _monitor?.dispose();
    exit(0);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
