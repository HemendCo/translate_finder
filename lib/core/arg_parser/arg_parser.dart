import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart';

class AppConfig {
  AppConfig({
    required this.selectedDirectories,
    required this.isVerbose,
    required this.supportedExtensions,
    required this.workingDirectory,
    required this.startingOffset,
    required this.endingOffset,
    required this.outputFile,
    required this.isForced,
    required this.watch,
    required this.regex,
    required this.localeDirectory,
  }) : assert(
          supportedExtensions.isNotEmpty,
        );
  final List<String> selectedDirectories;
  final bool isVerbose;
  final List<String> supportedExtensions;
  final String workingDirectory;
  final String regex; // = RegExp(r'(\$t\()(.*)(\))');
  final int startingOffset;
  final int endingOffset;
  final String outputFile;
  final bool isForced;
  final bool watch;
  final String localeDirectory;

  factory AppConfig.fromArgs(List<String> args) {
    final parseResult = appConfigParser.parse(args);
    if (parseResult['help'] == true) {
      print(appConfigParser.usage);
      exit(0);
    }
    var config = AppConfig(
      watch: parseResult['watch'],
      localeDirectory: parseResult['locale_directory'],
      selectedDirectories: parseResult['include'],
      isVerbose: parseResult['verbose'] == true,
      supportedExtensions: parseResult['extensions'] ?? [],
      workingDirectory: parseResult['directory'],
      outputFile: parseResult['output'],
      isForced: parseResult['force'] || parseResult['watch'],
      endingOffset: int.tryParse(parseResult['end_offset']) ?? 0,
      startingOffset: int.tryParse(parseResult['start_offset']) ?? 0,
      regex: parseResult['regex'],
    );
    final saveConfig = parseResult['save'] == true;
    switch (parseResult['config']) {
      case 'local':
        if (saveConfig) {
          localConfig = config;
        } else {
          config = localConfig;
        }
        break;
      case 'global':
        if (saveConfig) {
          globalConfig = config;
        } else {
          config = globalConfig;
        }
        break;
      default:
    }

    if (config.isVerbose) {
      print('app loaded in verbose mode on');
      print('app config is : $config');
    }
    return config;
  }

  @override
  String toString() {
    return 'AppConfig(selectedDirectories: $selectedDirectories, isVerbose: $isVerbose, supportedExtensions: $supportedExtensions, workingDirectory: $workingDirectory, startingOffset: $startingOffset, endingOffset: $endingOffset, outputFile: $outputFile, isForced: $isForced, watch: $watch, localeDirectory: $localeDirectory)';
  }

  AppConfig copyWith({
    List<String>? selectedDirectories,
    bool? isVerbose,
    List<String>? supportedExtensions,
    String? workingDirectory,
    int? startingOffset,
    int? endingOffset,
    String? regex,
    String? outputFile,
    bool? isForced,
    bool? watch,
    String? localeDirectory,
  }) {
    return AppConfig(
      selectedDirectories: selectedDirectories ?? this.selectedDirectories,
      isVerbose: isVerbose ?? this.isVerbose,
      supportedExtensions: supportedExtensions ?? this.supportedExtensions,
      workingDirectory: workingDirectory ?? this.workingDirectory,
      startingOffset: startingOffset ?? this.startingOffset,
      endingOffset: endingOffset ?? this.endingOffset,
      outputFile: outputFile ?? this.outputFile,
      isForced: isForced ?? this.isForced,
      watch: watch ?? this.watch,
      regex: regex ?? this.regex,
      localeDirectory: localeDirectory ?? this.localeDirectory,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'selectedDirectories': selectedDirectories,
      'supportedExtensions': supportedExtensions,
      'workingDirectory': workingDirectory,
      'localeDirectory': localeDirectory,
      'startingOffset': startingOffset,
      'endingOffset': endingOffset,
      'outputFile': outputFile,
      'isVerbose': isVerbose,
      'isForced': isForced,
      'regex': regex,
      'watch': watch,
    };
  }

