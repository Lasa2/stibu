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
      ..type = required ? reference : reference.nullable
      ..modifier = FieldModifier.final$));

    if (this is AttributeInfoRelation) {
      final info = this as AttributeInfoRelation;

      fields.add(Field((b) => b
        ..name = '${name}Relation'
        ..type = refer('Relation')
        ..assignment = Code('''const Relation(
          required: $required,
          array: $array,
          relatedCollection: '$name',
          relationType: ${info.relationType},
          twoWay: ${info.twoWay},
          twoWayKey: '${info.twoWayKey}',
          onDelete: ${info.onDelete},
          side: ${info.side},
        )''')
        ..static = true
        ..modifier = FieldModifier.constant));
    }

    return fields;
  }

  Parameter getConstructorParameter() => Parameter((b) => b
    ..name = name
    ..named = true
    ..toThis = true
    ..required = required);

  Parameter getDefaultFactoryParameter() => Parameter((b) => b
    ..name = name
    ..named = true
    ..type = required ? reference : reference.nullable
    ..required = required
    ..defaultTo = required && raw.defaultValue != null ? defaultTo : null);

  Code getToJsonField() => Code("'$name': $name");

  List<Code> getConstructorAsserts() => <Code>[];

  Parameter getCopyWithParameter() => Parameter((b) => b
    ..name = name
    ..named = true
    ..type = refer('${reference.symbol}${required ? '' : '?'} Function()?'));

  Code getCopyWithField() => Code('$name: $name?.call() ?? this.$name');

  Code getEqualCheck() =>
      array ? Code('_eq($name, other.$name)') : Code('$name == other.$name');

  Code getFromAppwriteField() => array
      ? Code('$name: List<$type>.unmodifiable(doc.data[\'$name\'] ?? [])')
      : Code('$name: doc.data[\'$name\']');

  Code getDefaultFactoryField() => Code('$name: $name');
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
        asserts.add(Code(
            'assert($name.every((e) => e.isNotBlank), \'$name is blank\')'));
        asserts.add(Code(
            'assert($name.every((e) => e.length <= $size), \'$name is greater than $size\')'));
      } else {
        asserts.add(Code('assert($name.isNotBlank, \'$name is blank\')'));
        asserts.add(Code(
            'assert($name.length <= $size, \'$name is greater than $size\')'));
      }
    } else {
      if (array) {
        asserts.add(Code(
          'assert($name == null || $name.every((e) => e.isNotBlank), \'$name is blank\')',
        ));
        asserts.add(Code(
          'assert($name == null || $name.every((e) => e.length <= $size), \'$name is greater than $size\')',
        ));
      } else {
        asserts.add(Code(
            'assert($name == null || $name.isNotBlank, \'$name is blank\')'));
        asserts.add(Code(
            'assert($name == null || $name.length <= $size, \'$name is greater than $size\')'));
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
        asserts.add(Code(
            'assert($name.every((e) => e >= $min), \'$name is less than $min\')'));
        asserts.add(Code(
            'assert($name.every((e) => e <= $max), \'$name is greater than $max\')'));
      } else {
        asserts.add(Code('assert($name >= $min, \'$name is less than $min\')'));
        asserts
            .add(Code('assert($name <= $max, \'$name is greater than $max\')'));
      }
    } else {
      if (array) {
        asserts.add(Code(
          'assert($name == null || $name.every((e) => e >= $min), \'$name is less than $min\')',
        ));
        asserts.add(Code(
          'assert($name == null || $name.every((e) => e <= $max), \'$name is greater than $max\')',
        ));
      } else {
        asserts.add(Code(
            'assert($name == null || $name >= $min, \'$name is less than $min\')'));
        asserts.add(Code(
            'assert($name == null || $name <= $max, \'$name is greater than $max\')'));
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
        asserts.add(Code(
            'assert($name.every((e) => e >= $min), \'$name is less than $min\')'));
        asserts.add(Code(
            'assert($name.every((e) => e <= $max), \'$name is greater than $max\')'));
      } else {
        asserts.add(Code('assert($name >= $min, \'$name is less than $min\')'));
        asserts
            .add(Code('assert($name <= $max, \'$name is greater than $max\')'));
      }
    } else {
      if (array) {
        asserts.add(Code(
          'assert($name == null || $name.every((e) => e >= $min), \'$name is less than $min\')',
        ));
        asserts.add(Code(
          'assert($name == null || $name.every((e) => e <= $max), \'$name is greater than $max\')',
        ));
      } else {
        asserts.add(Code(
            'assert($name == null || $name >= $min, \'$name is less than $min\')'));
        asserts.add(Code(
            'assert($name == null || $name <= $max, \'$name is greater than $max\')'));
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
        asserts.add(Code(
            'assert($name.every((e) => e.isValidEmail), \'$name is not a valid email\')'));
      } else {
        asserts.add(
            Code('assert($name.isValidEmail, \'$name is not a valid email\')'));
      }
    } else {
      if (array) {
        asserts.add(Code(
          'assert($name == null || $name.every((e) => e.isValidEmail), \'$name is not a valid email\')',
        ));
      } else {
        asserts.add(Code(
            'assert($name == null || $name.isValidEmail, \'$name is not a valid email\')'));
      }
    }

    return asserts;
  }
}

