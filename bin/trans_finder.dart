import 'dart:io';

import 'package:trans_finder/core/arg_parser/arg_parser.dart';
import 'package:trans_finder/core/dependency_injector/basic_dependency_injector.dart';
import 'package:trans_finder/features/generate_map/generate_map.dart';
import 'package:trans_finder/features/get_trans_texts/get_trans_texts.dart';
import 'package:trans_finder/features/save_output/save_output.dart';
import 'package:trans_finder/features/update_current_locales/update_current_locales.dart';

void main(List<String> arguments) {
  final config = AppConfig.fromArgs(arguments);
  deInjector.register(config);

  if (config.watch) {
    doTheJob();
    Directory(config.workingDirectory).watch().listen((event) {
      doTheJob();
    });
  } else {
    doTheJob();
  }
}

void doTheJob() {
  final samples = getTransTexts();
  final output = generateMap(samples);
  saveOutput(output);
  updateCurrentLocalesWith(output);
}
