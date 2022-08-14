import 'dart:io';

import 'package:trans_finder/core/arg_parser/arg_parser.dart';
import 'package:trans_finder/core/dependency_injector/basic_dependency_injector.dart';
import 'package:trans_finder/features/verbose_log/verbose_log.dart';

import '../file_locator/file_list_locator.dart';
import '../regex_finder/trans_finder.dart';

Iterable<String> getTransTexts() sync* {
  final config = deInjector.get<AppConfig>();
  verbosePrint('getting all files');

  final files = getAllFiles();
  verbosePrint('files found: ${files.length}');
  for (final file in files) {
    verbosePrint('processing file: $file');
    final text = File(file).readAsStringSync();
    final samples = sampleFinder(config.regex, text);
    for (final i in samples) {
      yield i;
    }
  }
}
