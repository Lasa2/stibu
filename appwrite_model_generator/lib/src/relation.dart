import 'package:code_builder/code_builder.dart';

Class getClass() => Class((b) => b
  ..name = 'Relation'
  ..annotations.add(refer('immutable'))
  ..fields.addAll(getFields())
  ..constructors.addAll(getConstructors()));

List<Field> getFields() => [
      Field((b) => b
        ..name = 'required'
        ..type = refer('bool')
        ..modifier = FieldModifier.final$),
      Field((b) => b
        ..name = 'array'
        ..type = refer('bool')
        ..modifier = FieldModifier.final$),
      Field((b) => b
        ..name = 'relatedCollection'
        ..type = refer('String')
        ..modifier = FieldModifier.final$),
      Field((b) => b
        ..name = 'relationType'
        ..type = refer('RelationType')
        ..modifier = FieldModifier.final$),
      Field((b) => b
        ..name = 'twoWay'
        ..type = refer('bool')
        ..modifier = FieldModifier.final$),
      Field((b) => b
        ..name = 'twoWayKey'
        ..type = refer('String?')
        ..modifier = FieldModifier.final$),
      Field((b) => b
        ..name = 'onDelete'
        ..type = refer('RelationOnDelete')
        ..modifier = FieldModifier.final$),
      Field((b) => b
        ..name = 'side'
        ..type = refer('RelationSide')
        ..modifier = FieldModifier.final$),
    ];

List<Constructor> getConstructors() => [
      Constructor((b) => b
        ..constant = true
        ..optionalParameters.addAll([
          Parameter((b) => b
            ..name = 'required'
            ..named = true
            ..toThis = true
            ..defaultTo = Code('false')),
          Parameter((b) => b
            ..name = 'array'
            ..named = true
            ..toThis = true
            ..defaultTo = Code('false')),
          Parameter((b) => b
            ..name = 'relatedCollection'
            ..named = true
            ..toThis = true
            ..required = true),
          Parameter((b) => b
            ..name = 'relationType'
            ..named = true
            ..toThis = true
            ..required = true),
          Parameter((b) => b
            ..name = 'twoWay'
            ..named = true
            ..toThis = true
            ..defaultTo = Code('false')),
          Parameter((b) => b
            ..name = 'twoWayKey'
            ..named = true
            ..toThis = true
            ..required = true),
          Parameter((b) => b
            ..name = 'onDelete'
            ..named = true
            ..toThis = true
            ..required = true),
          Parameter((b) => b
            ..name = 'side'
            ..named = true
            ..toThis = true
            ..required = true),
        ]))
    ];

Enum getRelationType() => Enum((b) => b
  ..name = 'RelationType'
  ..values.addAll([
    EnumValue((b) => b..name = 'oneToOne'),
    EnumValue((b) => b..name = 'oneToMany'),
    EnumValue((b) => b..name = 'manyToOne'),
    EnumValue((b) => b..name = 'manyToMany'),
  ]));

Enum getRelationOnDelete() => Enum((b) => b
  ..name = 'RelationOnDelete'
  ..values.addAll([
    EnumValue((b) => b..name = 'setNull'),
    EnumValue((b) => b..name = 'cascade'),
    EnumValue((b) => b..name = 'restrict'),
  ]));

Enum getRelationSide() => Enum((b) => b
  ..name = 'RelationSide'
  ..values.addAll([
    EnumValue((b) => b..name = 'parent'),
    EnumValue((b) => b..name = 'child'),
  ]));
