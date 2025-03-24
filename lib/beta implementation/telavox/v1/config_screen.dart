// lib/screens/config_screen.dart
import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart' hide Colors;
import '../v1/config_service.dart';

class ConfigScreen extends StatefulWidget {
  @override
  _ConfigScreenState createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  final ConfigService _configService = ConfigService();
  final _jwtTokenController = TextEditingController();
  final _baseUrlController = TextEditingController();
  int _pollInterval = 5;
  int _exemptionTime = 2;

  @override
  void initState() {
    super.initState();
    _loadCurrentConfig();
  }

  void _loadCurrentConfig() async {
    final config = await _configService.loadConfig();
    setState(() {
      _jwtTokenController.text = config.jwtToken ?? '';
      _baseUrlController.text = config.baseUrl;
      _pollInterval = config.pollInterval;
      _exemptionTime = config.exemptionTime;
    });
  }

  void _saveConfig() async {
    await _configService.updateConfig(
      jwtToken: _jwtTokenController.text,
      baseUrl: _baseUrlController.text,
      pollInterval: _pollInterval,
      exemptionTime: _exemptionTime,
    );
    displayInfoBar(
      context,
      builder: (context, close) => InfoBar(
        title: Text('Configuration Saved'),
        content: Text('Your settings have been updated successfully.'),
        severity: InfoBarSeverity.success,
        action: IconButton(
          icon: Icon(FluentIcons.clear),
          onPressed: close,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: PageHeader(
        title: Text('Application Configuration'),
        commandBar: CommandBar(
          items: [
            CommandBarButton(
              icon: Icon(FluentIcons.save),
              label: Text('Save Configuration'),
              onPressed: _saveConfig,
            ),
          ],
        ),
      ),
      content: ListView(
        padding: EdgeInsets.all(20),
        children: [
          InfoLabel(
            label: 'JWT Token',
            child: TextBox(
              controller: _jwtTokenController,
              placeholder: 'Enter your Telavox JWT Token',
              maxLines: 2,
            ),
          ),
          SizedBox(height: 20),
          InfoLabel(
            label: 'Base URL',
            child: TextBox(
              controller: _baseUrlController,
              placeholder: 'https://api.telavox.se',
            ),
          ),
          SizedBox(height: 20),
          InfoLabel(
            label: 'Poll Interval (seconds)',
            child: NumberBox<int>(
              value: _pollInterval,
              onChanged: (value) => setState(() => _pollInterval = value ?? 5),
              min: 1,
              max: 60,
            ),
          ),
          SizedBox(height: 20),
          InfoLabel(
            label: 'Exemption Time (minutes)',
            child: NumberBox<int>(
              value: _exemptionTime,
              onChanged: (value) => setState(() => _exemptionTime = value ?? 2),
              min: 1,
              max: 60,
            ),
          ),
        ],
      ),
    );
  }
}
