import 'package:trans_finder/features/verbose_log/verbose_log.dart';

Map<String, String> generateMap(Iterable<String> values) {
  verbosePrint('found total of ${values.length} items');
  final set = values.toSet();
  verbosePrint('after removed duplicates: ${set.length} items');
  final map = <String, String>{};
  for (final i in set) {
    map[i] = i;
  }
  return map;
}
