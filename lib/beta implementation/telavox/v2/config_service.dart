// lib/services/config_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;

class Config {
  final String? jwtToken;
  final String baseUrl;
  final int pollInterval;
  final int exemptionTime;
  final Map<String, dynamic>? recentCalls;

  Config({
    this.jwtToken,
    this.baseUrl = 'https://api.telavox.se',
    this.pollInterval = 5,
    this.exemptionTime = 2,
    this.recentCalls,
  });

  Map<String, dynamic> toJson() => {
    'credentials': {'jwt_token': jwtToken},
    'settings': {
      'base_url': baseUrl,
      'poll_interval': pollInterval,
      'exemption_time': exemptionTime,
    },
    'recent_calls': recentCalls ?? {},
  };

  // Create a new Config with updated values while preserving other fields
  Config copyWith({
    String? jwtToken,
    String? baseUrl,
    int? pollInterval,
    int? exemptionTime,
  }) {
    return Config(
      jwtToken: jwtToken ?? this.jwtToken,
      baseUrl: baseUrl ?? this.baseUrl,
      pollInterval: pollInterval ?? this.pollInterval,
      exemptionTime: exemptionTime ?? this.exemptionTime,
      recentCalls: this.recentCalls,
    );
  }
}

class ConfigService {
  File get _configFile {
    final appDir = Directory(path.join(
        Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'] ?? '.',
        '.telavox-monitor'
    ));

    if (!appDir.existsSync()) {
      appDir.createSync(recursive: true);
    }

    return File(path.join(appDir.path, 'config.json'));
  }

  Future<Config> loadConfig() async {
    if (!_configFile.existsSync()) {
      return Config(); // Return default config
    }

    try {
      final contents = await _configFile.readAsString();
      final Map<String, dynamic> json = jsonDecode(contents);

      return Config(
        jwtToken: json['credentials']?['jwt_token'],
        baseUrl: json['settings']?['base_url'] ?? 'https://api.telavox.se',
        pollInterval: json['settings']?['poll_interval'] ?? 5,
        exemptionTime: json['settings']?['exemption_time'] ?? 2,
        recentCalls: json['recent_calls'],
      );
    } catch (e) {
      // If there's an error reading the config, return default
      return Config();
    }
  }

  Future<void> updateConfig({
    String? jwtToken,
    String? baseUrl,
    int? pollInterval,
    int? exemptionTime,
  }) async {
    final currentConfig = await loadConfig();

    final newConfig = currentConfig.copyWith(
      jwtToken: jwtToken,
      baseUrl: baseUrl,
      pollInterval: pollInterval,
      exemptionTime: exemptionTime,
    );

    await _configFile.writeAsString(
        JsonEncoder.withIndent('  ').convert(newConfig.toJson())
    );
  }
}

