import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';

final _dartfmt = DartFormatter();

Future<void> generateRelationship() async {
  final emitter = DartEmitter(allocator: Allocator(), orderDirectives: true);
  final output = getLibary();

  final formatted = _dartfmt.format('${output.accept(emitter)}');

  print(formatted);
}

Library getLibary() => Library((lib) =>
    lib
      ..body
      .add(getRelationshipType())
      ..body
      .add(getRelationshipOnDelete())
      ..body
      .add(getRelationshipSide())
      ..body
      .add(getClass()));

Class getClass() => Class((b) =>
    b
      ..name = 'Relationship'
      ..fields
      .addAll(getFields())
      ..constructors
      .addAll(getConstructors()));

List<Field> getFields() => [
  Field((b) =>
      b
        ..name = 'required'
        ..type = refer('bool')
        ..modifier = FieldModifier.final$),
  Field((b) =>
      b
        ..name = 'array'
        ..type = refer('bool')
        ..modifier = FieldModifier.final$),
  Field((b) =>
      b
        ..name = 'relatedCollection'
        ..type = refer('String')
        ..modifier = FieldModifier.final$),
  Field((b) =>
      b
        ..name = 'relationshipType'
        ..type = refer('RelationshipType')
        ..modifier = FieldModifier.final$),
  Field((b) =>
      b
        ..name = 'twoWay'
        ..type = refer('bool')
        ..modifier = FieldModifier.final$),
  Field((b) =>
      b
        ..name = 'twoWayKey'
        ..type = refer('String?')
        ..modifier = FieldModifier.final$),
  Field((b) =>
      b
        ..name = 'onDelete'
        ..type = refer('RelationshipOnDelete')
        ..modifier = FieldModifier.final$),
  Field((b) =>
      b
        ..name = 'side'
        ..type = refer('RelationshipSide')
        ..modifier = FieldModifier.final$),
];

List<Constructor> getConstructors() => [Constructor((b) =>
    b
      ..optionalParameters
      .add(Parameter((b) =>
          b
            ..name = 'required'
            ..toThis = true
            ..defaultTo = Code('false')))
      ..optionalParameters
      .add(Parameter((b) =>
          b
            ..name = 'array'
            ..toThis = true
            ..defaultTo = Code('false')))
      ..requiredParameters
      .add(Parameter((b) =>
          b
            ..name = 'relatedCollection'
            ..toThis = true))
      ..requiredParameters
      .add(Parameter((b) =>
          b
            ..name = 'relationshipType'
            ..toThis = true))
      ..optionalParameters
      .add(Parameter((b) =>
          b
            ..name = 'twoWay'
            ..toThis = true
            ..defaultTo = Code('false')))
      ..optionalParameters
      .add(Parameter((b) =>
          b
            ..name = 'twoWayKey'
            ..toThis = true))
      ..requiredParameters
      .add(Parameter((b) =>
          b
            ..name = 'onDelete'
            ..toThis = true))
      ..requiredParameters
      .add(Parameter((b) =>
          b
            ..name = 'side'
            ..toThis = true)))];

Enum getRelationshipType() => Enum((b) =>
    b
      ..name = 'RelationshipType'
      ..values
      .addAll([
        EnumValue((b) => b..name = 'oneToOne'),
        EnumValue((b) => b..name = 'oneToMany'),
        EnumValue((b) => b..name = 'manyToOne'),
        EnumValue((b) => b..name = 'manyToMany'),
      ]));

Enum getRelationshipOnDelete() => Enum((b) =>
    b
      ..name = 'RelationshipOnDelete'
      ..values
      .addAll([
        EnumValue((b) => b..name = 'setNull'),
        EnumValue((b) => b..name = 'cascade'),
        EnumValue((b) => b..name = 'restrict'),
      ]));

Enum getRelationshipSide() => Enum((b) =>
    b
      ..name = 'RelationshipSide'
      ..values
      .addAll([
        EnumValue((b) => b..name = 'parent'),
        EnumValue((b) => b..name = 'child'),
      ]));
