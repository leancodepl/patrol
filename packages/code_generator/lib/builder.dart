import 'package:build/build.dart';
import 'package:code_generator/key_generator.dart';
import 'package:code_generator/object_model_generator.dart';
import 'package:source_gen/source_gen.dart';

Builder keyBuilder(BuilderOptions options) =>
    SharedPartBuilder([KeyGenerator()], 'keys');

Builder objectModelBuilder(BuilderOptions options) => LibraryBuilder(
      ObjectModelGenerator(),
      options: options,
    );
