import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';

final _dartfmt = DartFormatter();

Future<void> generateCollectionInfo() async {
  final emitter = DartEmitter(allocator: Allocator(), orderDirectives: true);
  final output = getLibary();

  final formatted = _dartfmt.format('${output.accept(emitter)}');

  print(formatted);
}

Library getLibary() => Library((lib) => lib..body.add(getClass()));

Class getClass() => Class((b) =>
    b
      ..name = 'CollectionInfo'
      ..fields
      .addAll(getFields())
      ..constructors
      .addAll(getConstructors()));

List<Field> getFields() => [
  Field((b) =>
      b
        ..name = '\$id'
        ..type = refer('String')
        ..modifier = FieldModifier.final$),
  Field((b) =>
      b
        ..name = '\$permissions'
        ..type = refer('List<String>')
        ..modifier = FieldModifier.final$),
  Field((b) =>
      b
        ..name = 'databaseId'
        ..type = refer('String')
        ..modifier = FieldModifier.final$),
  Field((b) =>
      b
        ..name = 'name'
        ..type = refer('String')
        ..modifier = FieldModifier.final$),
  Field((b) =>
      b
        ..name = 'enabled'
        ..type = refer('bool')
        ..modifier = FieldModifier.final$),
  Field((b) =>
      b
        ..name = 'documentSecurity'
        ..type = refer('bool')
        ..modifier = FieldModifier.final$),
];

List<Constructor> getConstructors() => [Constructor((b) =>
    b
      ..requiredParameters
      .add(Parameter((b) =>
          b
            ..name = '\$id'
            ..toThis = true))
      ..requiredParameters
      .add(Parameter((b) =>
          b
            ..name = '\$permissions'
            ..toThis = true))
      ..requiredParameters
      .add(Parameter((b) =>
          b
            ..name = 'databaseId'
            ..toThis = true))
      ..requiredParameters
      .add(Parameter((b) =>
          b
            ..name = 'name'
            ..toThis = true))
      ..requiredParameters
      .add(Parameter((b) =>
          b
            ..name = 'enabled'
            ..toThis = true))
      ..requiredParameters
      .add(Parameter((b) =>
          b
            ..name = 'documentSecurity'
            ..toThis = true)))];
