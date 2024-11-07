import 'package:appwrite_model_generator/src/collection_parser.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_helper_utils/dart_helper_utils.dart';

class ClassFactory {
  final CollectionInfo collectionInfo;
  late final String name = collectionInfo.name;
  late final String className = name.capitalizeFirstLetter;
  late final List<AttributeInfo> attributes = collectionInfo.attributes;

  ClassFactory(this.collectionInfo);

  List<Spec> build() => [
        for (final attribute in attributes) ...[
          if (attribute is AttributeInfoEnum) ...[
            Enum((b) => b
              ..annotations.add(refer('immutable'))
              ..name = attribute.typeReference.symbol
              ..values.addAll(
                  attribute.values.map((e) => EnumValue((b) => b..name = e))))
          ],
        ],
        getClass(),
      ];

  Class getClass() => Class((b) => b
    ..annotations.add(refer('immutable'))
    ..name = className
    ..extend = refer('AppwriteModel<$className>')
    ..fields.addAll(getFields())
    ..constructors.add(getPrivateConstructor())
    ..constructors.add(getDefaultFactory())
    ..methods.add(toJsonMethod())
    ..methods.add(toAppwriteMethod())
    ..methods.add(copyWithMethod())
    // ..methods.add(toStringMethod())
    ..methods.add(operatorEqualMethod())
    ..methods.add(hashCodeGetter())
    ..constructors.add(fromAppwriteFactory())
    ..methods.addAll([
      pageMethod(),
      listMethod(),
      getMethod(),
      createMethod(),
      updateMethod(),
      deleteMethod(),
    ]));

  List<Field> getFields() {
    final fields = <Field>[
      Field(
        (b) => b
          ..name = 'collectionInfo'
          ..type = refer('CollectionInfo')
          ..static = true
          ..modifier = FieldModifier.constant
          ..assignment = Code('''
CollectionInfo(
  \$id: '${collectionInfo.$id}',
  \$permissions: ${collectionInfo.$permissions.map((e) => "'$e'").toList()},
  databaseId: '${collectionInfo.databaseId}',
  name: '${collectionInfo.name}',
  enabled: ${collectionInfo.enabled},
  documentSecurity: ${collectionInfo.documentSecurity},
)
'''),
      ),
    ];

    for (final attribute in attributes) {
      fields.addAll(attribute.getFields());
    }

    return fields;
  }

  Constructor getPrivateConstructor() => Constructor((b) {
        b
          ..name = '_'
          ..optionalParameters
              .addAll(attributes.map((e) => e.getConstructorParameter()))
          ..optionalParameters.add(Parameter((b) => b
            ..name = '\$id'
            ..named = true
            ..required = true
            ..toSuper = true))
          ..optionalParameters.add(Parameter((b) => b
            ..name = '\$collectionId'
            ..named = true
            ..required = true
            ..toSuper = true))
          ..optionalParameters.add(Parameter((b) => b
            ..name = '\$databaseId'
            ..named = true
            ..required = true
            ..toSuper = true))
          ..optionalParameters.add(Parameter((b) => b
            ..name = '\$createdAt'
            ..named = true
            ..required = true
            ..toSuper = true))
          ..optionalParameters.add(Parameter((b) => b
            ..name = '\$updatedAt'
            ..named = true
            ..required = true
            ..toSuper = true))
          ..optionalParameters.add(Parameter((b) => b
            ..name = '\$permissions'
            ..named = true
            ..required = true
            ..toSuper = true));

        final asserts = attributes.expand((e) => e.getConstructorAsserts());
        if (asserts.isNotEmpty) {
          b.initializers.addAll(asserts);
        } else {
          b.constant = true;
        }
      });

  Constructor getDefaultFactory() => Constructor((b) => b
    ..factory = true
    ..optionalParameters
        .addAll(attributes.map((e) => e.getDefaultFactoryParameter()))
    ..lambda = true
    ..body = Code('''
        $className._(
          ${attributes.map((e) => e.getDefaultFactoryField()).join(',\n')},
          \$id: ID.unique(),
          \$collectionId: collectionInfo.\$id,
          \$databaseId: collectionInfo.databaseId,
          \$createdAt: DateTime.now().toUtc(),
          \$updatedAt: DateTime.now().toUtc(),
          \$permissions: collectionInfo.\$permissions,
        )
'''));

  Method toJsonMethod() => Method((b) => b
    ..name = 'toJson'
    ..returns = refer('Map<String, dynamic>')
    ..annotations.add(refer('override'))
    ..lambda = true
    ..body = Code('''{
      ${attributes.map((e) => e.getToJsonField()).join(',\n')}
    }'''));

