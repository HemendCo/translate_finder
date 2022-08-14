import 'dart:convert';
import 'dart:io';

import 'package:trans_finder/core/arg_parser/arg_parser.dart';
import 'package:trans_finder/core/dependency_injector/basic_dependency_injector.dart';
import 'package:trans_finder/features/verbose_log/verbose_log.dart';

void updateCurrentLocalesWith(Map<String, String> update) {
  final config = deInjector.get<AppConfig>();
  final dir = Directory(config.localeDirectory);
  if (dir.existsSync()) {
    final files = dir.listSync(recursive: true);
    for (final file in files) {
      if (file is File) {
        final fileName = file.path.split('/').last;
        final fileExtension = fileName.split('.').last;
        if (fileExtension == 'json') {
          final fileContent = Map<String, String>.from(jsonDecode(file.readAsStringSync()));
          final addedKeys = update.keys.where((element) => !fileContent.containsKey(element));
          for (final i in addedKeys) {
            fileContent[i] = i;
          }
          file.writeAsStringSync(jsonEncode(fileContent));
        }
      }
    }
  } else {
    verbosePrint('no locales directory found skipping update phase');
  }
}
