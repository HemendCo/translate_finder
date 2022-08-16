import 'dart:convert';

class ClipWatcherConfig {
  final String regex;
  final int interval;
  final int startingOffset;
  final int endingOffset;
  Duration get intervalDuration => Duration(milliseconds: interval);
  const ClipWatcherConfig({
    required this.regex,
    required this.interval,
    required this.startingOffset,
    required this.endingOffset,
  });

  ClipWatcherConfig copyWith({
    String? regex,
    int? interval,
    int? startingOffset,
    int? endingOffset,
  }) {
    return ClipWatcherConfig(
      regex: regex ?? this.regex,
      interval: interval ?? this.interval,
      startingOffset: startingOffset ?? this.startingOffset,
      endingOffset: endingOffset ?? this.endingOffset,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'regex': regex,
      'interval': interval,
      'startingOffset': startingOffset,
      'endingOffset': endingOffset,
    };
  }

  factory ClipWatcherConfig.fromMap(Map<String, dynamic> map) {
    return ClipWatcherConfig(
      regex: map['regex'],
      interval: map['interval']?.toInt() ?? 0,
      startingOffset: map['startingOffset']?.toInt() ?? 0,
      endingOffset: map['endingOffset']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory ClipWatcherConfig.fromJson(String source) => ClipWatcherConfig.fromMap(json.decode(source));

  @override
  String toString() {
    return 'ClipWatcherConfig(regex: $regex, interval: $interval, startingOffset: $startingOffset, endingOffset: $endingOffset)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ClipWatcherConfig &&
        other.regex == regex &&
        other.interval == interval &&
        other.startingOffset == startingOffset &&
        other.endingOffset == endingOffset;
  }

  @override
  int get hashCode {
    return regex.hashCode ^ interval.hashCode ^ startingOffset.hashCode ^ endingOffset.hashCode;
  }
}