  Method toAppwriteMethod() => Method((b) => b
    ..name = 'toAppwrite'
    ..annotations.add(refer('override'))
    ..returns = refer('dynamic')
    ..optionalParameters.add(Parameter((b) => b
      ..name = 'relationLevels'
      ..named = true
      ..type = refer('List<RLevel>')
      ..defaultTo = Code('const []')))
    ..body = Block((body) {
      String getAttributeCode(AttributeInfo e) {
        if (e is AttributeInfoRelation) {
          if (AttributeInfoRelation.isTypeSingle(e.relationType, e.side)) {
            return "if (hasChildren) '${e.name}': ${e.name}?.toAppwrite(relationLevels: children)";
          } else {
            return "if (hasChildren) '${e.name}': ${e.name}?.map((e) => e.toAppwrite(relationLevels: children)).toList()";
          }
        }
        return "${e.getToJsonField()}";
      }

      if (attributes.any((e) => e is AttributeInfoRelation)) {
        body.statements.addAll([
          Code(
              'final children = relationLevels.isNotEmpty ? relationLevels.sublist(1) : null;'),
          Code('final hasChildren = children != null && children.isNotEmpty;'),
        ]);
      }

      body.statements.addAll([
        Code(
            'final rInfo = relationLevels.isNotEmpty ? relationLevels.first : null;'),
        Code('final hasRInfo = rInfo != null;'),
        Code('var data = <String, dynamic>{};'),
        Code('if (hasRInfo && rInfo.includeId) data[\'\\\$id\'] = \$id;'),
        Code(
            'if (hasRInfo && rInfo.includeData) {data = {...data, ...{ ${attributes.map(getAttributeCode).join(',\n')} }};}'),
        Code(
            'else if (!hasRInfo) {data = { ${attributes.map(getAttributeCode).join(',\n')} };}'),
        Code(
            'if (hasRInfo && rInfo.includePermissions) {data[\'\\\$permissions\'] = \$permissions;}'),
        Code(
            'if (hasRInfo && rInfo.includeId && !rInfo.includeData && !rInfo.includePermissions) {return \$id;} else {return data;}'),
      ]);
    }));

  Method copyWithMethod() => Method((b) => b
    ..name = 'copyWith'
    ..annotations.add(refer('override'))
    ..returns = refer(className)
    ..optionalParameters.addAll(attributes.map((e) => e.getCopyWithParameter()))
    ..optionalParameters.addAll([
      Parameter((b) => b
        ..name = '\$id'
        ..named = true
        ..type = refer('String?')),
      Parameter((b) => b
        ..name = '\$collectionId'
        ..type = refer('String?')),
      Parameter((b) => b
        ..name = '\$databaseId'
        ..type = refer('String?')),
      Parameter((b) => b
        ..name = '\$createdAt'
        ..type = refer('DateTime?')),
      Parameter((b) => b
        ..name = '\$updatedAt'
        ..type = refer('DateTime?')),
      Parameter((b) => b
        ..name = '\$permissions'
        ..type = refer('List<String>?')),
    ])
    ..lambda = true
    ..body = Code('''
        $className._(
          ${attributes.map((e) => e.getCopyWithField()).join(',\n')},
          \$id: \$id ?? this.\$id,
          \$collectionId: \$collectionId ?? this.\$collectionId,
          \$databaseId: \$databaseId ?? this.\$databaseId,
          \$createdAt: \$createdAt ?? this.\$createdAt,
          \$updatedAt: \$updatedAt ?? this.\$updatedAt,
          \$permissions: \$permissions ?? this.\$permissions,
        )
      '''));

  Method toStringMethod() => Method((b) => b
    ..name = 'toString'
    ..annotations.add(refer('override'))
    ..returns = refer('String')
    ..lambda = true
    ..body = Code('toJson().toString()'));

  Method operatorEqualMethod() => Method((b) => b
    ..name = 'operator =='
    ..annotations.add(refer('override'))
    ..returns = refer('bool')
    ..requiredParameters.add(Parameter((b) => b
      ..name = 'other'
      ..type = refer('Object')))
    ..lambda = true
    ..body = Code('''
        other is $className &&
          other.\$id == \$id &&
          ${attributes.map((e) => e.getEqualCheck()).join(' &&\n')}
      '''));

  Method hashCodeGetter() => Method((b) => b
    ..name = 'hashCode'
    ..type = MethodType.getter
    ..annotations.add(refer('override'))
    ..returns = refer('int')
    ..lambda = true
    ..body = Code('''
        _hash([
          \$id,
          ${attributes.map((e) => e.array ? '...(${e.name}${e.required ? '' : ' ?? []'})' : e.name).join(
              ',\n',
            )}
        ])
      '''));

