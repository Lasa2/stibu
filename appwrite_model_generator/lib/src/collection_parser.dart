import 'package:code_builder/code_builder.dart';
import 'package:dart_helper_utils/dart_helper_utils.dart';

extension on Reference {
  Reference get nullable => refer('$symbol?', url);
}

class CollectionInfo {
  final String $id;
  final List<String> $permissions;
  final String databaseId;
  final String name;
  final bool enabled;
  final bool documentSecurity;
  final List<AttributeInfo> attributes;

  Reference get reference => refer(name.capitalizeFirstLetter);

  CollectionInfo({
    required this.$id,
    required this.$permissions,
    required this.databaseId,
    required this.name,
    required this.enabled,
    required this.documentSecurity,
    required this.attributes,
  });

  factory CollectionInfo.fromMap(
    Map<String, dynamic> map,
    Map<String, String> collectionIdToName,
  ) {
    return CollectionInfo(
      $id: map['\$id'],
      $permissions: List.unmodifiable(map['\$permissions']),
      databaseId: map['databaseId'],
      name: map['name'],
      enabled: map['enabled'],
      documentSecurity: map['documentSecurity'],
      attributes: (map['attributes'] as List<dynamic>)
          .map((e) => resolveAttributeInfo(
                e as Map<String, dynamic>,
                refer((map['name'] as String).capitalizeFirstLetter),
                collectionIdToName,
              ))
          .toList(),
    );
  }
}

class AttributeInfoRaw {
  final String key;
  final bool required;
  final bool array;
  final dynamic defaultValue;

  AttributeInfoRaw({
    required this.key,
    required this.required,
    required this.array,
    required this.defaultValue,
  });
}

class AttributeInfo {
  final AttributeInfoRaw raw;

  String get name => raw.key;
  bool get required => raw.required;
  bool get array => raw.array;
  Type get type => dynamic;
  Reference get typeReference => refer('dynamic');
  Code get defaultTo => Code(raw.defaultValue.toString());
  Reference get reference =>
      array ? refer('List<${typeReference.symbol}>') : typeReference;

  AttributeInfo({required this.raw});

  List<Field> getFields() {
    final fields = <Field>[];

    fields.add(Field((b) => b
      ..name = name
      ..type = required ? typeReference : typeReference.nullable
      ..modifier = FieldModifier.final$));

    if (this is AttributeInfoRelationship) {
      final info = this as AttributeInfoRelationship;

      fields.add(Field((b) => b
        ..name = '${name}Relationship'
        ..type = refer('Relationship')
        ..assignment = Code('''Relationship(
          required: $required,
          array: $array,
          relatedCollection: '$name',
          relationshipType: RelationshipType.${info.relationshipType},
          twoWay: ${info.twoWay},
          twoWayKey: ${info.twoWayKey},
          onDelete: RelationshipOnDelete.${info.onDelete},
          side: RelationshipSide.${info.side},
        )''')
        ..static = true
        ..modifier = FieldModifier.final$));
    }

    return fields;
  }

  Parameter getConstructorParameter() => Parameter((b) => b
    ..name = name
    ..toThis = true
    ..required = required);

  Parameter getDefaultFactoryParameter() => Parameter((b) => b
    ..name = name
    ..type = required ? typeReference : typeReference.nullable
    ..defaultTo = required ? defaultTo : null);

  Code getToJsonField() => Code("'$name': $name");

  List<Code> getConstructorAsserts() => <Code>[];

  Parameter getCopyWithParameter() => Parameter((b) => b
    ..name = name
    ..type = refer('${reference.symbol}? Function()?'));

  Code getCopyWithField() => Code('$name: $name?.call()');

  Code getEqualCheck() =>
      array ? Code('eq($name, other.$name)') : Code('$name == other.$name');

  Code getFromAppwriteField() => array
      ? Code('$name: List<$type>.unmodifiable(doc.data[\'$name\'] ?? [])')
      : Code('$name: doc.data[\'$name\']');
}

class AttributeInfoString extends AttributeInfo {
  final int size;

  AttributeInfoString({required super.raw, required this.size});

  @override
  Type get type => String;
  @override
  Reference get typeReference => refer('String');
  @override
  List<Code> getConstructorAsserts() {
    final asserts = <Code>[];

    if (required) {
      if (array) {
        asserts.add(Code('assert(all($name, (e) => e.isNotBlank));'));
        asserts.add(Code('assert(all($name, (e) => e.length <= $size));'));
      } else {
        asserts.add(Code('assert($name.isNotBlank);'));
        asserts.add(Code('assert($name.length <= $size);'));
      }
    } else {
      if (array) {
        asserts.add(Code(
          'assert($name == null || all($name, (e) => e.isNotBlank));',
        ));
        asserts.add(Code(
          'assert($name == null || all($name, (e) => e.length <= $size));',
        ));
      } else {
        asserts.add(Code('assert($name == null || $name.isNotBlank);'));
        asserts.add(Code('assert($name == null || $name.length <= $size);'));
      }
    }

    return asserts;
  }
}

class AttributeInfoInt extends AttributeInfo {
  final int min;
  final int max;

