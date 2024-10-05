import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';

final _dartfmt = DartFormatter();

Future<void> generateAppwriteClient() async {
  final emitter = DartEmitter(allocator: Allocator(), orderDirectives: true);
  final output = getLibary();

  final formatted = _dartfmt.format('${output.accept(emitter)}');

  print(formatted);
}

Library getLibary() => Library((lib) => lib
  ..directives.add(Directive.import('package:appwrite/appwrite.dart'))
  ..directives.add(Directive.import('package:appwrite/models.dart'))
  ..directives.add(Directive.import('package:result_type/result_type.dart'))
  ..body.add(getClass()));

Class getClass() => Class((b) => b
  ..name = 'AppwriteClient'
  ..fields.addAll(getFields())
  ..constructors.addAll(getConstructors()));

List<Field> getFields() => [
      Field((b) => b
        ..name = 'client'
        ..type = refer('Client')
        ..modifier = FieldModifier.final$),
      Field((b) => b
        ..name = 'account'
        ..type = refer('Account')
        ..modifier = FieldModifier.final$
        ..late = true
        ..assignment = Code('Account(client)')),
      Field((b) => b
        ..name = 'databases'
        ..type = refer('Databases')
        ..modifier = FieldModifier.final$
        ..late = true
        ..assignment = Code('Databases(client)')),
      Field((b) => b
        ..name = 'realtime'
        ..type = refer('Realtime')
        ..modifier = FieldModifier.final$
        ..late = true
        ..assignment = Code('Realtime(client)')),
      Field((b) => b
        ..name = 'functions'
        ..type = refer('Functions')
        ..modifier = FieldModifier.final$
        ..late = true
        ..assignment = Code('Functions(client)')),
      Field((b) => b
        ..name = 'avatars'
        ..type = refer('Avatars')
        ..modifier = FieldModifier.final$
        ..late = true
        ..assignment = Code('Avatars(client)')),
      Field((b) => b
        ..name = 'storage'
        ..type = refer('Storage')
        ..modifier = FieldModifier.final$
        ..late = true
        ..assignment = Code('Storage(client)')),
    ];

List<Constructor> getConstructors() => [
      Constructor((b) => b
        ..requiredParameters.add(Parameter((b) => b
          ..name = 'client'
          ..type = refer('Client')
          ..toThis = true)))
    ];

Method pageMethod() => Method((b) => b
  ..name = 'page'
  ..types.add(refer('T extends AppwriteModel<T>'))
  ..modifier = MethodModifier.async
  ..returns = refer('Future<Result<(int, List<T>), String>>')
  ..requiredParameters.addAll([
    Parameter((b) => b
      ..name = 'databaseId'
      ..type = refer('String')),
    Parameter((b) => b
      ..name = 'collectionId'
      ..type = refer('String')),
    Parameter((b) => b
      ..name = 'fromAppwrite'
      ..type = refer('T Function(Document doc)')),
  ])
  ..optionalParameters.addAll([
    Parameter((b) => b
      ..name = 'limit'
      ..type = refer('int')
      ..defaultTo = Code('25')),
    Parameter((b) => b
      ..name = 'offset'
      ..type = refer('int?')),
    Parameter((b) => b
      ..name = 'last'
      ..type = refer('T?')),
    Parameter((b) => b
      ..name = 'queries'
      ..type = refer('List<Query>?')),
  ])
  ..body = Code('''
    assert(limit > 0);
    assert(offset != null && offset >= 0 || last != null);
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
      return Success(
        response.total,
        response.documents.map((e) => fromAppwrite(e)).toList(),
      );
    } catch (e) {
      return Failure(e.message ?? "Unable to list documents");
    }
  '''));

Method listMethod() => Method((b) => b
  ..name = 'list'
  ..types.add(refer('T extends AppwriteModel<T>'))
  ..modifier = MethodModifier.async
  ..returns = refer('Future<Result<List<T>, String>>')
  ..requiredParameters.addAll([
    Parameter((b) => b
      ..name = 'databaseId'
      ..type = refer('String')),
    Parameter((b) => b
      ..name = 'collectionId'
      ..type = refer('String')),
    Parameter((b) => b
      ..name = 'fromAppwrite'
      ..type = refer('T Function(Document doc)')),
    Parameter((b) => b
      ..name = 'queries'
      ..type = refer('List<Query>')),
  ])
  ..body = Code('''
    try {
      final response = await databases.listDocuments(
        databaseId: databaseId,
        collectionId: collectionId,
        queries: queries,
      );
      return Success(response.documents.map((e) => fromAppwrite(e)).toList());
    } catch (e) {
      return Failure(e.message ?? "Unable to list documents");
    }
  '''));

