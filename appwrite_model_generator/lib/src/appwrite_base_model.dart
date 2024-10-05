import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';

final _dartfmt = DartFormatter();

Future<void> generateAppwriteModel() async {
  final emitter = DartEmitter(allocator: Allocator(), orderDirectives: true);
  final output = getLibary();

  final formatted = _dartfmt.format('${output.accept(emitter)}');

  print(formatted);
}

Library getLibary() => Library((lib) => lib
  ..directives.add(Directive.import('package:flutter/foundation.dart'))
  ..body.add(getClass()));

Class getClass() => Class((b) => b
  ..annotations.add(refer('immutable', 'package:flutter/foundation.dart'))
  ..abstract = true
  ..name = 'AppwriteModel'
  ..types.add(refer('T'))
  ..fields.addAll(getFields())
  ..constructors.addAll(getConstructors())
  ..methods.addAll(getPermisionHelpers())
  ..methods.add(toJsonMethod())
  ..methods.add(copyWithMethod())
  ..methods.add(toStringMethod())
  ..methods.add(toAppwriteMethod()));

List<Field> getFields() => [
      Field((b) => b
        ..name = '\$id'
        ..type = refer('String')
        ..modifier = FieldModifier.final$),
      Field((b) => b
        ..name = '\$collectionId'
        ..type = refer('String')
        ..modifier = FieldModifier.final$),
      Field((b) => b
        ..name = '\$databaseId'
        ..type = refer('String')
        ..modifier = FieldModifier.final$),
      Field((b) => b
        ..name = '\$createdAt'
        ..type = refer('DateTime')
        ..modifier = FieldModifier.final$),
      Field((b) => b
        ..name = '\$updatedAt'
        ..type = refer('DateTime')
        ..modifier = FieldModifier.final$),
      Field((b) => b
        ..name = '\$permissions'
        ..type = refer('List<String>')
        ..modifier = FieldModifier.final$),
    ];

List<Method> getPermisionHelpers() => [
      Method((b) => b
        ..name = 'canRead'
        ..returns = refer('bool')
        ..lambda = true
        ..body = Code('\$permissions.any((e) => e.contains("read"));')),
      Method((b) => b
        ..name = 'canUpdate'
        ..returns = refer('bool')
        ..lambda = true
        ..body = Code('\$permissions.any((e) => e.contains("update"));')),
      Method((b) => b
        ..name = 'canDelete'
        ..returns = refer('bool')
        ..lambda = true
        ..body = Code('\$permissions.any((e) => e.contains("delete"));')),
      Method((b) => b
        ..name = 'canReadUpdate'
        ..returns = refer('bool')
        ..lambda = true
        ..body = Code('canRead && canUpdate;')),
    ];

List<Constructor> getConstructors() => [
      Constructor((b) => b
        ..name = 'AppwriteModel'
        ..requiredParameters.add(Parameter((b) => b
          ..name = '\$id'
          ..type = refer('String')
          ..toThis = true))
        ..requiredParameters.add(Parameter((b) => b
          ..name = '\$collectionId'
          ..type = refer('String')
          ..toThis = true))
        ..requiredParameters.add(Parameter((b) => b
          ..name = '\$databaseId'
          ..type = refer('String')
          ..toThis = true))
        ..requiredParameters.add(Parameter((b) => b
          ..name = '\$createdAt'
          ..type = refer('DateTime')
          ..toThis = true))
        ..requiredParameters.add(Parameter((b) => b
          ..name = '\$updatedAt'
          ..type = refer('DateTime')
          ..toThis = true))
        ..requiredParameters.add(Parameter((b) => b
          ..name = '\$permissions'
          ..type = refer('List<String>')
          ..toThis = true)))
    ];

Method toJsonMethod() => Method((b) => b
  ..name = 'toJson'
  ..returns = refer('Map<String, dynamic>'));

Method copyWithMethod() => Method((b) => b
  ..name = 'copyWith'
  ..returns = refer('T')
  ..requiredParameters.add(Parameter((b) => b
    ..name = '\$id'
    ..type = refer('String')))
  ..requiredParameters.add(Parameter((b) => b
    ..name = '\$collectionId'
    ..type = refer('String')))
  ..requiredParameters.add(Parameter((b) => b
    ..name = '\$databaseId'
    ..type = refer('String')))
  ..requiredParameters.add(Parameter((b) => b
    ..name = '\$createdAt'
    ..type = refer('DateTime')))
  ..requiredParameters.add(Parameter((b) => b
    ..name = '\$updatedAt'
    ..type = refer('DateTime')))
  ..requiredParameters.add(Parameter((b) => b
    ..name = '\$permissions'
    ..type = refer('List<String>'))));

Method toStringMethod() => Method((b) => b
  ..name = 'toString'
  ..returns = refer('String')
  ..lambda = true
  ..body = Code('toJson().toString();'));

Method toAppwriteMethod() => Method((b) => b
  ..name = 'toAppwrite'
  ..optionalParameters.add(Parameter((b) => b
    ..name = 'includeRelations'
    ..type = refer('bool')
    ..defaultTo = Code('false')))
  ..returns = refer('Map<String, dynamic>'));
