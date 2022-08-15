import 'dart:convert';
import 'dart:io';

import 'package:translate_finder/core/arg_parser/arg_parser.dart';
import 'package:translate_finder/core/dependency_injector/basic_dependency_injector.dart';
import 'package:translate_finder/features/verbose_log/verbose_log.dart';

import '../file_slave/file_slave.dart';
import '../save_output/save_output.dart';

Future<void> updateCurrentLocalesWith(Map<String, String> update) async {
  final config = deInjector.get<AppConfig>();
  final dir = Directory(config.localeDirectory);
  if (dir.existsSync()) {
    final files = dir.listSync(recursive: true);
    for (final nFile in files) {
      if (nFile is File) {
        final file = FileSlave(nFile.path);
        verbosePrint('found locale file in ${file.path}');
        final fileName = file.path.split('/').last;
        final fileExtension = fileName.split('.').last;
        if (fileExtension == 'json') {
          final fileContent = Map<String, String>.from(jsonDecode(await file.read()));
          final fileKeys = fileContent.keys.map((e) => e).toList();
          final addedKeys = update.keys.map((e) => e).where((element) => !fileKeys.contains(element));
          for (final i in addedKeys) {
            fileContent[i] = i;
          }
          final json = formatOutput(fileContent);
          file.write(jsonEncode(json));
        }
      }
    }
  } else {
    verbosePrint('no locales directory found skipping update phase');
  }
}
