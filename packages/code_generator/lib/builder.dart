import 'package:build/build.dart';
import 'package:code_generator/key_generator.dart';
import 'package:code_generator/object_model_generator.dart';
import 'package:source_gen/source_gen.dart';

Builder keyBuilder(BuilderOptions options) => LibraryBuilder(
      KeyGenerator(),
      generatedExtension: '.keys.dart',
      options: options,
    );

Builder objectModelBuilder(BuilderOptions options) => LibraryBuilder(
      ObjectModelGenerator(),
      generatedExtension: '.object_model.dart',
      options: options,
    );
