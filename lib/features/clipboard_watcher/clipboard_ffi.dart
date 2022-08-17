import 'dart:io';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:translate_finder/features/verbose_log/verbose_log.dart';

/// rust libs can be found in (release)[https://github.com/FMotalleb/libclipboard/releases/tag/0.2.1]
/// Type of set_contents method on Rust side.
typedef RustSetContents = Void Function(Pointer<Utf8>);

/// Type of get_contents method on Rust side.
typedef RustGetContents = Pointer<Utf8> Function();

/// Type of set_contents method on Dart side.
typedef DartSetContents = void Function(Pointer<Utf8>);

/// Type of get_contents method on Dart side.
typedef DartGetContents = Pointer<Utf8> Function();

/// Class for operating the clipboard.
///
/// ## How to use
///
/// ### getContents
///
/// Get contents of the clipboard.
///
/// ```dart
/// var contents = Clipboard.getContents();
/// ```
///
/// ### setContents
///
/// Set contents to the clipboard.
///
/// ```dart
/// var contents = "All the world's a stage";
/// Clipboard.setContents(contents);
/// ```
class Clipboard {
  /// Get clipboard contents as [String].
  static DynamicLibrary libCache = _loadLib();
  static final LazyInstance<DartGetContents> _getContentsMethodPointer = LazyInstance(
    () => libCache.lookup<NativeFunction<RustGetContents>>('get_contents').asFunction(),
  );
  static final DartSetContents _setContentsMethodPointer =
      libCache.lookup<NativeFunction<RustSetContents>>('set_contents').asFunction();
  static String getContents() {
    return _getContentsMethodPointer.instance().toDartString();
  }

  /// Set contents received to the clipboard.
  ///
  /// The type of the argument is [String].
  static void setContents(String contents) {
    var ptr = contents.toNativeUtf8();
    _setContentsMethodPointer(ptr);
  }

  static final List<String> _libDirs = [
    // Directory.current.path,
    // Platform.script.path,
    Platform.resolvedExecutable,
  ];

  /// Load the dynamic library according to the platform.
  ///
  /// Returns a [DynamicLibrary] instance.
  ///
  /// If you call [_loadLib] from an unsupported platform, it throws
  /// PlatformException.
  static DynamicLibrary _loadLib() {
    for (final dir in _libDirs) {
      var libPath = dir.replaceAll(RegExp(r'[^/]+$'), '');

      if (Platform.isWindows) {
        if (libPath[0] == '/') libPath = libPath.replaceFirst('/', '');
        libPath += 'libclipboard.dll';
      } else if (Platform.isMacOS) {
        libPath += 'libclipboard.dylib';
      } else if (Platform.isLinux) {
        libPath += 'libclipboard.so';
      } else {
        throw OSError('${Platform.operatingSystem} is not supported.');
      }
      if (File(libPath).existsSync()) {
        verbosePrint('lib found at $libPath');
        return DynamicLibrary.open(libPath);
      } else {
        verbosePrint('lib not found at $libPath. Trying next.');
      }
    }
    throw Exception('dll is not found. scanned $_libDirs');
  }
}

class LazyInstance<T> {
  T? _instance;
  bool get isInitialized => _instance != null;
  T get instance {
    _instance ??= _createInstance();
    return _instance!;
  }

  final T Function() _createInstance;

  LazyInstance(this._createInstance);
  void reset() {
    _instance = _createInstance();
  }
}
