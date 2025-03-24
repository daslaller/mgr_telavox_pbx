// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart' hide Colors;
import '../v1/telavox_monitor.dart';
import '../v1/config_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ConfigService _configService = ConfigService();
  TelavoxMonitor? _monitor;
  List<CallData> _activeCalls = [];

  @override
  void initState() {
    super.initState();
    _initializeMonitor();
  }

  Future<void> _initializeMonitor() async {
    final config = await _configService.loadConfig();
    setState(() {
      _monitor = TelavoxMonitor(
        config: config,
        logger: Logger('TelavoxMonitorGUI'),
      );

      _monitor?.events.listen((event) {
        if (event.containsKey(TelavoxEvent.newCall)) {
          setState(() {
            _activeCalls.add(event[TelavoxEvent.newCall]);
          });
        } else if (event.containsKey(TelavoxEvent.callEnded)) {
          setState(() {
            _activeCalls.removeWhere((call) =>
            call.phoneNumber == event[TelavoxEvent.callEnded]
            );
          });
        }
      });
    });
  }

  void _startMonitoring() {
    _monitor?.startMonitoring();
  }

  void _stopMonitoring() {
    _monitor?.stopMonitoring();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: PageHeader(
        title: Text('Telavox Call Monitor'),
        commandBar: CommandBar(
          items: [
            CommandBarButton(
              icon: Icon(FluentIcons.play),
              label: Text('Start Monitoring'),
              onPressed: _startMonitoring,
            ),
            CommandBarButton(
              icon: Icon(FluentIcons.stop),
              label: Text('Stop Monitoring'),
              onPressed: _stopMonitoring,
            ),
          ],
        ),
      ),
      content: ListView.builder(
        itemCount: _activeCalls.length,
        itemBuilder: (context, index) {
          final call = _activeCalls[index];
          return Card(
            child: ListTile(
              title: Text(call.phoneNumber),
              subtitle: Text('Extension: ${call.extensionName}'),
              trailing: Text(call.timestamp.toString()),
            ),
          );
        },
      ),
    );
  }
}
