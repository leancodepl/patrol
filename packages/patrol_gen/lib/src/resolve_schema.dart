import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:path/path.dart' as path;
import 'package:patrol_gen/src/schema.dart';

Future<Schema> resolveSchema(String schemaPath) async {
  final file = path.normalize(path.absolute(schemaPath));
  final result = await resolveFile2(path: file);

  final enums = <Enum>[];
  final messages = <Message>[];
  final classServices = <ClassDeclaration>[];

  if (result is ResolvedUnitResult) {
    for (final declaration in result.unit.declarations) {
      if (declaration is EnumDeclaration) {
        enums.add(
          Enum(
            declaration.name.lexeme,
            declaration.constants.map((e) => e.name.lexeme).toList(),
          ),
        );
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
  final genericTypes = declaration.typeParameters?.typeParameters
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
    declaration.name.lexeme,
    iosGenConfig,
    dartGenConfig,
    androidGenConfig,
    declaration.members.whereType<MethodDeclaration>().map((method) {
      final returnType = method.returnType;
      if (returnType is NamedType) {
        final responseMessage = returnType.name2.lexeme == 'void'
            ? null
            : messages.firstWhere((msg) => msg.name == returnType.name2.lexeme);

        Message? requestMessage;
        if (method.parameters!.parameters.isNotEmpty) {
          final parameter = method.parameters!.parameters.first;
          if (parameter is SimpleFormalParameter) {
            final parameterTypeName =
                (parameter.type! as NamedType).name2.lexeme;

            requestMessage =
                messages.firstWhere((msg) => msg.name == parameterTypeName);
          } else {
            throw UnsupportedError('unsupported parameter $parameter');
          }
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
    declaration.name.lexeme,
    declaration.members
        .whereType<FieldDeclaration>()
        .map((e) => e.fields)
        .whereType<VariableDeclarationList>()
        .map((e) {
      final type = e.type;
      if (type is NamedType) {
        final isOptional = type.question != null;
        final fieldName = e.variables.first.name.lexeme;

        if (type.type?.isDartCoreMap ?? false) {
          final arguments = type.typeArguments!.arguments;
          return MessageField(
            isOptional: isOptional,
            name: fieldName,
            type: MapFieldType(
              keyType: (arguments[0] as NamedType).name2.lexeme,
              valueType: (arguments[1] as NamedType).name2.lexeme,
            ),
          );
        } else if (type.type?.isDartCoreList ?? false) {
          final genericType = type.typeArguments!.arguments.first as NamedType;
          return MessageField(
            isOptional: isOptional,
            name: fieldName,
            type: ListFieldType(type: genericType.name2.lexeme),
          );
        } else {
          return MessageField(
            isOptional: isOptional,
            name: fieldName,
            type: OrdinaryFieldType(type: type.name2.lexeme),
          );
        }
      } else {
        throw UnsupportedError('unsupported type $type');
      }
    }).toList(),
  );
}
