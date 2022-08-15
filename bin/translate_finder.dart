import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:translate_finder/core/arg_parser/arg_parser.dart';
import 'package:translate_finder/core/dependency_injector/basic_dependency_injector.dart';
import 'package:translate_finder/features/generate_map/generate_map.dart';
import 'package:translate_finder/features/get_translate_texts/get_translate_texts.dart';
import 'package:translate_finder/features/save_output/save_output.dart';
import 'package:translate_finder/features/update_current_locales/update_current_locales.dart';

void main(List<String> arguments) {
  final config = AppConfig.fromArgs(arguments);
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
          print('change found in ${event.path}');
          doTheJob(
            config,
            overrideFiles: [event.path],
          );
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
  if (config.awaitForTasks) {
    await saveOutput(output);
    await updateCurrentLocalesWith(output);
  } else {
    saveOutput(output);
    updateCurrentLocalesWith(output);
  }
}
