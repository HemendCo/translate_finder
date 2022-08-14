import 'package:trans_finder/core/arg_parser/arg_parser.dart';
import 'package:trans_finder/core/dependency_injector/basic_dependency_injector.dart';
import 'package:trans_finder/features/verbose_log/verbose_log.dart';

Iterable<String> sampleFinder(
  RegExp regex,
  String text,
) sync* {
  final mamad = regex.allMatches(text);

  final config = deInjector.get<AppConfig>();
  for (final i in mamad) {
    final startingPoint = i.start + config.startingOffset;
    final endingPoint = i.end + config.endingOffset;
    final effectiveString = text.substring(startingPoint, endingPoint);
    verbosePrint('found keyword $effectiveString');
    yield effectiveString;
  }
}
