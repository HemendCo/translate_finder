import 'package:bloc/bloc.dart';

import 'clipboard_ffi.dart';

class ClipboardWatcher extends Cubit<Iterable<String>> {
  ClipboardWatcher({
    RegExp? regex,
    this.delayDuration = const Duration(milliseconds: 35),
  })  : regex = regex ?? RegExp('.+'),
        super([]) {
    _watch();
  }
  final RegExp regex;
  final Duration delayDuration;
  bool _shouldWatch = true;

  Future<void> _watch() async {
    while (_shouldWatch) {
      final contents = Clipboard.getContents();
      if (regex.hasMatch(contents)) {
        final items = regex.allMatches(contents);
        final output = items.map((e) => e.group(0) ?? 'null found in regex');
        if (isAcceptable(output)) {
          emit(output);
        }
      }
      await Future.delayed(delayDuration);
    }
  }

  bool isAcceptable(Iterable input) {
    if (state.length == input.length) {
      for (int i = 0; i < state.length; i++) {
        if (state.elementAt(i) != input.elementAt(i)) {
          return true;
        }
      }
      return false;
    }
    return true;
  }

  @override
  Future<void> close() async {
    _shouldWatch = false;
    await super.close();
  }
}
