import 'dart:io';

import 'package:args/args.dart';

class AppConfig {
  AppConfig({
    required this.isVerbose,
    required this.selectedDirectories,
    required this.supportedExtensions,
    required this.workingDirectory,
    required this.startingOffset,
    required this.endingOffset,
    required this.regex,
    required this.outputFile,
    required this.isForced,
  }) : assert(
          supportedExtensions.isNotEmpty,
        );
  final List<String> selectedDirectories;
  final bool isVerbose;
  final List<String> supportedExtensions;
  final String workingDirectory;
  final RegExp regex; // = RegExp(r'(\$t\()(.*)(\))');
  final int startingOffset;
  final int endingOffset;
  final String outputFile;
  final bool isForced;
  factory AppConfig.fromArgs(List<String> args) {
    final commandParser = ArgParser()
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
        'regex',
        callback: (p0) {
          if (p0 == null) {
            print('don\'t forget to specify the regex');
            exit(64);
          }
        },
        defaultsTo: r'(\$t\()(.*)(\))',
        valueHelp: 'regex pattern to find translations',
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
        'verbose',
        abbr: 'v',
        defaultsTo: false,
      )
      ..addFlag(
        'force',
        abbr: 'f',
        defaultsTo: false,
      )
      ..addFlag(
        'help',
        abbr: 'h',
        help: 'show help',
      );

    final parseResult = commandParser.parse(args);
    if (parseResult['help'] == true) {
      print(commandParser.usage);
      exit(0);
    }
    final config = AppConfig(
      selectedDirectories: parseResult['include'],
      isVerbose: parseResult['verbose'] == true,
      supportedExtensions: parseResult['extensions'] ?? [],
      workingDirectory: parseResult['directory'],
      outputFile: parseResult['output'],
      isForced: parseResult['force'],
      endingOffset: int.tryParse(parseResult['end_offset']) ?? 0,
      startingOffset: int.tryParse(parseResult['start_offset']) ?? 0,
      regex: RegExp(parseResult['regex']),
    );
    if (config.isVerbose) {
      print('app loaded in verbose mode on');
      print('app config is : $config');
    }
    return config;
  }

  @override
  String toString() {
    return '''
    selectedDirectories: $selectedDirectories, 
    isVerbose: $isVerbose, 
    supportedExtensions: $supportedExtensions, 
    workingDirectory: $workingDirectory
    ''';
  }
}