Method getMethod() => Method((b) => b
  ..name = 'get'
  ..types.add(refer('T extends AppwriteModel<T>'))
  ..modifier = MethodModifier.async
  ..returns = refer('Future<Result<T, String>>')
  ..requiredParameters.addAll([
    Parameter((b) => b
      ..name = 'databaseId'
      ..type = refer('String')),
    Parameter((b) => b
      ..name = 'collectionId'
      ..type = refer('String')),
    Parameter((b) => b
      ..name = 'documentId'
      ..type = refer('String')),
    Parameter((b) => b
      ..name = 'fromAppwrite'
      ..type = refer('T Function(Document doc)')),
  ])
  ..optionalParameters.addAll([
    Parameter((b) => b
      ..name = 'queries'
      ..type = refer('List<Query>?'))
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
    } catch (e) {
      return Failure(e.message ?? "Unable to get document");
    }
  '''));

Method createMethod() => Method((b) => b
  ..name = 'create'
  ..types.add(refer('T extends AppwriteModel<T>'))
  ..modifier = MethodModifier.async
  ..returns = refer('Future<Result<T, String>>')
  ..requiredParameters.addAll([
    Parameter((b) => b
      ..name = 'databaseId'
      ..type = refer('String')),
    Parameter((b) => b
      ..name = 'collectionId'
      ..type = refer('String')),
    Parameter((b) => b
      ..name = 'fromAppwrite'
      ..type = refer('T Function(Document doc)')),
    Parameter((b) => b
      ..name = 'model'
      ..type = refer('T')),
  ])
  ..optionalParameters.addAll([
    Parameter((b) => b
      ..name = 'permissions'
      ..type = refer('List<String>?'))
  ])
  ..body = Code('''
    try {
      final response = await databases.createDocument(
        databaseId: databaseId,
        collectionId: collectionId,
        documentId: model.\$id,
        data: model.toAppwrite(),
        permissions: permissions,
      );
      return Success(fromAppwrite(response));
    } catch (e) {
      return Failure(e.message ?? "Unable to create document");
    }
  '''));

Method updateMethod() => Method((b) => b
  ..name = 'update'
  ..types.add(refer('T extends AppwriteModel<T>'))
  ..modifier = MethodModifier.async
  ..returns = refer('Future<Result<T, String>>')
  ..requiredParameters.addAll([
    Parameter((b) => b
      ..name = 'databaseId'
      ..type = refer('String')),
    Parameter((b) => b
      ..name = 'collectionId'
      ..type = refer('String')),
    Parameter((b) => b
      ..name = 'fromAppwrite'
      ..type = refer('T Function(Document doc)')),
    Parameter((b) => b
      ..name = 'model'
      ..type = refer('T')),
  ])
  ..optionalParameters.addAll([
    Parameter((b) => b
      ..name = 'permissions'
      ..type = refer('List<String>?')),
    Parameter((b) => b
      ..name = 'includeRelations'
      ..type = refer('bool')
      ..defaultTo = Code('false')),
  ])
  ..body = Code('''
    try {
      final response = await databases.updateDocument(
        databaseId: databaseId,
        collectionId: collectionId,
        documentId: model.\$id,
        data: model.toAppwrite(),
        permissions: permissions,
      );
      return Success(fromAppwrite(response));
    } catch (e) {
      return Failure(e.message ?? "Unable to update document");
    }
  '''));

Method deleteMethod() => Method((b) => b
  ..name = 'delete'
  ..modifier = MethodModifier.async
  ..returns = refer('Future<Result<void, String>>')
  ..requiredParameters.addAll([
    Parameter((b) => b
      ..name = 'databaseId'
      ..type = refer('String')),
    Parameter((b) => b
      ..name = 'collectionId'
      ..type = refer('String')),
    Parameter((b) => b
      ..name = 'documentId'
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
    } catch (e) {
      return Failure(e.message ?? "Unable to delete document");
    }
  '''));