  Constructor fromAppwriteFactory() => Constructor((b) => b
    ..factory = true
    ..name = 'fromAppwrite'
    ..requiredParameters.add(Parameter((b) => b
      ..name = 'doc'
      ..type = refer('Document')))
    ..lambda = true
    ..body = Code('''
        $className._(
          ${attributes.map((e) => e.getFromAppwriteField()).join(',\n')},
          \$id: doc.\$id,
          \$collectionId: doc.\$collectionId,
          \$databaseId: doc.\$databaseId,
          \$createdAt: DateTime.parse(doc.\$createdAt),
          \$updatedAt: DateTime.parse(doc.\$updatedAt),
          \$permissions: toList(doc.\$permissions),
        )
'''));

  Method pageMethod() => Method((b) => b
    ..name = 'page'
    ..static = true
    ..modifier = MethodModifier.async
    ..returns = refer('Future<Result<(int, List<$className>), String>>')
    ..optionalParameters.addAll([
      Parameter((b) => b
        ..name = 'limit'
        ..named = true
        ..type = refer('int')
        ..defaultTo = Code('25')),
      Parameter((b) => b
        ..name = 'offset'
        ..named = true
        ..type = refer('int?')),
      Parameter((b) => b
        ..name = 'last'
        ..named = true
        ..type = refer('$className?')),
      Parameter((b) => b
        ..name = 'queries'
        ..named = true
        ..type = refer('List<String>?')),
    ])
    ..lambda = true
    ..body = Code('''
    _client.page<$className>(
        databaseId: collectionInfo.databaseId,
        collectionId: collectionInfo.\$id,
        fromAppwrite: $className.fromAppwrite,
        limit: limit,
        offset: offset,
        last: last,
        queries: queries,
      )
  '''));

  Method listMethod() => Method((b) => b
    ..name = 'list'
    ..modifier = MethodModifier.async
    ..returns = refer('Future<Result<(int, List<$className>), String>>')
    ..optionalParameters.addAll([
      Parameter((b) => b
        ..name = 'queries'
        ..type = refer('List<String>?')),
    ])
    ..lambda = true
    ..body = Code('''
    _client.list<$className>(
        databaseId: collectionInfo.databaseId,
        collectionId: collectionInfo.\$id,
        fromAppwrite: $className.fromAppwrite,
        queries: queries,
      )
  '''));

  Method getMethod() => Method((b) => b
    ..name = 'get'
    ..static = true
    ..modifier = MethodModifier.async
    ..returns = refer('Future<Result<$className, String>>')
    ..requiredParameters.addAll([
      Parameter((b) => b
        ..name = 'documentId'
        ..type = refer('String')),
    ])
    ..optionalParameters.addAll([
      Parameter((b) => b
        ..name = 'queries'
        ..named = true
        ..type = refer('List<String>?'))
    ])
    ..lambda = true
    ..body = Code('''
    _client.get<$className>(
        databaseId: collectionInfo.databaseId,
        collectionId: collectionInfo.\$id,
        fromAppwrite: $className.fromAppwrite,
        documentId: documentId,
        queries: queries,
      )
  '''));

  Method createMethod() => Method((b) => b
    ..name = 'create'
    ..modifier = MethodModifier.async
    ..returns = refer('Future<Result<$className, String>>')
    ..optionalParameters.addAll([
      Parameter((b) => b
        ..name = 'relationLevels'
        ..named = true
        ..type = refer('List<RLevel>')
        ..defaultTo = Code('const []')),
    ])
    ..lambda = true
    ..body = Code('''
    _client.create<$className>(
        databaseId: collectionInfo.databaseId,
        collectionId: collectionInfo.\$id,
        fromAppwrite: $className.fromAppwrite,
        model: this,
        relationLevels: relationLevels,
      )
  '''));

  Method updateMethod() => Method((b) => b
    ..name = 'update'
    ..modifier = MethodModifier.async
    ..returns = refer('Future<Result<$className, String>>')
    ..optionalParameters.addAll([
      Parameter((b) => b
        ..name = 'relationLevels'
        ..type = refer('List<RLevel>')
        ..named = true
        ..defaultTo = Code('const []')),
    ])
    ..lambda = true
    ..body = Code('''
    _client.update<$className>(
        databaseId: collectionInfo.databaseId,
        collectionId: collectionInfo.\$id,
        fromAppwrite: $className.fromAppwrite,
        model: this,
        relationLevels: relationLevels,
      )
  '''));

  Method deleteMethod() => Method((b) => b
    ..name = 'delete'
    ..modifier = MethodModifier.async
    ..returns = refer('Future<Result<void, String>>')
    ..lambda = true
    ..body = Code('''
    _client.delete(
        databaseId: collectionInfo.databaseId,
        collectionId: collectionInfo.\$id,
        documentId: \$id,
      )
  '''));
}
