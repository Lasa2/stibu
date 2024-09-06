import 'package:stibu/model_generator/model.dart';

class AttributeInfo {
  final String name;
  final Type type;
  final bool required;
  final bool array;
  final dynamic defaultValue;

  AttributeInfo({
    required this.name,
    this.type = dynamic,
    required this.required,
    required this.array,
    required this.defaultValue,
  });
}

class AttributeInfoString extends AttributeInfo {
  @override
  Type get type => String;
  final int size;

  AttributeInfoString({
    required super.name,
    required super.required,
    required super.array,
    required super.defaultValue,
    required this.size,
  });
}

class AttributeInfoInteger extends AttributeInfo {
  @override
  Type get type => int;
  final int min;
  final int max;

  AttributeInfoInteger({
    required super.name,
    required super.required,
    required super.array,
    required super.defaultValue,
    required this.min,
    required this.max,
  });
}

class AttributeInfoEmail extends AttributeInfo {
  String get email => "email";
  @override
  Type get type => String;

  AttributeInfoEmail({
    required super.name,
    required super.required,
    required super.array,
    required super.defaultValue,
  });
}

class Relationship {}

enum RelationshipType { oneToOne, manyToOne, oneToMany, manyToMany }

enum OnDelete { setNull, cascade, restrict }

enum Side { parent, child }

class AttributeInfoRelationship extends AttributeInfo {
  @override
  Type get type => Relationship;
  final String relatedCollection;
  final RelationshipType relationType;
  final bool twoWay;
  final String twoWayKey;
  final OnDelete onDelete;
  final Side side;

  AttributeInfoRelationship({
    required super.name,
    required super.required,
    required super.array,
    required super.defaultValue,
    required this.relatedCollection,
    required this.relationType,
    required this.twoWay,
    required this.twoWayKey,
    required this.onDelete,
    required this.side,
  });
}

class AttributeInfoBoolean extends AttributeInfo {
  @override
  Type get type => bool;

  AttributeInfoBoolean({
    required super.name,
    required super.required,
    required super.array,
    required super.defaultValue,
  });
}

class AttributeInfoDateTime extends AttributeInfo {
  @override
  Type get type => DateTime;

  AttributeInfoDateTime({
    required super.name,
    required super.required,
    required super.array,
    required super.defaultValue,
  });
}

class AttributeInfoEnum extends AttributeInfo {
  // Marked with format = enum

  final List<String> elements;
  @override
  Type get type => Enum;

  AttributeInfoEnum({
    required super.name,
    required super.required,
    required super.array,
    required super.defaultValue,
    required this.elements,
  });
}

AttributeInfo resolveAttributeInfo(Map<String, dynamic> attribute) {
  final name = attribute['key'] as String;
  final required = attribute['required'] as bool;
  final array = attribute['array'] as bool;
  final defaultValue = attribute['default'] as dynamic;
  final format =
      attribute.containsKey('format') ? attribute['format'] as String : null;

  if (format == 'enum') {
    return AttributeInfoEnum(
        name: name,
        required: required,
        array: array,
        defaultValue: defaultValue,
        elements: List.from(attribute['elements'] as List<dynamic>));
  }
  if (format == 'email') {
    return AttributeInfoEmail(
      name: name,
      required: required,
      array: array,
      defaultValue: defaultValue,
    );
  }
  switch (attribute['type'] as String) {
    case 'string':
      return AttributeInfoString(
        name: name,
        required: required,
        array: array,
        defaultValue: defaultValue,
        size: attribute['size'] as int,
      );
    case 'integer':
      return AttributeInfoInteger(
        name: name,
        required: required,
        array: array,
        defaultValue: defaultValue,
        min: attribute['min'] as int,
        max: attribute['max'] as int,
      );
    case 'boolean':
      return AttributeInfoBoolean(
        name: name,
        required: required,
        array: array,
        defaultValue: defaultValue,
      );
    case 'datetime':
      return AttributeInfoDateTime(
        name: name,
        required: required,
        array: array,
        defaultValue: defaultValue,
      );
    case 'relationship':
      return AttributeInfoRelationship(
        name: name,
        required: required,
        array: array,
        defaultValue: defaultValue,
        relatedCollection: attribute['relatedCollection'] as String,
        relationType: RelationshipType.values.byName(attribute['relationType']),
        twoWay: attribute['twoWay'] as bool,
        twoWayKey: attribute['twoWayKey'],
        onDelete: OnDelete.values.byName(attribute['onDelete']),
        side: Side.values.byName(attribute['side']),
      );
    default:
      return AttributeInfo(
        name: name,
        required: required,
        array: array,
        defaultValue: defaultValue,
      );
  }
}

