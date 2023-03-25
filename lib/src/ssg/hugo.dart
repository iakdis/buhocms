import 'dart:io';

import 'package:yaml/yaml.dart';

import '../utils/preferences.dart';

class Hugo {
  static String getValue(String source) {
    final yaml = loadYaml(source) as YamlMap;
    return yaml.entries.first.value.toString();
  }

  static String getHugoTheme() {
    final sitePath = '${Preferences.getSitePath()}${Platform.pathSeparator}';
    File? config;
    final toml = File('${sitePath}config.toml');
    final yaml = File('${sitePath}config.yaml');
    final json = File('${sitePath}config.json');
    final tomlExists = toml.existsSync();
    final yamlExists = yaml.existsSync();
    final jsonExists = json.existsSync();
    if (tomlExists) config = toml;
    if (yamlExists) config = yaml;
    if (jsonExists) config = json;

    var theme = '';
    final configLines = config?.readAsLinesSync() ?? [];
    for (var i = 0; i < configLines.length; i++) {
      final configLine = configLines[i];
      if (tomlExists) {
        if (configLine.startsWith('theme')) {
          theme = configLine.substring(9, configLine.length - 1); //TODO toml
        }
      } else if (yamlExists) {
        if (configLine.startsWith('theme')) {
          theme = configLine.substring(9, configLine.length - 1); //TODO yaml
        }
      } else if (jsonExists) {
        if (configLine.startsWith('"theme"')) {
          theme = configLine.substring(9, configLine.length - 1); //TODO json
        }
      }
    }

    return theme;
  }

  static Future<void> setHugoTheme(String theme) async {
    final sitePath = '${Preferences.getSitePath()}${Platform.pathSeparator}';

    File? config;
    final toml = File('${sitePath}config.toml');
    final yaml = File('${sitePath}config.yaml');
    final json = File('${sitePath}config.json');
    final tomlExists = toml.existsSync();
    final yamlExists = yaml.existsSync();
    final jsonExists = json.existsSync();
    if (tomlExists) config = toml;
    if (yamlExists) config = yaml;
    if (jsonExists) config = json;
    var themeEntryExists = false;

    final configLines = await config?.readAsLines() ?? [];
    for (var i = 0; i < configLines.length; i++) {
      if (tomlExists) {
        if (configLines[i].startsWith('theme')) {
          themeEntryExists = true;
          configLines[i] = 'theme = "$theme"';
        }
      } else if (yamlExists) {
        if (configLines[i].startsWith('theme')) {
          themeEntryExists = true;
          configLines[i] = 'theme: $theme';
        }
      } else if (jsonExists) {
        if (configLines[i].startsWith('"theme"')) {
          themeEntryExists = true;
          configLines[i] = '"theme": "$theme"';
        }
      }
    }
    if (!themeEntryExists) {
      if (tomlExists) {
        configLines.add('theme = "$theme"');
      } else if (yamlExists) {
        configLines.add('theme: $theme');
      } else if (jsonExists) {
        configLines.add('"theme": "$theme"');
      }
    }

    await config?.writeAsString(configLines.join('\n'));
  }
}
