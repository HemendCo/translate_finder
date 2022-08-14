import 'dart:io';

import 'package:path/path.dart';
import 'package:trans_finder/core/arg_parser/arg_parser.dart';
import 'package:trans_finder/core/dependency_injector/basic_dependency_injector.dart';
import 'package:trans_finder/features/generate_map/generate_map.dart';
import 'package:trans_finder/features/get_trans_texts/get_trans_texts.dart';
import 'package:trans_finder/features/save_output/save_output.dart';
import 'package:trans_finder/features/update_current_locales/update_current_locales.dart';

void main(List<String> arguments) {
  coreApp(arguments);
}

void coreApp(List<String> args) {
  final config = AppConfig.fromArgs(args);
  deInjector.register(config);
  doTheJob();
  if (config.watch) {
    activeWatch(config);
  }
}

void activeWatch(AppConfig config) {
  for (final i in config.selectedDirectories) {
    final dir = Directory(join(config.workingDirectory, i));
    if (dir.existsSync()) {
      print('watching ${dir.path}');
      dir.watch(events: FileSystemEvent.modify).listen((event) async {
        print('change found in ${event.path}');
        await doTheJob([event.path]);
      });
    } else {
      print('cannot watch ${dir.path} because it does not exists');
    }
  }
}

Future<void> doTheJob([List<String>? override]) async {
  final samples = getTransTexts(override);
  final output = generateMap(samples);
  await saveOutput(output);
  updateCurrentLocalesWith(output);
}
