import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart';

import '../statics.dart';
import 'clipboard_watcher_config.dart';

class AppConfig {
  AppConfig({
    required this.selectedDirectories,
    required this.isVerbose,
    required this.supportedExtensions,
    required this.workingDirectory,
    required this.startingOffset,
    required this.endingOffset,
    required this.tempOutputFile,
    required this.watch,
    required this.regex,
    required this.localeDirectory,
    this.clipWatcherConfig,
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
  final String tempOutputFile;
  final bool watch;
  final String localeDirectory;
  final ClipWatcherConfig? clipWatcherConfig;
  final String appVersion = '1.0.0';

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
      tempOutputFile: parseResult['output'],
      endingOffset: int.tryParse(parseResult['end_offset']) ?? 0,
      startingOffset: int.tryParse(parseResult['start_offset']) ?? 0,
      regex: parseResult['regex'],
      clipWatcherConfig: ClipWatcherConfig(
        regex: parseResult['regex'],
        interval: 150,
        startingOffset: int.tryParse(parseResult['start_offset']) ?? 0,
        endingOffset: int.tryParse(parseResult['end_offset']) ?? 0,
      ),
    );
    final saveConfig = parseResult['save'] == true;
    switch (parseResult['config']) {
      case 'local':
        if (saveConfig) {
          localConfig = config;
          final multiConfig = File(multiConfigFile);
          if (!multiConfig.existsSync()) {
            File(multiConfigFile).writeAsStringSync(
              jsonEncode(
                [
                  config.toMap(),
                ],
              ),
            );
          }
        } else {
          final cache = localConfig;
          config = cache.copyWith(
            watch: config.watch || cache.watch,
            isVerbose: config.isVerbose || cache.isVerbose,
          );
        }
        break;
      case 'global':
        if (saveConfig) {
          globalConfig = config;
        } else {
          if (globalConfigFile.existsSync()) {
            final cache = globalConfig;
            config = cache.copyWith(
              localeDirectory: config.localeDirectory,
              workingDirectory: config.workingDirectory,
              tempOutputFile: config.tempOutputFile,
              watch: config.watch || cache.watch,
              isVerbose: config.isVerbose || cache.isVerbose,
            );
          } else {
            if (config.isVerbose) {
              print('requested to get global config file but no config file provided');
              print('maybe its first runtime so one will be created');
            }
            print('creating global config file at ${globalConfigFile.path}');
            globalConfig = config;
          }
        }
        break;
      default:
    }

    if (config.isVerbose) {
      print('app loaded in verbose mode on');
      print('app config is : $config');
    }
    config.updateGitignore(
      [
        config.tempOutputFile,
      ],
    );
    return config;
  }
  void updateGitignore(List<String> items) {
    final gitignore = File(join(workingDirectory, '.gitignore'));

    if (gitignore.existsSync()) {
      for (final item in items) {
        final lines = gitignore.readAsLinesSync();
        if (!lines.contains(item)) {
          gitignore.writeAsStringSync(
            '${lines.join('\n')}\n$item',
            mode: FileMode.append,
          );
        }
      }
    }
  }

  @override
  String toString() {
    return 'AppConfig(selectedDirectories: $selectedDirectories, isVerbose: $isVerbose, supportedExtensions: $supportedExtensions, workingDirectory: $workingDirectory, startingOffset: $startingOffset, endingOffset: $endingOffset, tempOutputFile: $tempOutputFile, watch: $watch, localeDirectory: $localeDirectory)';
  }

  AppConfig copyWith({
    List<String>? selectedDirectories,
    bool? isVerbose,
    List<String>? supportedExtensions,
    String? workingDirectory,
    int? startingOffset,
    int? endingOffset,
    String? regex,
    String? tempOutputFile,
    bool? watch,
    String? localeDirectory,
    ClipWatcherConfig? clipWatcherConfig,
  }) {
    return AppConfig(
      selectedDirectories: selectedDirectories ?? this.selectedDirectories,
      isVerbose: isVerbose ?? this.isVerbose,
      supportedExtensions: supportedExtensions ?? this.supportedExtensions,
      workingDirectory: workingDirectory ?? this.workingDirectory,
      startingOffset: startingOffset ?? this.startingOffset,
      endingOffset: endingOffset ?? this.endingOffset,
      tempOutputFile: tempOutputFile ?? this.tempOutputFile,
      watch: watch ?? this.watch,
      regex: regex ?? this.regex,
      clipWatcherConfig: clipWatcherConfig ?? this.clipWatcherConfig,
      localeDirectory: localeDirectory ?? this.localeDirectory,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'selectedDirectories': selectedDirectories,
      'supportedExtensions': supportedExtensions,
      'workingDirectory': workingDirectory,
      'localeDirectory': localeDirectory,
      'tempOutputFile': tempOutputFile,
      'regex': regex,
      'startingOffset': startingOffset,
      'endingOffset': endingOffset,
      'watch': watch,
      'isVerbose': isVerbose,
      'appVersion': appVersion,
      if (clipWatcherConfig != null) 'clipWatcherConfig': clipWatcherConfig?.toMap(),
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
      tempOutputFile: map['tempOutputFile'] ?? '',
      watch: map['watch'] ?? false,
      regex: map['regex'] ?? '',
      clipWatcherConfig: map['clipWatcherConfig'] != null ? ClipWatcherConfig.fromMap(map['clipWatcherConfig']) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory AppConfig.fromJson(String source) => AppConfig.fromMap(json.decode(source));
}

String get globalAppConfigPath {
  final exeFile = File(Platform.resolvedExecutable);
  final exeDir = exeFile.parent.path;
  return join(exeDir, basicConfigFileName);
}

String get localAppConfigPath {
  final local = Directory.current.path;
  return join(local, basicConfigFileName);
}

File globalConfigFile = File(globalAppConfigPath);
AppConfig get globalConfig => AppConfig.fromJson(globalConfigFile.readAsStringSync());
set globalConfig(AppConfig config) => File(globalAppConfigPath).writeAsStringSync(config.toJson());
final localConfigFile = File(localAppConfigPath);
AppConfig get localConfig => AppConfig.fromJson(localConfigFile.readAsStringSync());
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
    defaultsTo: "(\\\$t\\((\\'|\\\")([^()\\n])*(\\'|\\\")\\))",
    valueHelp:
        'regex pattern to find translations default bad-words are one of `) or (` this characters count as breaker',
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
    defaultsTo: '.translations.json',
    valueHelp: 'output file path',
    abbr: 'o',
  )
  ..addFlag(
    'watch',
    abbr: 'w',
    help: 'watch for changes in the working directory (this flag will cause the program to run in a loop)',
    defaultsTo: false,
  )
  ..addFlag(
    'verbose',
    abbr: 'v',
    defaultsTo: false,
  )
  ..addOption(
    'config',
    abbr: 'c',
    defaultsTo: 'args',
    allowed: [
      'local',
      'global',
      'args',
    ],
    help:
        '''config scope (in global scope the config will be saved next to executable file of translate_finder in this case ${Platform.resolvedExecutable})
notes:
  - in global scope values of 
    - localeDirectory
    - workingDirectory
    - tempOutputFile
    will be overwritten by values from args or default settings

  - in both local and global scope values of
    - isForced
    - watch
    - isVerbose
    is result of "or (||)" of args and the config file.
    if args is set to true then the loaded config value is ignored and wise versa''',
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
