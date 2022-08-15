import 'dart:io' as io;

import 'package:translate_finder/features/verbose_log/verbose_log.dart';

class FileSlave {
  static final Map<String, FileSlave> _instance = {};
  static const _refreshDelay = Duration(milliseconds: 15);
  factory FileSlave(String source) {
    _instance[source] ??= FileSlave._(io.File(source));
    return _instance[source]!;
  }
  FileSlave._(this.sourceFile);

  final io.File sourceFile;
  String get path => sourceFile.path;
  List<String> tasks = [];
  void write(String data) {
    tasks.add(data);
    sourceFile.writeAsStringSync(data);
    tasks.remove(data);
  }

  Future<String> read() async {
    while (tasks.isNotEmpty) {
      verbosePrint('file ${path} is busy, going to lockdown state for next cycle');
      await Future.delayed(_refreshDelay);
    }
    return sourceFile.readAsString();
  }
}