  factory AppConfig.fromMap(Map<String, dynamic> map) {
    return AppConfig(
      selectedDirectories: List<String>.from(map['selectedDirectories']),
      supportedExtensions: List<String>.from(map['supportedExtensions']),
      startingOffset: map['startingOffset']?.toInt() ?? 0,
      workingDirectory: map['workingDirectory'] ?? '',
      endingOffset: map['endingOffset']?.toInt() ?? 0,
      localeDirectory: map['localeDirectory'] ?? '',
      isVerbose: map['isVerbose'] ?? false,
      outputFile: map['outputFile'] ?? '',
      isForced: (map['isForced'] ?? false) || (map['watch'] ?? false),
      watch: map['watch'] ?? false,
      regex: map['regex'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory AppConfig.fromJson(String source) => AppConfig.fromMap(json.decode(source));
}

String get globalAppConfigPath {
  final exeFile = File(Platform.resolvedExecutable);
  final exeDir = exeFile.parent.path;
  return join(exeDir, 'translate_finder_config.json');
}

String get localAppConfigPath {
  final local = Directory.current.path;
  return join(local, 'translate_finder_config.json');
}

AppConfig get globalConfig => AppConfig.fromJson(File(globalAppConfigPath).readAsStringSync());
set globalConfig(AppConfig config) => File(globalAppConfigPath).writeAsStringSync(config.toJson());

AppConfig get localConfig => AppConfig.fromJson(File(localAppConfigPath).readAsStringSync());
set localConfig(AppConfig config) => File(localAppConfigPath).writeAsStringSync(config.toJson());

final appConfigParser = ArgParser(
  usageLineLength: 400,
  allowTrailingOptions: true,
)
  ..addMultiOption(
    'extensions',
    defaultsTo: [
      'vue',
      'js',
      'ts',
    ],
    aliases: ['ext'],
    help: 'supported file extensions',
  )
  ..addMultiOption(
    'include',
    defaultsTo: [
      'components',
      'pages',
    ],
    aliases: ['inc'],
    help: 'directories to look for translations',
  )
  ..addOption(
    'directory',
    abbr: 'd',
    callback: (p0) {
      if (p0 == null) {
        print('don\'t forget to specify the working directory');
        exit(64);
      }
      if (!Directory(p0).existsSync()) {
        print('selected directory does not exists');
        exit(64);
      }
    },
    defaultsTo: Directory.current.path,
  )
  ..addOption(
    'locale_directory',
    abbr: 'l',
    help: 'default address to locales directory',
    defaultsTo: '${Directory.current.path}/locales',
  )
  ..addOption(
    'regex',
    callback: (p0) {
      if (p0 == null) {
        print('don\'t forget to specify the regex');
        exit(64);
      }
    },
    defaultsTo: r"(\$t\(([^}{<>\n])*\'\))",
    valueHelp: 'regex pattern to find translations default bad-words are one of `}, {, < and >`',
  )
  ..addOption(
    'start_offset',
    defaultsTo: '4',
    valueHelp: 'select text after matching with given regex pattern with this starting offset',
    callback: (p0) {
      if (int.tryParse(p0 ?? 'err') == null) {
        print('start_offset must be an integer');
        exit(64);
      }
    },
  )
  ..addOption(
    'end_offset',
    defaultsTo: '-2',
    valueHelp: 'select text after matching with given regex pattern with this ending offset',
    callback: (p0) {
      if (int.tryParse(p0 ?? 'err') == null) {
        print('end_offset must be an integer');
        exit(64);
      }
    },
  )
  ..addOption(
    'output',
    defaultsTo: 'translations.json',
    valueHelp: 'output file path',
    abbr: 'o',
  )
  ..addFlag(
    'watch',
    abbr: 'w',
    help:
        'watch for changes in the working directory (this flag will cause the program to run in a loop with force mode on)',
    defaultsTo: false,
  )
  ..addFlag(
    'verbose',
    abbr: 'v',
    defaultsTo: false,
  )
  ..addFlag(
    'force',
    abbr: 'f',
    defaultsTo: false,
  )
  ..addOption(
    'config',
    abbr: 'c',
    defaultsTo: 'none',
    allowed: [
      'local',
      'global',
      'none',
    ],
    help: 'config scope',
  )
  ..addFlag(
    'save',
    abbr: 's',
    defaultsTo: false,
    help: 'save the current config to local or global config',
  )
  ..addFlag(
    'help',
    abbr: 'h',
    help: 'show help',
  );
