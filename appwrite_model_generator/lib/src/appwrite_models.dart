import 'dart:convert';
import 'dart:io';

import 'package:appwrite_model_generator/src/collection_parser.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_helper_utils/dart_helper_utils.dart';
import 'package:dart_style/dart_style.dart';

final _dartfmt = DartFormatter();

Future<void> generateAppwriteModels() async {
  final emitter = DartEmitter(allocator: Allocator(), orderDirectives: true);
  final output = getLibary();

  final formatted = _dartfmt.format('${output.accept(emitter)}');

  print(formatted);
}

Library getLibary() => Library((lib) {
  lib.directives.add(Directive.import('package:flutter/foundation.dart'));
  lib.directives.add(Directive.import(
    'package:appwrite_model/appwrite_model.dart',
  ));
  lib.directives.add(Directive.import(
    'package:dart_helper_utils/dart_helper_utils.dart',
  ));
  lib.directives.add(Directive.import('package:collection/collection.dart'));

  final inputFile = File('input.json');
  final input = inputFile.readAsStringSync();
  final jsonMap = json.decode(input);
  final collections = jsonMap['collections'] as List<dynamic>;
  final Map<String, String> collectionIdToName = collections.fold(
    <String, String>{},
    (
      map,
      collection,
    ) => map..[collection['\$id'] as String] = collection['name'] as String,
  );

  lib.body.addAll(collections.map((collection) =>
      ClassFactory(CollectionInfo.fromMap(
        collection,
        collectionIdToName,
      )).getClass()));
});

class ClassFactory {
  final CollectionInfo collectionInfo;
  late final String name = collectionInfo.name;
  late final String className = name.capitalizeFirstLetter;
  late final List<AttributeInfo> attributes = collectionInfo.attributes;

  ClassFactory(this.collectionInfo);

  Class getClass() => Class((b) =>
      b
        ..annotations
        .add(refer('immutable', 'package:flutter/foundation.dart'))
        ..name = className
        ..extend = refer('AppwriteModel<$className>')
        ..fields
        .addAll(getFields())
        ..constructors
        .add(getPrivateConstructor())
        ..constructors
        .add(getDefaultFactory())
        ..methods
        .add(toJsonMethod())
        ..methods
        .add(toAppwriteMethod())
        ..methods
        .add(copyWithMethod())
        ..methods
        .add(toStringMethod())
        ..methods
        .add(operatorEqualMethod())
        ..methods
        .add(hashCodeMethod())
        ..constructors
        .add(fromAppwriteFactory()));

  List<Field> getFields() {
    final fields = <Field>[];

    for (final attribute in attributes) {
      fields.addAll(attribute.getFields());
    }

    return fields;
  }

  Constructor getPrivateConstructor() => Constructor((b) =>
      b
        ..requiredParameters
        .addAll(attributes.map((e) => e.getConstructorParameter()))
        ..requiredParameters
        .add(Parameter((b) =>
            b
              ..name = '\$id'
              ..required = true
              ..toSuper = true))
        ..requiredParameters
        .add(Parameter((b) =>
            b
              ..name = '\$collectionId'
              ..required = true
              ..toSuper = true))
        ..requiredParameters
        .add(Parameter((b) =>
            b
              ..name = '\$databaseId'
              ..required = true
              ..toSuper = true))
        ..requiredParameters
        .add(Parameter((b) =>
            b
              ..name = '\$createdAt'
              ..required = true
              ..toSuper = true))
        ..requiredParameters
        .add(Parameter((b) =>
            b
              ..name = '\$updatedAt'
              ..required = true
              ..toSuper = true))
        ..requiredParameters
        .add(Parameter((b) =>
            b
              ..name = '\$permissions'
              ..required = true
              ..toSuper = true))
        ..initializers
        .addAll(attributes.expand((e) => e.getConstructorAsserts())));

  Constructor getDefaultFactory() => Constructor((b) =>
      b
        ..factory = true
        ..requiredParameters
        .addAll(attributes.map((e) => e.getDefaultFactoryParameter())));

  Method toJsonMethod() => Method((b) =>
      b
        ..name = 'toJson'
        ..returns = refer('Map<String, dynamic>')
        ..annotations
        .add(refer('override'))
        ..body = Code('''return {
      ${attributes.map((e) => e.getToJsonField()).join(',\n')}
    };'''));

  Method toAppwriteMethod() => Method((b) =>
      b
        ..name = 'toAppwrite'
        ..annotations
        .add(refer('override'))
        ..returns = refer('Map<String, dynamic>')
        ..requiredParameters
        .add(Parameter((b) =>
            b
              ..name = 'relationLevels'
              ..type = refer('List<bool>')
              ..defaultTo = Code('[]')))
        ..body = Code('''return
      {${attributes
            .map((e) {
              if (e is AttributeInfoRelationship) {
                return "if (relationLevels.isNotEmpty) '${e.name}': ${e
                    .name}?.toAppwrite(relationLevels: relationLevels..removeAt(0)),";
              }
              return "'${e.name}': ${e.name},";
            })
            .join(',\n')}
      if (relationLevels.isNotEmpty && relationLevels.first == true) '\$id': \$id,
    };'''));

  Method copyWithMethod() => Method((b) =>
      b
        ..name = 'copyWith'
        ..annotations
        .add(refer('override'))
        ..returns = refer(className)
        ..requiredParameters
        .addAll(attributes.map((e) => e.getCopyWithParameter()))
        ..body = Code('''
        return $className._(
          ${attributes.map((e) => e.getCopyWithField()).join(',\n')}
          \$id: \$id,
          \$collectionId: \$collectionId,
          \$databaseId: \$databaseId,
          \$createdAt: \$createdAt,
          \$updatedAt: \$updatedAt,
          \$permissions: \$permissions,
        );
      '''));

  Method toStringMethod() => Method((b) =>
      b
        ..name = 'toString'
        ..annotations
        .add(refer('override'))
        ..returns = refer('String')
        ..lambda = true
        ..body = Code('toJson().toString();'));

  Method operatorEqualMethod() => Method((b) =>
      b
        ..name = '=='
        ..annotations
        .add(refer('override'))
        ..returns = refer('bool')
        ..requiredParameters
        .add(Parameter((b) =>
            b
              ..name = 'other'
              ..type = refer('Object')))
        ..body = Code('''
        final eq = const ListEquality().equals;
        return other is $className &&
          other.\$id == \$id &&
          ${attributes.map((e) => e.getEqualCheck()).join(' &&\n')};
      '''));

  Method hashCodeMethod() => Method((b) =>
      b
        ..name = 'hashCode'
        ..annotations
        .add(refer('override'))
        ..returns = refer('int')
        ..body = Code('''
        final hash = const ListEquality().hash;
        return hash([
          \$id,
          ${attributes.map((e) => e.array ? '...(${e.name} ??)' : e.name).join(
          ',\n',
        )}
        ]);
      '''));

  Constructor fromAppwriteFactory() => Constructor((b) =>
      b
        ..factory = true
        ..requiredParameters
        .add(Parameter((b) =>
            b
              ..name = 'doc'
              ..type = refer('Document')))
        ..body = Code('''
            return $className._(
              ${attributes.map((e) => e.getFromAppwriteField()).join(',\n')}
              \$id: doc.id,
              \$collectionId: doc.collection,
              \$databaseId: doc.database,
              \$createdAt: doc.createdAt,
              \$updatedAt: doc.updatedAt,
              \$permissions: doc.permissions,
            );
          '''));
}
