import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';
import 'package:translate_finder/core/arg_parser/arg_parser.dart';
import 'package:translate_finder/core/dependency_injector/basic_dependency_injector.dart';
import 'package:translate_finder/core/statics.dart';
import 'package:translate_finder/features/generate_map/generate_map.dart';
import 'package:translate_finder/features/get_translate_texts/get_translate_texts.dart';
import 'package:translate_finder/features/save_output/save_output.dart';
import 'package:translate_finder/features/update_current_locales/update_current_locales.dart';

void main(List<String> arguments) {
  if (arguments.contains('--multi') || arguments.contains('-m')) {
    final configsFile = File(multiConfigFile);
    if (configsFile.existsSync()) {
      final configs = configsFile.readAsStringSync();
      final configsMap = jsonDecode(configs);

      final configsList = (configsMap as List).map((e) => Map<String, dynamic>.from(e));
      for (final configMap in configsList) {
        final config = AppConfig.fromMap(configMap);
        runApp(config);
      }
    } else {
      print('No configs file found create one named `$multiConfigFile`');
      exit(64);
    }
  } else {
    final config = AppConfig.fromArgs(arguments);
    runApp(config);
  }
}

void runApp(AppConfig config) {
  deInjector.register(config);
  doTheJob(config);
  if (config.watch) {
    activeWatch(config);
  }
}

void activeWatch(AppConfig config) {
  for (final i in config.selectedDirectories) {
    final dir = Directory(join(config.workingDirectory, i));
    if (dir.existsSync()) {
      print('watching ${dir.path}');
      dir
          .watch(
        events: FileSystemEvent.modify,
        recursive: true,
      )
          .listen(
        (event) async {
          if (config.supportedExtensions.contains(event.path.split('.').last)) {
            print('change found in ${event.path}');
            doTheJob(
              config,
              overrideFiles: [event.path],
            );
          }
        },
      );
    } else {
      print('cannot watch ${dir.path} because it does not exists');
    }
  }
}

Future<void> doTheJob(
  AppConfig config, {
  List<String>? overrideFiles,
  List<String>? overrideSamples,
}) async {
  final samples = overrideSamples ?? getTransTexts(overrideFiles);
  final output = generateMap(samples);

  saveOutput(output);
  updateCurrentLocalesWith(output);
}