  AttributeInfoInt({required super.raw, required this.min, required this.max});

  @override
  Type get type => int;
  @override
  Reference get typeReference => refer('int');
  @override
  List<Code> getConstructorAsserts() {
    final asserts = <Code>[];

    if (required) {
      if (array) {
        asserts.add(Code('assert(all($name, (e) => e >= $min));'));
        asserts.add(Code('assert(all($name, (e) => e <= $max));'));
      } else {
        asserts.add(Code('assert($name >= $min);'));
        asserts.add(Code('assert($name <= $max);'));
      }
    } else {
      if (array) {
        asserts.add(Code(
          'assert($name == null || all($name, (e) => e >= $min));',
        ));
        asserts.add(Code(
          'assert($name == null || all($name, (e) => e <= $max));',
        ));
      } else {
        asserts.add(Code('assert($name == null || $name >= $min);'));
        asserts.add(Code('assert($name == null || $name <= $max);'));
      }
    }

    return asserts;
  }
}

class AttributeInfoDouble extends AttributeInfo {
  final double min;
  final double max;

  AttributeInfoDouble({
    required super.raw,
    required this.min,
    required this.max,
  });

  @override
  Type get type => double;
  @override
  Reference get typeReference => refer('double');
  @override
  List<Code> getConstructorAsserts() {
    final asserts = <Code>[];

    if (required) {
      if (array) {
        asserts.add(Code('assert(all($name, (e) => e >= $min));'));
        asserts.add(Code('assert(all($name, (e) => e <= $max));'));
      } else {
        asserts.add(Code('assert($name >= $min);'));
        asserts.add(Code('assert($name <= $max);'));
      }
    } else {
      if (array) {
        asserts.add(Code(
          'assert($name == null || all($name, (e) => e >= $min));',
        ));
        asserts.add(Code(
          'assert($name == null || all($name, (e) => e <= $max));',
        ));
      } else {
        asserts.add(Code('assert($name == null || $name >= $min);'));
        asserts.add(Code('assert($name == null || $name <= $max);'));
      }
    }

    return asserts;
  }
}

class AttributeInfoEmail extends AttributeInfo {
  String get format => 'email';

  AttributeInfoEmail({required super.raw});

  @override
  Type get type => String;
  @override
  Reference get typeReference => refer('String');
  @override
  List<Code> getConstructorAsserts() {
    final asserts = <Code>[];

    if (required) {
      if (array) {
        asserts.add(Code('assert(all($name, (e) => e.isValidEmail));'));
      } else {
        asserts.add(Code('assert($name.isValidEmail);'));
      }
    } else {
      if (array) {
        asserts.add(Code(
          'assert($name == null || all($name, (e) => e.isValidEmail));',
        ));
      } else {
        asserts.add(Code('assert($name == null || $name.isValidEmail);'));
      }
    }

    return asserts;
  }
}

class Relationship {}

enum RelationshipType { oneToOne, manyToOne, oneToMany, manyToMany }

enum RelationshipOnDelete { setNull, cascade, restrict }

enum RelationshipSide { parent, child }

class AttributeInfoRelationship extends AttributeInfo {
  final RelationshipType relationshipType;
  final RelationshipOnDelete onDelete;
  final RelationshipSide side;
  final String relatedCollection;
  final bool twoWay;
  final String? twoWayKey;
  final Reference relatedClassReference;
  final Reference _reference;

  AttributeInfoRelationship({
    required super.raw,
    required this.relationshipType,
    required this.onDelete,
    required this.side,
    required this.relatedCollection,
    required this.twoWay,
    required this.twoWayKey,
    required this.relatedClassReference,
  }) : _reference = resolveRelationshipType(
          relationshipType,
          side,
          relatedClassReference,
        );

  @override
  Type get type => Relationship;
  @override
  Reference get typeReference => _reference;
  @override
  Code getToJsonField() {
    if (isTypeSingle(relationshipType, side)) {
      return Code("'$name': $name?.toJson()");
    } else {
      return Code("'$name': $name?.map((e) => e.toJson()).toList()");
    }
  }

  static bool isTypeSingle(RelationshipType type, RelationshipSide side) {
    return type == RelationshipType.oneToOne ||
        type == RelationshipType.oneToMany && side == RelationshipSide.child ||
        type == RelationshipType.manyToOne && side == RelationshipSide.parent;
  }

  static Reference resolveRelationshipType(
    RelationshipType type,
    RelationshipSide side,
    Reference relatedCollection,
  ) {
    if (isTypeSingle(type, side)) {
      return relatedCollection;
    } else {
      return refer('List<${relatedCollection.symbol}>');
    }
  }

  @override
  Code getFromAppwriteField() {
    if (isTypeSingle(relationshipType, side)) {
      return Code('$name: doc.data[\'$name\']');
    } else {
      return Code(
        '$name: List<$type>.unmodifiable(doc.data[\'$name\']?.map((e) => $relatedClassReference.fromAppwrite(Document.fromMap(e)))) ?? [])',
      );
    }
  }
}

class AttributeInfoBool extends AttributeInfo {
  AttributeInfoBool({required super.raw});

