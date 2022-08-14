import 'dart:convert';
import 'dart:io';

import 'package:translate_finder/core/arg_parser/arg_parser.dart';
import 'package:translate_finder/core/dependency_injector/basic_dependency_injector.dart';
import 'package:translate_finder/features/verbose_log/verbose_log.dart';

String formatOutput(String input) {
  const rules = {
    r"\\'": "'",
    r"\'": "'",
    r'\\"': '"',
    r'\"': '"',
    r'\\': r'\',
  };
  String output = input;
  for (final i in rules.entries) {
    output = output.replaceAll(i.key, i.value);
  }
  return output;
}

Future<void> saveOutput(Map<String, String> input) {
  final output = formatOutput(jsonEncode(input));
  final config = deInjector.get<AppConfig>();
  final oFile = File(config.outputFile);
  if (oFile.existsSync()) {
    if (config.isForced) {
      verbosePrint('output file found but forced to overwrite');
      return oFile.writeAsString(output);
    } else {
      print('output file found do you want to override it? (y/n)');
      final input = stdin.readLineSync();
      if (input == 'y') {
        verbosePrint('output file found but forced to overwrite');
        return oFile.writeAsString(output);
      } else {
        verbosePrint('output file found but not forced to overwrite');

        exit(1);
      }
    }
  } else {
    verbosePrint('output file not found creating one');
    oFile.createSync();
    return oFile.writeAsString(output);
  }
}
