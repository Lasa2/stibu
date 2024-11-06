import 'package:code_builder/code_builder.dart';



Class getClass() => Class((b) => b
  ..name = 'CollectionInfo'
  ..annotations.add(refer('immutable'))
  ..fields.addAll(getFields())
  ..constructors.addAll(getConstructors()));

List<Field> getFields() => [
      Field((b) => b
        ..name = '\$id'
        ..type = refer('String')
        ..modifier = FieldModifier.final$),
      Field((b) => b
        ..name = '\$permissions'
        ..type = refer('List<String>')
        ..modifier = FieldModifier.final$),
      Field((b) => b
        ..name = 'databaseId'
        ..type = refer('String')
        ..modifier = FieldModifier.final$),
      Field((b) => b
        ..name = 'name'
        ..type = refer('String')
        ..modifier = FieldModifier.final$),
      Field((b) => b
        ..name = 'enabled'
        ..type = refer('bool')
        ..modifier = FieldModifier.final$),
      Field((b) => b
        ..name = 'documentSecurity'
        ..type = refer('bool')
        ..modifier = FieldModifier.final$),
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
            ..name = '\$permissions'
            ..named = true
            ..required = true
            ..toThis = true),
          Parameter((b) => b
            ..name = 'databaseId'
            ..named = true
            ..required = true
            ..toThis = true),
          Parameter((b) => b
            ..name = 'name'
            ..named = true
            ..required = true
            ..toThis = true),
          Parameter((b) => b
            ..name = 'enabled'
            ..named = true
            ..required = true
            ..toThis = true),
          Parameter((b) => b
            ..name = 'documentSecurity'
            ..named = true
            ..required = true
            ..toThis = true)
        ])),

    ];
