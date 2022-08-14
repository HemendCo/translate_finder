import 'dart:io';

import 'package:trans_finder/core/arg_parser/arg_parser.dart';
import 'package:trans_finder/core/dependency_injector/basic_dependency_injector.dart';

import '../verbose_log/verbose_log.dart';

Iterable<String> getAllFiles() sync* {
  final config = deInjector.get<AppConfig>();
  final baseDir = config.workingDirectory;
  final includes = config.selectedDirectories;
  final extensions = config.supportedExtensions;
  for (final i in includes) {
    final dir = Directory('$baseDir/$i');
    if (dir.existsSync()) {
      final files = dir.listSync(recursive: true);
      for (final file in files) {
        if (file is File) {
          final fileName = file.path.split('/').last;
          final fileExtension = fileName.split('.').last;

          if (extensions.contains(fileExtension)) {
            verbosePrint('accepted file: $fileName');
            yield file.path;
          } else {
            verbosePrint('file extension mismatch: $fileName');
          }
        }
      }
    } else {
      verbosePrint('directory $i not found');
    }
  }
}