String resolveRelationshipType(AttributeInfoRelationship attribute) {
  final relatedClass = capitalize(attribute.relatedCollection);

  switch (attribute.relationType) {
    case RelationshipType.oneToOne:
      return relatedClass;
    case RelationshipType.oneToMany:
      if (attribute.side == Side.parent) {
        return 'List<$relatedClass>';
      } else {
        return relatedClass;
      }
    case RelationshipType.manyToOne:
      if (attribute.side == Side.parent) {
        return relatedClass;
      } else {
        return 'List<$relatedClass>';
      }
    case RelationshipType.manyToMany:
      return 'List<$relatedClass>';
  }
}

String generateField(AttributeInfo attribute) {
  final type = attribute.type.toString();
  final name = attribute.name;

  if (attribute is AttributeInfoRelationship) {
    return generateRelationshipField(attribute);
  }

  String field = 'final';
  if (attribute.type == Enum) {
    field += ' ${capitalize(name)}';
  } else if (attribute.array) {
    field += ' List<$type>';
  } else {
    field += ' $type';
  }

  if (!attribute.required) {
    field += '?';
  }

  return '$field $name;';
}

String generateRelationshipField(AttributeInfoRelationship attribute) {
  final type = attribute.type.toString();
  final name = attribute.name;

  String field = '''
final $type ${name}Relation = Relationship(
    required: ${attribute.required},
    array: ${attribute.array},
    relatedCollection: '${attribute.relatedCollection}',
    relationType: ${attribute.relationType},
    twoWay: ${attribute.twoWay},
    twoWayKey: '${attribute.twoWayKey}',
    onDelete: ${attribute.onDelete},
    side: ${attribute.side},
  );
  ''';

  field += 'final ${resolveRelationshipType(attribute)}';

  if (!attribute.required) {
    field += '?';
  }

  return '$field $name;';
}

String generateConstructorField(AttributeInfo attribute) {
  final name = attribute.name;

  String field = '';
  if (attribute.required && attribute.defaultValue == null) {
    field += 'required this.$name';
  } else {
    field += 'this.$name';
  }

  if (attribute.defaultValue != null && attribute.defaultValue != '') {
    field += ' = ${attribute.defaultValue}';
  }

  return field;
}

List<String> generateAsserts(AttributeInfo attribute) {
  final name = attribute.name;
  final asserts = <String>[];

  if (attribute is AttributeInfoString) {
    if (attribute.required) {
      if (!attribute.array) {
        asserts.add('assert($name.isNotEmpty)');
      }
      asserts.add('assert($name.length <= ${attribute.size})');
    } else {
      asserts.add(
          'assert($name == null || $name.isNotEmpty && $name.length <= ${attribute.size})');
    }
  } else if (attribute is AttributeInfoInteger) {
    if (attribute.required) {
      asserts.add('assert($name >= ${attribute.min})');
      asserts.add('assert($name <= ${attribute.max})');
    } else {
      asserts.add('assert($name == null || $name >= ${attribute.min})');
      asserts.add('assert($name == null || $name <= ${attribute.max})');
    }
  } else if (attribute is AttributeInfoDateTime) {
    if (attribute.required) {
      asserts.add('assert($name.isUtc)');
    } else {
      asserts.add('assert($name == null || $name.isUtc)');
    }
  }

  return asserts;
}

String generateNamedConstructorField(AttributeInfo attribute) {
  final type = attribute.type.toString();
  final name = attribute.name;

  String field = '';

  if (attribute.required && attribute.defaultValue == null) {
    field += 'required ';
  }

  if (attribute is AttributeInfoRelationship) {
    field += resolveRelationshipType(attribute);
  } else if (attribute.type == Enum) {
    field += capitalize(name);
  } else if (attribute.array) {
    field += 'List<$type>';
  } else {
    field += type;
  }

  if (!attribute.required) {
    field += '?';
  }

  if (attribute.defaultValue != null && attribute.defaultValue != '') {
    field += ' = ${attribute.defaultValue}';
  }

  return '$field $name';
}

String generateNamedConstructorFieldAssignment(AttributeInfo attribute) {
  final name = attribute.name;

  return '$name: $name';
}

String generateToJsonField(AttributeInfo attribute) {
  final name = attribute.name;

  switch (attribute.type.toString()) {
    case 'DateTime':
      return "'$name': ${attribute.array ? '$name.map((e) => e.toIso8601String()).toList()' : '$name.toIso8601String()'}";
    case 'Enum':
      return "'$name': ${attribute.array ? '$name.map((e) => e.name).toList()' : '$name.name'}";
    case 'Relationship':
      return generateRelationshipToJsonField(
          attribute as AttributeInfoRelationship);
    default:
      return "'$name': $name";
  }
}

