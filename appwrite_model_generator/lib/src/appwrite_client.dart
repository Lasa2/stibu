import 'package:code_builder/code_builder.dart';

Class getClass() => Class((b) => b
  ..name = 'AppwriteClient'
  ..fields.addAll(getFields())
  ..constructors.addAll(getConstructors())
  ..methods.addAll([
    pageMethod(),
    listMethod(),
    getMethod(),
    createMethod(),
    updateMethod(),
    deleteMethod(),
  ]));

List<Field> getFields() => [
      Field((b) => b
        ..name = 'client'
        ..type = refer('Client')
        ..modifier = FieldModifier.final$),
      Field((b) => b
        ..name = 'account'
        ..modifier = FieldModifier.final$
        ..type = refer('Account')),
      Field((b) => b
        ..name = 'databases'
        ..modifier = FieldModifier.final$
        ..type = refer('Databases')),
      Field((b) => b
        ..name = 'realtime'
        ..modifier = FieldModifier.final$
        ..type = refer('Realtime')),
      Field((b) => b
        ..name = 'functions'
        ..modifier = FieldModifier.final$
        ..type = refer('Functions')),
      Field((b) => b
        ..name = 'avatars'
        ..modifier = FieldModifier.final$
        ..type = refer('Avatars')),
      Field((b) => b
        ..name = 'storage'
        ..modifier = FieldModifier.final$
        ..type = refer('Storage')),
    ];

List<Constructor> getConstructors() => [
      Constructor((b) => b
        ..requiredParameters.add(Parameter((b) => b
          ..name = 'client'
          ..toThis = true))
        ..initializers.addAll([
          Code('account = Account(client)'),
          Code('databases = Databases(client)'),
          Code('realtime = Realtime(client)'),
          Code('functions = Functions(client)'),
          Code('avatars = Avatars(client)'),
          Code('storage = Storage(client)'),
        ])),
    ];

Method pageMethod() => Method((b) => b
  ..name = 'page'
  ..types.add(refer('T extends AppwriteModel<T>'))
  ..modifier = MethodModifier.async
  ..returns = refer('Future<Result<(int, List<T>), String>>')
  ..optionalParameters.addAll([
    Parameter((b) => b
      ..name = 'databaseId'
      ..named = true
      ..required = true
      ..type = refer('String')),
    Parameter((b) => b
      ..name = 'collectionId'
      ..named = true
      ..required = true
      ..type = refer('String')),
    Parameter((b) => b
      ..name = 'fromAppwrite'
      ..named = true
      ..required = true
      ..type = refer('T Function(Document doc)')),
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
      ..type = refer('T?')),
    Parameter((b) => b
      ..name = 'queries'
      ..named = true
      ..type = refer('List<String>?')),
  ])
  ..body = Code('''
    assert(limit > 0, 'Limit must be greater than 0');
    assert(offset != null && offset >= 0 || last != null, 'Either offset or last must be provided');
    try {
      final response = await databases.listDocuments(
        databaseId: databaseId,
        collectionId: collectionId,
        queries: [
          Query.limit(limit),
          if (offset != null) Query.offset(offset),
          if (last != null) Query.cursorAfter(last.\$id),
          ...?queries,
        ],
      );
      return Success((
        response.total,
        response.documents.map((e) => fromAppwrite(e)).toList(),
      ));
    } on AppwriteException catch (e) {
      return Failure(e.message ?? 'Unable to list documents');
    }
  '''));

Method listMethod() => Method((b) => b
  ..name = 'list'
  ..types.add(refer('T extends AppwriteModel<T>'))
  ..modifier = MethodModifier.async
  ..returns = refer('Future<Result<(int, List<T>), String>>')
  ..optionalParameters.addAll([
    Parameter((b) => b
      ..name = 'databaseId'
      ..named = true
      ..required = true
      ..type = refer('String')),
    Parameter((b) => b
      ..name = 'collectionId'
      ..named = true
      ..required = true
      ..type = refer('String')),
    Parameter((b) => b
      ..name = 'fromAppwrite'
      ..named = true
      ..required = true
      ..type = refer('T Function(Document doc)')),
    Parameter((b) => b
      ..name = 'queries'
      ..named = true
      ..type = refer('List<String>?')),
  ])
  ..body = Code('''
    try {
      final response = await databases.listDocuments(
        databaseId: databaseId,
        collectionId: collectionId,
        queries: queries ?? [],
      );
      return Success((
        response.total,
        response.documents.map((e) => fromAppwrite(e)).toList(),
      ));
    } on AppwriteException catch (e) {
      return Failure(e.message ?? 'Unable to list documents');
    }
  '''));

