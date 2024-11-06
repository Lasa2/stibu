import 'package:code_builder/code_builder.dart';

Class getClass() => Class((b) => b
  ..annotations.add(refer('immutable'))
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
        ..type = MethodType.getter
        ..returns = refer('bool')
        ..lambda = true
        ..body = Code('\$permissions.any((e) => e.contains(\'read\'))')),
      Method((b) => b
        ..name = 'canUpdate'
        ..type = MethodType.getter
        ..returns = refer('bool')
        ..lambda = true
        ..body = Code('\$permissions.any((e) => e.contains(\'update\'))')),
      Method((b) => b
        ..name = 'canDelete'
        ..type = MethodType.getter
        ..returns = refer('bool')
        ..lambda = true
        ..body = Code('\$permissions.any((e) => e.contains(\'delete\'))')),
      Method((b) => b
        ..name = 'canReadUpdate'
        ..type = MethodType.getter
        ..returns = refer('bool')
        ..lambda = true
        ..body = Code('canRead && canUpdate')),
    ];

List<Constructor> getConstructors() => [
      Constructor((b) => b
        ..constant = true
        ..optionalParameters.addAll([
          Parameter((b) => b
            ..name = '\$id'
            ..named = true
            ..required = true
            ..toThis = true),
          Parameter((b) => b
            ..name = '\$collectionId'
            ..named = true
            ..required = true
            ..toThis = true),
          Parameter((b) => b
            ..name = '\$databaseId'
            ..named = true
            ..required = true
            ..toThis = true),
          Parameter((b) => b
            ..name = '\$createdAt'
            ..named = true
            ..required = true
            ..toThis = true),
          Parameter((b) => b
            ..name = '\$updatedAt'
            ..named = true
            ..required = true
            ..toThis = true),
          Parameter((b) => b
            ..name = '\$permissions'
            ..named = true
            ..required = true
            ..toThis = true),
        ]))
    ];

Method toJsonMethod() => Method((b) => b
  ..name = 'toJson'
  ..returns = refer('Map<String, dynamic>'));

Method copyWithMethod() => Method((b) => b
  ..name = 'copyWith'
  ..returns = refer('T')
  ..optionalParameters.addAll([
    Parameter((b) => b
      ..name = '\$id'
      ..named = true
      ..type = refer('String?')),
    Parameter((b) => b
      ..name = '\$collectionId'
      ..named = true
      ..type = refer('String?')),
    Parameter((b) => b
      ..name = '\$databaseId'
      ..named = true
      ..type = refer('String?')),
    Parameter((b) => b
      ..name = '\$createdAt'
      ..named = true
      ..type = refer('DateTime?')),
    Parameter((b) => b
      ..name = '\$updatedAt'
      ..named = true
      ..type = refer('DateTime?')),
    Parameter((b) => b
      ..name = '\$permissions'
      ..named = true
      ..type = refer('List<String>?')),
  ]));

Method toStringMethod() => Method((b) => b
  ..name = 'toString'
  ..annotations.add(refer('override'))
  ..returns = refer('String')
  ..lambda = true
  ..body = Code('toJson().toString()'));

Method toAppwriteMethod() => Method((b) => b
  ..name = 'toAppwrite'
  ..optionalParameters.add(Parameter((b) => b
    ..name = 'relationLevels'
    ..named = true
    ..type = refer('List<bool>')
    ..defaultTo = Code('const []')))
  ..returns = refer('Map<String, dynamic>'));