String generateRelationshipToJsonField(AttributeInfoRelationship attribute) {
  final name = attribute.name;
  switch (attribute.relationType) {
    case RelationshipType.oneToOne:
      return "'$name': $name?.toJson()";
    case RelationshipType.oneToMany:
      if (attribute.side == Side.parent) {
        return "'$name': $name?.map((e) => e.toJson()).toList()";
      } else {
        return "'$name': $name?.toJson()";
      }
    case RelationshipType.manyToOne:
      if (attribute.side == Side.parent) {
        return "'$name': $name?.toJson()";
      } else {
        return "'$name': $name?.map((e) => e.toJson()).toList()";
      }
    case RelationshipType.manyToMany:
      return "'$name': $name?.map((e) => e.toJson()).toList()";
  }
}

String generateCopyWithField(AttributeInfo attribute) {
  final type = attribute.type.toString();
  final name = attribute.name;

  String field = '';

  if (attribute is AttributeInfoRelationship) {
    field += '${resolveRelationshipType(attribute)}?';
  } else if (attribute.type == Enum) {
    field += '${capitalize(name)}?';
  } else if (attribute.array) {
    field += 'List<$type>?';
  } else {
    field += '$type?';
  }

  if (attribute.defaultValue != null && attribute.defaultValue != '') {
    field += ' = $name';
  } else if (!attribute.required && attribute.type is String) {
    field += ' = \'\'';
  }

  return '$field $name';
}

String generateCopyWithFieldAssignment(AttributeInfo attribute) {
  final name = attribute.name;

  if (!attribute.required && attribute.type is String) {
    return '$name: $name == \'\' ? this.$name : $name';
  }

  return '$name: $name ?? this.$name';
}

String generateFromAppwriteField(AttributeInfo attribute) {
  final name = attribute.name;
  final type = attribute.type.toString();

  if (attribute is AttributeInfoRelationship) {
    return generateRelationshipFromAppwriteField(attribute);
  }

  final buildType = switch (type) {
    'Enum' => '${capitalize(name)}.values.byName(doc.data[\'$name\'])',
    'DateTime' => 'DateTime.parse(doc.data[\'$name\'])',
    _ => 'doc.data[\'$name\']',
  };

  if (attribute.array) {
    return '$name: List<$type>.unmodifiable(doc.data[\'$name\'].map((e) => $buildType))';
  }

  return '$name: $buildType';
}

String generateRelationshipFromAppwriteField(
    AttributeInfoRelationship attribute) {
  final name = attribute.name;
  final relatedClass = capitalize(attribute.relatedCollection);

  if (attribute.relationType == RelationshipType.oneToOne ||
      attribute.relationType == RelationshipType.oneToMany &&
          attribute.side == Side.child ||
      attribute.relationType == RelationshipType.manyToOne &&
          attribute.side == Side.parent) {
    return '$name: doc.data[\'$name\'] == null ? null : $relatedClass.fromAppwrite(Document.fromMap(doc.data[\'$name\']))';
  }

  if (attribute.relationType == RelationshipType.manyToMany ||
      attribute.relationType == RelationshipType.oneToMany &&
          attribute.side == Side.parent ||
      attribute.relationType == RelationshipType.manyToOne &&
          attribute.side == Side.child) {
    return '$name: List<$relatedClass>.unmodifiable(doc.data[\'$name\'] == null ? [] : doc.data[\'$name\'].map((e) => $relatedClass.fromAppwrite(Document.fromMap(e))))';
  }

  throw Exception('Invalid relationship type');
}

bool isListType(AttributeInfo attribute) {
  return attribute.array ||
      attribute is AttributeInfoRelationship &&
          (attribute.relationType == RelationshipType.manyToMany ||
              (attribute.relationType == RelationshipType.oneToMany &&
                  attribute.side == Side.parent) ||
              (attribute.relationType == RelationshipType.manyToOne &&
                  attribute.side == Side.child));
}

bool containsList(List<AttributeInfo> attributes) {
  return attributes.any(isListType);
}

String generateEqualsFields(AttributeInfo attribute) {
  final name = attribute.name;

  if (isListType(attribute)) {
    return 'eq($name, other.$name)';
  }

  return '$name == other.$name';
}

String generateHashCodeField(AttributeInfo attribute) {
  final name = attribute.name;

  if (isListType(attribute)) {
    if (!attribute.required || attribute is AttributeInfoRelationship) {
      return '...($name ?? [])';
    }
    return '...$name';
  }

  return name;
}
