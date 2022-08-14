import '../../core/arg_parser/arg_parser.dart';
import '../../core/dependency_injector/basic_dependency_injector.dart';

void verbosePrint(Object? object) {
  final config = deInjector.get<AppConfig>();
  if (config.isVerbose) {
    print(object);
  }
}