class Relationship {}

enum RelationType { oneToOne, manyToOne, oneToMany, manyToMany }

enum RelationOnDelete { setNull, cascade, restrict }

enum RelationSide { parent, child }

class AttributeInfoRelation extends AttributeInfo {
  final RelationType relationType;
  final RelationOnDelete onDelete;
  final RelationSide side;
  final String relatedCollection;
  final bool twoWay;
  final String? twoWayKey;
  final Reference relatedClassReference;
  final Reference _reference;

  AttributeInfoRelation({
    required super.raw,
    required this.relationType,
    required this.onDelete,
    required this.side,
    required this.relatedCollection,
    required this.twoWay,
    required this.twoWayKey,
    required this.relatedClassReference,
  }) : _reference = resolveRelationshipType(
          relationType,
          side,
          relatedClassReference,
        );

  @override
  Type get type => Relationship;
  @override
  Reference get typeReference => _reference;
  @override
  Code getToJsonField() {
    if (isTypeSingle(relationType, side)) {
      return Code("'$name': $name?.toJson()");
    } else {
      return Code("'$name': $name?.map((e) => e.toJson()).toList()");
    }
  }

  static bool isTypeSingle(RelationType type, RelationSide side) {
    return type == RelationType.oneToOne ||
        type == RelationType.oneToMany && side == RelationSide.child ||
        type == RelationType.manyToOne && side == RelationSide.parent;
  }

  static Reference resolveRelationshipType(
    RelationType type,
    RelationSide side,
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
    if (isTypeSingle(relationType, side)) {
      return required
          ? Code(
              '$name: ${relatedClassReference.symbol}.fromAppwrite(Document.fromMap(doc.data[\'$name\']))',
            )
          : Code('''
          $name: doc.data['$name'] != null
              ? ${relatedClassReference.symbol}.fromAppwrite(Document.fromMap(doc.data['$name']))
              : null
        ''');
    } else {
      return Code(
        '$name: List<${relatedClassReference.symbol}>.unmodifiable(doc.data[\'$name\']?.map((e) => ${relatedClassReference.symbol}.fromAppwrite(Document.fromMap(e))) ?? [])',
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
        asserts.add(
            Code('assert($name.every((e) => e.isUtc), \'$name is not UTC\')'));
      } else {
        asserts.add(Code('assert($name.isUtc, \'$name is not UTC\')'));
      }
    } else {
      if (array) {
        asserts.add(Code(
          'assert($name == null || $name.every((e) => e.isUtc), \'$name is not UTC\')',
        ));
      } else {
        asserts.add(
            Code('assert($name == null || $name.isUtc, \'$name is not UTC\')'));
      }
    }
    return asserts;
  }

  @override
  Code getFromAppwriteField() => array
      ? Code(
          '$name: List<$type>.unmodifiable(doc.data[\'$name\']?.map((e) => $type.parse(e)) ?? [])',
        )
      : required
          ? Code('''
          $name: $type.parse(doc.data['$name'])
        ''')
          : Code('''
          $name: doc.data['$name'] != null
              ? $type.parse(doc.data['$name'])
              : null
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
          '${classReference.symbol}${raw.key.capitalizeFirstLetter}',
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
          '$name: List<$type>.unmodifiable(doc.data[\'$name\']?.map((e) => ${typeReference.symbol}.values.byName(e)) ?? [])',
        )
      : required
          ? Code(
              '$name: ${typeReference.symbol}.values.byName(doc.data[\'$name\'])',
            )
          : Code(
              '$name: doc.data[\'$name\'] != null ? ${typeReference.symbol}.values.byName(doc.data[\'$name\']) : null',
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
      values: (attribute['elements'] as List<dynamic>).cast<String>(),
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
      return AttributeInfoRelation(
        raw: AttributeInfoRaw(
          key: key,
          required: required,
          array: array,
          defaultValue: defaultValue,
        ),
        relationType: RelationType.values.byName(
          attribute['relationType'] as String,
        ),
        onDelete: RelationOnDelete.values.byName(
          attribute['onDelete'] as String,
        ),
        side: RelationSide.values.byName(attribute['side'] as String),
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