Method getMethod() => Method((b) => b
  ..name = 'get'
  ..types.add(refer('T extends AppwriteModel<T>'))
  ..modifier = MethodModifier.async
  ..returns = refer('Future<Result<T, String>>')
  ..optionalParameters.addAll([
    Parameter((b) => b
      ..name = 'databaseId'
      ..named = true
      ..required = true
      ..type = refer('String')),
    Parameter((b) => b
      ..name = 'collectionId'
      ..named = true
      ..required = true
      ..type = refer('String')),
    Parameter((b) => b
      ..name = 'documentId'
      ..named = true
      ..required = true
      ..type = refer('String')),
    Parameter((b) => b
      ..name = 'fromAppwrite'
      ..named = true
      ..required = true
      ..type = refer('T Function(Document doc)')),
    Parameter((b) => b
      ..name = 'queries'
      ..named = true
      ..type = refer('List<String>?'))
  ])
  ..body = Code('''
    try {
      final response = await databases.getDocument(
        databaseId: databaseId,
        collectionId: collectionId,
        documentId: documentId,
        queries: queries,
      );
      return Success(fromAppwrite(response));
    } on AppwriteException catch (e) {
      return Failure(e.message ?? 'Unable to get document');
    }
  '''));

Method createMethod() => Method((b) => b
  ..name = 'create'
  ..types.add(refer('T extends AppwriteModel<T>'))
  ..modifier = MethodModifier.async
  ..returns = refer('Future<Result<T, String>>')
  ..optionalParameters.addAll([
    Parameter((b) => b
      ..name = 'databaseId'
      ..named = true
      ..required = true
      ..type = refer('String')),
    Parameter((b) => b
      ..name = 'collectionId'
      ..named = true
      ..required = true
      ..type = refer('String')),
    Parameter((b) => b
      ..name = 'fromAppwrite'
      ..named = true
      ..required = true
      ..type = refer('T Function(Document doc)')),
    Parameter((b) => b
      ..name = 'model'
      ..named = true
      ..required = true
      ..type = refer('T')),
    Parameter((b) => b
      ..name = 'relationLevels'
      ..named = true
      ..type = refer('List<RLevel>')
      ..defaultTo = Code('const []')),
  ])
  ..body = Code('''
    try {
      final response = await databases.createDocument(
        databaseId: databaseId,
        collectionId: collectionId,
        documentId: model.\$id,
        data: model.toAppwrite(relationLevels: relationLevels),
        permissions: model.\$permissions,
      );
      return Success(fromAppwrite(response));
    } on AppwriteException catch (e) {
      return Failure(e.message ?? 'Unable to create document');
    }
  '''));

Method updateMethod() => Method((b) => b
  ..name = 'update'
  ..types.add(refer('T extends AppwriteModel<T>'))
  ..modifier = MethodModifier.async
  ..returns = refer('Future<Result<T, String>>')
  ..optionalParameters.addAll([
    Parameter((b) => b
      ..name = 'databaseId'
      ..named = true
      ..required = true
      ..type = refer('String')),
    Parameter((b) => b
      ..name = 'collectionId'
      ..named = true
      ..required = true
      ..type = refer('String')),
    Parameter((b) => b
      ..name = 'fromAppwrite'
      ..named = true
      ..required = true
      ..type = refer('T Function(Document doc)')),
    Parameter((b) => b
      ..name = 'model'
      ..named = true
      ..required = true
      ..type = refer('T')),
    Parameter((b) => b
      ..name = 'relationLevels'
      ..named = true
      ..type = refer('List<RLevel>')
      ..defaultTo = Code('const []')),
  ])
  ..body = Code('''
    try {
      final response = await databases.updateDocument(
        databaseId: databaseId,
        collectionId: collectionId,
        documentId: model.\$id,
        data: model.toAppwrite(relationLevels: relationLevels),
        permissions: model.\$permissions,
      );
      return Success(fromAppwrite(response));
    } on AppwriteException catch (e) {
      return Failure(e.message ?? 'Unable to update document');
    }
  '''));

Method deleteMethod() => Method((b) => b
  ..name = 'delete'
  ..modifier = MethodModifier.async
  ..returns = refer('Future<Result<void, String>>')
  ..optionalParameters.addAll([
    Parameter((b) => b
      ..name = 'databaseId'
      ..named = true
      ..required = true
      ..type = refer('String')),
    Parameter((b) => b
      ..name = 'collectionId'
      ..named = true
      ..required = true
      ..type = refer('String')),
    Parameter((b) => b
      ..name = 'documentId'
      ..named = true
      ..required = true
      ..type = refer('String')),
  ])
  ..body = Code('''
    try {
      await databases.deleteDocument(
        databaseId: databaseId,
        collectionId: collectionId,
        documentId: documentId,
      );
      return Success(null);
    } on AppwriteException catch (e) {
      return Failure(e.message ?? 'Unable to delete document');
    }
  '''));
