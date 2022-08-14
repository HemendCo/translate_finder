import '../../core/arg_parser/arg_parser.dart';
import '../../core/dependency_injector/basic_dependency_injector.dart';

bool? isVerbose;
void verbosePrint(Object? object) {
  isVerbose ??= deInjector.get<AppConfig>().isVerbose;
  if (isVerbose == true) {
    print(object);
  }
}
