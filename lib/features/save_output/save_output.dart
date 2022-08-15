import 'dart:convert';
import 'dart:io';

import 'package:translate_finder/core/arg_parser/arg_parser.dart';
import 'package:translate_finder/core/dependency_injector/basic_dependency_injector.dart';
import 'package:translate_finder/features/verbose_log/verbose_log.dart';

String _applyRule(String input) {
  const rules = {
    r"\\'": "'",
    r"\'": "'",
    r'\\"': '"',
    r'\"': '"',
    r'\n': '\n',
    r'\\n': '\n',
    r'\\': r'\',
  };
  String out = input;
  for (final i in rules.entries) {
    out = out.replaceAll(i.key, i.value);
  }
  return out;
}

Map<String, String> formatOutput(Map<String, String> input) {
  final output = <String, String>{};
  for (final i in input.entries) {
    final keyVal = _applyRule(i.key);
    if (output[keyVal] == null) {
      final valueVal = _applyRule(i.value);
      output[keyVal] = valueVal;
    }
  }
  return output;
}

void saveOutput(Map<String, String> input) {
  final output = jsonEncode(formatOutput(input));
  final config = deInjector.get<AppConfig>();
  final oFile = File(config.tempOutputFile);
  verbosePrint('writing to temp file');
  return oFile.writeAsStringSync(output);
}
