
import 'package:fluent_ui/fluent_ui.dart';
import 'package:system_theme/system_theme.dart';
import 'package:window_manager/window_manager.dart';
import '../v2/config_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize window management
  await windowManager.ensureInitialized();
  WindowOptions windowOptions = WindowOptions(
    size: Size(800, 600),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
    title: 'Telavox Monitor Configuration',
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  // Initialize system theme
  await SystemTheme.accentColor.load();

  runApp(ConfigApp());
}

class ConfigApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FluentApp(
      title: 'Telavox Monitor Configuration',
      themeMode: ThemeMode.system,
      theme: FluentThemeData(
        accentColor: SystemTheme.accentColor.accent.toAccentColor(),
        brightness: Brightness.light,
      ),
      darkTheme: FluentThemeData(
        accentColor: SystemTheme.accentColor.accent.toAccentColor(),
        brightness: Brightness.dark,
      ),
      home: ConfigScreen(),
    );
  }
}

class ConfigScreen extends StatefulWidget {
  @override
  _ConfigScreenState createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> with WindowListener {
  final ConfigService _configService = ConfigService();
  final _jwtTokenController = TextEditingController();
  final _baseUrlController = TextEditingController();
  int _pollInterval = 5;
  int _exemptionTime = 2;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _loadCurrentConfig();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowClose() async {
    await windowManager.hide();
  }

  void _loadCurrentConfig() async {
    setState(() => _isLoading = true);
    final config = await _configService.loadConfig();
    setState(() {
      _jwtTokenController.text = config.jwtToken ?? '';
      _baseUrlController.text = config.baseUrl;
      _pollInterval = config.pollInterval;
      _exemptionTime = config.exemptionTime;
      _isLoading = false;
    });
  }

  void _saveConfig() async {
    try {
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
          onClose: close,
        ),
      );
    } catch (e) {
      displayInfoBar(
        context,
        builder: (context, close) => InfoBar(
          title: Text('Error'),
          content: Text('Failed to save configuration: ${e.toString()}'),
          severity: InfoBarSeverity.error,
          onClose: close,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      appBar: NavigationAppBar(
        title: Text('Telavox Monitor Configuration'),
        actions: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: Icon(FluentIcons.chrome_minimize),
              onPressed: () async => await windowManager.minimize(),
            ),
            IconButton(
              icon: Icon(FluentIcons.chrome_close),
              onPressed: () async => await windowManager.close(),
            ),
          ],
        ),
      ),
      content: _isLoading
          ? Center(child: ProgressRing())
          : ScaffoldPage(
        header: PageHeader(
          title: Text('Application Configuration'),
          commandBar: CommandBar(
            mainAxisAlignment: MainAxisAlignment.end,
            primaryItems: [
              CommandBarButton(
                icon: Icon(FluentIcons.refresh),
                label: Text('Reload'),
                onPressed: _loadCurrentConfig,
              ),
              CommandBarButton(
                icon: Icon(FluentIcons.save),
                label: Text('Save Configuration'),
                onPressed: _saveConfig,
              ),
            ],
          ),
        ),
        content: Padding(
          padding: EdgeInsets.all(20),
          child: ListView(
            children: [
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Telavox API Settings',
                        style: FluentTheme.maybeOf(context)?.typography.display ?? TextStyle(),
                      ),
                      SizedBox(height: 20),
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
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Monitoring Settings',
                        style: FluentTheme.maybeOf(context)?.typography.subtitle ?? TextStyle(inherit: true),
                      ),
                      SizedBox(height: 20),
                      InfoLabel(
                        label: 'Poll Interval (seconds)',
                        child: NumberBox<int>(
                          value: _pollInterval,
                          onChanged: (value) => setState(() => _pollInterval = value ?? 5),
                          min: 1,
                          max: 60,
                          smallChange: 1,
                          largeChange: 5,
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
                          smallChange: 1,
                          largeChange: 5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
