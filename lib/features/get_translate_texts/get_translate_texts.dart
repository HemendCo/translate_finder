import 'dart:io';

import 'package:translate_finder/core/arg_parser/arg_parser.dart';
import 'package:translate_finder/core/dependency_injector/basic_dependency_injector.dart';
import 'package:translate_finder/features/verbose_log/verbose_log.dart';

import '../file_locator/file_list_locator.dart';
import '../regex_finder/translate_finder.dart';

Iterable<String> getTransTexts([List<String>? overRidingPath]) sync* {
  final config = deInjector.get<AppConfig>();
  verbosePrint('getting all files');
  RegExp regex = RegExp(config.regex);
  final files = overRidingPath ?? getAllFiles();
  verbosePrint('files found: ${files.length}');
  for (final file in files) {
    verbosePrint('processing file: $file');
    final text = File(file).readAsStringSync();
    final samples = sampleFinder(regex, text);
    for (final i in samples) {
      yield i;
    }
  }
}
