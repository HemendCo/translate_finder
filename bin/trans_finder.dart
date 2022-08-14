import 'package:trans_finder/core/arg_parser/arg_parser.dart';
import 'package:trans_finder/core/dependency_injector/basic_dependency_injector.dart';
import 'package:trans_finder/features/generate_map/generate_map.dart';
import 'package:trans_finder/features/get_trans_texts/get_trans_texts.dart';
import 'package:trans_finder/features/save_output/save_output.dart';

void main(List<String> arguments) {
  final config = AppConfig.fromArgs(arguments);
  deInjector.register(config);
  final samples = getTransTexts();
  saveOutput(generateMap(samples));
}
