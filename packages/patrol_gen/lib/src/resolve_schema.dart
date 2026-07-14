import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:path/path.dart' as path;
import 'package:patrol_gen/src/schema.dart';

Future<Schema> resolveSchema(String schemaPath) async {
  final file = path.normalize(path.absolute(schemaPath));
  final result = await resolveFile(path: file);

  final enums = <Enum>[];
  final messages = <Message>[];
  final classServices = <ClassDeclaration>[];

  if (result is ResolvedUnitResult) {
    for (final declaration in result.unit.declarations) {
      if (declaration is EnumDeclaration) {
        final enumFields = declaration.body.constants.map((e) {
          final name = e.name.lexeme;
          final value =
              switch (e.arguments?.argumentList.arguments.firstOrNull) {
                final expression? =>
                  expression.toString().replaceAll("'", '').replaceAll('"', ''),
                _ => name,
              };
          return EnumField(name, value);
        }).toList();

        enums.add(Enum(declaration.namePart.typeName.lexeme, enumFields));
      } else if (declaration is ClassDeclaration) {
        if (declaration.abstractKeyword != null) {
          classServices.add(declaration);
        } else {
          messages.add(_createMessage(declaration));
        }
      }
    }
  }

  return Schema(
    enums,
    messages,
    classServices.map((e) => _createService(e, messages)).toList(),
  );
}

Service _createService(ClassDeclaration declaration, List<Message> messages) {
  final genericTypes =
      declaration.namePart.typeParameters?.typeParameters
          .map((e) => e.name.lexeme)
          .toSet() ??
      {};

  final iosGenConfig = ServiceGenConfig(
    needsClient: genericTypes.contains('IOSClient'),
    needsServer: genericTypes.contains('IOSServer'),
  );

  final dartGenConfig = ServiceGenConfig(
    needsClient: genericTypes.contains('DartClient'),
    needsServer: genericTypes.contains('DartServer'),
  );

  final androidGenConfig = ServiceGenConfig(
    needsClient: genericTypes.contains('AndroidClient'),
    needsServer: genericTypes.contains('AndroidServer'),
  );

  return Service(
    declaration.namePart.typeName.lexeme,
    iosGenConfig,
    dartGenConfig,
    androidGenConfig,
    declaration.body.members.whereType<MethodDeclaration>().map((method) {
      final returnType = method.returnType;
      if (returnType is NamedType) {
        final responseMessage = returnType.name.lexeme == 'void'
            ? null
            : messages.firstWhere((msg) => msg.name == returnType.name.lexeme);

        Message? requestMessage;
        if (method.parameters!.parameters.isNotEmpty) {
          final parameter = method.parameters!.parameters.first;
          final parameterTypeName = (parameter.type! as NamedType).name.lexeme;

          requestMessage = messages.firstWhere(
            (msg) => msg.name == parameterTypeName,
          );
        }

        return Endpoint(responseMessage, requestMessage, method.name.lexeme);
      } else {
        throw UnsupportedError('unsupported return type $returnType');
      }
    }).toList(),
  );
}

Message _createMessage(ClassDeclaration declaration) {
  return Message(
    declaration.namePart.typeName.lexeme,
    declaration.body.members
        .whereType<FieldDeclaration>()
        .map((e) => e.fields)
        .whereType<VariableDeclarationList>()
        .map((e) {
          final type = e.type;
          if (type is! NamedType) {
            throw UnsupportedError('unsupported type $type');
          }

          final arguments = type.typeArguments?.arguments;

          final fieldType = switch (type.type) {
            final t? when t.isDartCoreMap => switch (arguments) {
              [final NamedType key, final NamedType value] => MapFieldType(
                keyType: key.name.lexeme,
                valueType: value.name.lexeme,
              ),
              _ => throw UnsupportedError('unsupported map type $type'),
            },
            final t? when t.isDartCoreList => switch (arguments) {
              [final NamedType element, ...] => ListFieldType(
                type: element.name.lexeme,
              ),
              _ => throw UnsupportedError('unsupported list type $type'),
            },
            _ => OrdinaryFieldType(type: type.name.lexeme),
          };

          return MessageField(
            isOptional: type.question != null,
            name: e.variables.first.name.lexeme,
            type: fieldType,
          );
        })
        .toList(),
  );
}
