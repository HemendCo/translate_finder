import 'dart:convert';
import 'dart:io';

import 'package:translate_finder/core/arg_parser/arg_parser.dart';
import 'package:translate_finder/core/dependency_injector/basic_dependency_injector.dart';
import 'package:translate_finder/features/verbose_log/verbose_log.dart';

import '../save_output/save_output.dart';

Future<void> updateCurrentLocalesWith(Map<String, String> update) async {
  final config = deInjector.get<AppConfig>();
  final dir = Directory(config.localeDirectory);
  if (await dir.exists()) {
    await for (final file in dir.list(recursive: true)) {
      if (file is File) {
        verbosePrint('found locale file in ${file.path}');
        final fileName = file.path.split('/').last;
        final fileExtension = fileName.split('.').last;
        if (fileExtension == 'json') {
          final fileContent = Map<String, String>.from(jsonDecode(await file.readAsString()));
          final fileKeys = fileContent.keys.map((e) => formatOutput(e)).toList();
          final addedKeys = update.keys.map((e) => formatOutput(e)).where((element) => !fileKeys.contains(element));
          for (final i in addedKeys) {
            fileContent[i] = i;
          }
          await file.writeAsString(formatOutput(jsonEncode(fileContent)));
        }
      }
    }
  } else {
    verbosePrint('no locales directory found skipping update phase');
  }
}