  @override
  Type get type => bool;
  @override
  Reference get typeReference => refer('bool');
}

class AttributeInfoDateTime extends AttributeInfo {
  AttributeInfoDateTime({required super.raw});

  @override
  Type get type => DateTime;
  @override
  Reference get typeReference => refer('DateTime');
  @override
  Code getToJsonField() => array
      ? Code("'$name': $name.map((e) => e.toIso8601String()).toList()")
      : Code("'$name': $name.toIso8601String()");
  @override
  List<Code> getConstructorAsserts() {
    final asserts = <Code>[];

    if (required) {
      if (array) {
        asserts.add(Code('assert(all($name, (e) => e.isUtc));'));
      } else {
        asserts.add(Code('assert($name.isUtc);'));
      }
    } else {
      if (array) {
        asserts.add(Code(
          'assert($name == null || all($name, (e) => e.isUtc));',
        ));
      } else {
        asserts.add(Code('assert($name == null || $name.isUtc);'));
      }
    }
    return asserts;
  }

  @override
  Code getFromAppwriteField() => array
      ? Code(
          '$name: List<$type>.unmodifiable(doc.data[\'$name\']?.map((e) => DateTime.parse(e)) ?? [])',
        )
      : Code('''
          $name: doc.data['$name'] != null
              ? DateTime.parse(doc.data['$name'])
              : null,
        ''');
}

class AttributeInfoEnum extends AttributeInfo {
  final List<String> values;
  final Reference _reference;

  AttributeInfoEnum({
    required super.raw,
    required this.values,
    required Reference classReference,
  }) : _reference = refer(
          '${classReference.symbol}.${raw.key.capitalizeFirstLetter}',
        );

  @override
  Type get type => Enum;
  @override
  Reference get typeReference => _reference;
  @override
  Code getToJsonField() => array
      ? Code("'$name': $name.map((e) => e.name).toList()")
      : Code("'$name': $name.name");
  @override
  Code getFromAppwriteField() => array
      ? Code(
          '$name: List<$type>.unmodifiable(doc.data[\'$name\']?.map((e) => $typeReference.values.byName(e)) ?? [])',
        )
      : Code(
          '$name: $typeReference.values.byName(doc.data[\'$name\']) ?? $typeReference.values.first',
        );
}

AttributeInfo resolveAttributeInfo(
  Map<String, dynamic> attribute,
  Reference classReference,
  Map<String, String> collectionIdToName,
) {
  final key = attribute['key'] as String;
  final required = attribute['required'] as bool;
  final array = attribute['array'] as bool;
  final defaultValue = attribute['default'];
  final format = attribute['format'] as String?;

  if (format == 'email') {
    return AttributeInfoEmail(
        raw: AttributeInfoRaw(
      key: key,
      required: required,
      array: array,
      defaultValue: defaultValue,
    ));
  }

  if (format == 'enum') {
    return AttributeInfoEnum(
      raw: AttributeInfoRaw(
        key: key,
        required: required,
        array: array,
        defaultValue: defaultValue,
      ),
      values: (attribute['values'] as List<dynamic>).cast<String>(),
      classReference: classReference,
    );
  }

  switch (attribute['type'] as String) {
    case 'string':
      return AttributeInfoString(
          raw: AttributeInfoRaw(
            key: key,
            required: required,
            array: array,
            defaultValue: defaultValue,
          ),
          size: attribute['size'] as int);
    case 'integer':
      return AttributeInfoInt(
          raw: AttributeInfoRaw(
            key: key,
            required: required,
            array: array,
            defaultValue: defaultValue,
          ),
          min: attribute['min'] as int,
          max: attribute['max'] as int);
    case 'double':
      return AttributeInfoDouble(
          raw: AttributeInfoRaw(
            key: key,
            required: required,
            array: array,
            defaultValue: defaultValue,
          ),
          min: attribute['min'] as double,
          max: attribute['max'] as double);
    case 'boolean':
      return AttributeInfoBool(
          raw: AttributeInfoRaw(
        key: key,
        required: required,
        array: array,
        defaultValue: defaultValue,
      ));
    case 'datetime':
      return AttributeInfoDateTime(
          raw: AttributeInfoRaw(
        key: key,
        required: required,
        array: array,
        defaultValue: defaultValue,
      ));
    case 'relationship':
      return AttributeInfoRelationship(
        raw: AttributeInfoRaw(
          key: key,
          required: required,
          array: array,
          defaultValue: defaultValue,
        ),
        relationshipType: RelationshipType.values.byName(
          attribute['relationshipType'] as String,
        ),
        onDelete: RelationshipOnDelete.values.byName(
          attribute['onDelete'] as String,
        ),
        side: RelationshipSide.values.byName(attribute['side'] as String),
        relatedCollection: attribute['relatedCollection'] as String,
        twoWay: attribute['twoWay'] as bool,
        twoWayKey: attribute['twoWayKey'] as String?,
        relatedClassReference: refer(
          collectionIdToName[attribute['relatedCollection'] as String]!
              .capitalizeFirstLetter,
        ),
      );
    default:
      throw Exception('Unknown attribute type');
  }
}
